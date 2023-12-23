//
//  File.swift
//  
//
//  Created by Mikita Kupryk on 23/12/2023.
//

import Foundation

public enum DeviceError: Error, LocalizedError {
    case pair(_ message: String)
    case permisson(_ message: String)
    case devDiskImageNotFound(_ message: String)
    case devDiskImageMount(_ message: String)
    case productInfo(_ message: String)
    case devMode(_ message: String)

    public var errorDescription: String? {
        switch self {
            case .pair(let message),
                 .permisson(let message),
                 .devDiskImageNotFound(let message),
                 .devDiskImageMount(let message),
                 .productInfo(let message),
                 .devMode(let message):
                return message
        }
    }
}
