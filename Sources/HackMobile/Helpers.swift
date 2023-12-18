//
//  Helpers.swift
//


import AnyCodable
import Foundation
import HackMobileCore

public typealias AnyCodableDictionary = [String: AnyCodable]

enum Helpers {
    
    static func read_plist_to_binary_data(plist: plist_t?) -> Data? {
        guard let plist = plist else {
            return nil
        }
        
        var buf: UnsafeMutablePointer<CChar>?
        
        defer {
            free(buf)
        }
        
        var len: UInt32 = 0
        
        guard plist_to_bin(plist, &buf, &len) == PLIST_ERR_SUCCESS, let buf = buf, len > 0 else {
            return nil
        }
        
        return Data(bytes: buf, count: Int(len))
    }

}

extension Result where Success == Void {
    
    static func success() -> Self {
        return .success(())
    }
    
}
