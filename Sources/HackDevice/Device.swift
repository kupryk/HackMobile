//
//  File.swift
//  
//
//  Created by Mikita Kupryk on 23/12/2023.
//

import Foundation
import HackMobile
import RitchieDevice

private var deviceList: [String: Device] = [:]
 
public struct Device: DeviceDisplayable {
    
    /// Prefer the network connection even if the device is paired via USB.
    public var preferNetworkConnection: Bool = false

    /// Set this value to true to find network & USB devices or to false to only find USB devices.
    public static var detectNetworkDevices: Bool = false
    
    /// The default `preferNetworkConnection` value.
    /// Change this value to change the `preferNetworkConnection` on initialisation for all devices.
    public static var preferNetworkConnectionDefault: Bool = false

    public private(set) var udid: String
    public private(set) var name: String
    public private(set) var productName: String?
    public private(set) var version: String?
    public private(set) var connectionType: ConnectionType = .unknown
    public private(set) static var isGeneratingDeviceNotifications: Bool = false
    
    public static var availableDevices: [DeviceDisplayable] {
        return Array(deviceList.values)
    }
    
    /// Readonly: Get the current lookup flags to perform the request. This allows changing from USB to network.
    private var lookupOptions: idevice_options {
        var options = connectionType.lookupOptions

        if preferNetworkConnection && connectionType.contains(.network) {
            options.rawValue |= IDEVICE_LOOKUP_PREFER_NETWORK.rawValue
        }
        
        return options
    }

    /// Readonly: True when the devices uses the network connection, otherwise false.
    public var usesNetwork: Bool {
        return (connectionType == .network) || (connectionType.contains(.network) && preferNetworkConnection)
    }

    /// Readonly: True if the DeveloperDiskImage is already mounted
    public var developerDiskImageIsMounted: Bool {
        return developerImageIsMountedForDevice(udid, lookupOptions)
    }

    /// Readonly: True if DeveloperMode is enabled
    public var developerModeIsEnabled: Bool {
        guard majorVersion ?? 0 >= 16 else {
            return true
        }
    
        return developerModeIsEnabledForDevice(udid, lookupOptions)
    }

    // MARK: - Static functions
    
    /// Start an observer for newly added, paired or removed iOS devices.
    /// - Return: True if the observer could be started, false otherwise.
    @discardableResult
    public static func startGeneratingDeviceNotifications() -> Bool {
        guard !Device.isGeneratingDeviceNotifications else { 
            return false
        }

        let callback: idevice_event_cb_t = { (event, _: UnsafeMutableRawPointer?) in            
            guard let eventT = event?.pointee, let udidT = eventT.udid else {
                return
            }

            let udid = String(cString: udidT)
            var notificationName: Notification.Name?

            // Replace the idevice_connection_type with a swift enum
            var connectionType: ConnectionType = .unknown
            
            switch eventT.conn_type {
                case CONNECTION_USBMUXD: 
                    connectionType = .usb
                case CONNECTION_NETWORK:
                    // Make sure to skip this network device if we only allow USB connections.
                    guard Device.detectNetworkDevices else {
                        return
                    }
            
                    connectionType = .network
                default:
                    connectionType = .unknown
            }

            // The existing device isntance or nil if the device does not exist yet.
            var device = deviceList[udid]

            // Determine the correct event to send
            switch eventT.event {
            case IDEVICE_DEVICE_ADD, IDEVICE_DEVICE_PAIRED:
                // Check if the devive is already connected via a different connection type.
                if (device != nil) && !(device!.connectionType.contains(connectionType)) {
                    // Add the missing connection type to the device.
                    device?.connectionType.insert(connectionType)
                    notificationName = .deviceChanged
                    break
                } else if let res = deviceName(udid, connectionType.lookupOptions) {
                    // Create and add the device to the internal device list before sending the notification.
                    device = Device(UDID: udid, name: String(cString: res), connectionType: connectionType)
                    notificationName = (eventT.event == IDEVICE_DEVICE_ADD) ? .deviceConnected : .devicePaired

                    // Load the product details
                    let productVersion: UnsafePointer<Int8> = deviceProductVersion(udid, connectionType.lookupOptions)
                    device?.version = String(cString: productVersion)

                    let productName: UnsafePointer<Int8> = deviceProductName(udid, connectionType.lookupOptions)
                    device?.productName = String(cString: productName)

                    break
                }

                // Something went wrong. Most likely we can not read the device. Abort.
                return

            case IDEVICE_DEVICE_REMOVE:
                // Remove an existing connectionType from the list.
                if device?.connectionType.contains(connectionType) ?? false {
                    device?.connectionType.remove(connectionType)

                    // If there is no connection type left, we need to disconnect the device.
                    notificationName = (device?.connectionType.isEmpty ?? true) ? .deviceDisconnected : .deviceChanged
                    break
                }

                // Something went wrong. Maybe some error in the connection.
                notificationName = .deviceDisconnected
            default:
                return
            }
            
            // The deviceList does not store references, therefore write the modified device to the list to update
            // the cached device.
            deviceList[udid] = (notificationName == .deviceDisconnected) ? nil : device

            DispatchQueue.main.async {
                // Fix a rare crash where device is somehow nil.
                if let device = device {
                    NotificationCenter.default.post(name: notificationName!, object: nil, userInfo: ["device": device])
                }
            }
        }

        // Subscribe for new devices events.
        if idevice_event_subscribe(callback, nil) == IDEVICE_E_SUCCESS {
            Device.isGeneratingDeviceNotifications = true
            return true
        }
        
        return false
    }
    // swiftlint:enable cyclomatic_complexity

