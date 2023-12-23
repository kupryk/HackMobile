//
//  File.swift
//
//
//  Created by Mikita Kupryk on 23/12/2023.
//

import HackMobile
import Foundation

public struct ConnectionType: OptionSet, Hashable, CustomStringConvertible, Codable {
    public let rawValue: Int
    
    public static let unknown = ConnectionType(rawValue: 1 << 0)
    public static let usb     = ConnectionType(rawValue: 1 << 1)
    public static let network = ConnectionType(rawValue: 1 << 2)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public var description: String {
        let options: [ConnectionType: String] = [.usb: "usb", .network: "network", .unknown: "unknown"]
        let optionArr: [String] = options.keys.compactMap { self.contains($0) ? options[$0] : nil }
        return optionArr.joined(separator: ", ")
    }
    
    public var lookupOptions: idevice_options {
        switch self {
            case .network:
                return IDEVICE_LOOKUP_NETWORK
            case .usb:
                return IDEVICE_LOOKUP_USBMUX
            default:
                return idevice_options(IDEVICE_LOOKUP_NETWORK.rawValue | IDEVICE_LOOKUP_USBMUX.rawValue)
        }
    }
}
