//
//  File.swift
//  
//
//  Created by Mikita Kupryk on 23/12/2023.
//

import Foundation

public protocol Device: CustomStringConvertible {
    var udid: String { get }
    var name: String { get }
    var version: String? { get }
    var minorVersion: Int { get }
    var majorVersion: Int? { get }
    var productName: String? { get }
    var connectionType: ConnectionType { get }

    static var availableDevices: [Device] { get }
    static var isGeneratingDeviceNotifications: Bool { get }

    @discardableResult static func startGeneratingDeviceNotifications() -> Bool
    @discardableResult static func stopGeneratingDeviceNotifications() -> Bool
}

public extension Device {
    
    var majorVersion: Int? {
        guard let components = self.version?.split(separator: "."), !components.isEmpty else {
            return nil
        }
        
        return Int(components[0])
    }

    var minorVersion: Int {
        guard let components = self.version?.split(separator: "."), components.count > 1 else {
            return 0
        }
        
        return Int(components[1])!
    }

    var description: String {
        return "\(type(of: self))(udid: \(udid), name: \(name), connectionType: \(connectionType))"
    }

}