    /// Stop observing device changes.
    /// - Return: True if the observer could be closed, False otherwise.
    @discardableResult
    public static func stopGeneratingDeviceNotifications() -> Bool {
        guard Device.isGeneratingDeviceNotifications else { return false }

        // Remove all currently connected devices.
        deviceList.forEach { NotificationCenter.default.post(name: .deviceDisconnected, object: nil, userInfo: ["device": $1]) }
        deviceList.removeAll()

        // Cancel device event subscription.
        if idevice_event_unsubscribe() == IDEVICE_E_SUCCESS {
            Device.isGeneratingDeviceNotifications = false
            return true
        }

        return false
    }

    // MARK: - Initializing Device
    private init(UDID: String, name: String, connectionType: ConnectionType) {
        self.udid = UDID
        self.name = name
        self.connectionType = connectionType
        // Assign the default value
        self.preferNetworkConnection = Device.preferNetworkConnectionDefault
    }

    // MARK: - Upload Developer Disk Image

    /// Pair the specific iOS Device with this computer and try to upload the DeveloperDiskImage.
    /// - Parameter devImage: URL to the DeveloperDiskImage.dmg
    /// - Parameter devImageSig: URL to the DeveloperDiskImage.dmg.signature
    /// - Throws:
    ///    * `DeviceError.pair`: The pairing process failed
    ///    * `DeviceError.devMode`: Developer mode is not enabled
    ///    * `DeviceError.devDiskImageMount`: DeveloperDiskImage mounting failed
    /// - Return: Device instance
    public func pair(devImage: URL, devImageSig: URL) throws {
        // Check if the device is connected
        guard pairDevice(self.udid, self.lookupOptions) else {
            throw DeviceError.pair("Could not pair device!")
        }

        // Try to enable developer mode if required
        if !self.developerModeIsEnabled {
            throw DeviceError.devMode("Developer mode not enabled!")
        }

        // Try to mount the DeveloperDiskImage.dmg
        if !self.mountDeveloperDiskImage(devImage: devImage, devImageSig: devImageSig) {
            throw DeviceError.devDiskImageMount("Mount error!")
        }
    }

    /// Display the developer mode toggle inside the settings app.
    /// - Return: true on success, false otherwise
    @discardableResult
    public func enabledDeveloperModeToggleInSettings() -> Bool {
        return enableDeveloperMode(self.udid, self.lookupOptions)
    }

    /// Try to upload and mount the DeveloperDiskImage.dmg on this device.
    /// - Parameter devImage: URL to the DeveloperDiskImage.dmg
    /// - Parameter devImageSig: URL to the DeveloperDiskImage.dmg.signature
    private func mountDeveloperDiskImage(devImage: URL, devImageSig: URL) -> Bool {
        return mountImageForDevice(udid, devImage.path, devImageSig.path, self.lookupOptions)
    }

}

extension Device: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.udid == rhs.udid
    }

}
