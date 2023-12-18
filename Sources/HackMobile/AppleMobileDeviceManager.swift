//
//  AppleMobileDeviceManager.swift
//


import AnyCodable
import Foundation
import HackMobile

public class AppleMobileDeviceManager {
    
    public struct Configuration {
        public var connectionMethod: ConnectionMethod = .usbPreferred
    }
    
    public static let shared = AppleMobileDeviceManager()
    public static var configuration: Configuration = .init()
    
    private init() {}

    public class CodableRecord: Codable, Equatable, Hashable, Identifiable {
        public var id: UUID = .init()
        public internal(set) var store: AnyCodable
        
        public var plistData: Data? {
            guard !dictionary.keys.isEmpty, let data = try? PropertyListEncoder().encode(AnyCodable(dictionary)) else {
                return nil
            }
    
            return data
        }

        public var xml: String? {
            guard !dictionary.keys.isEmpty,
                  let data = try? PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: .zero),
                  let text = String(data: data, encoding: .utf8), !text.isEmpty else {
                return nil
            }
        
            return text
        }
        
        var dictionary: [String: Any] {
            return store.value as? [String: Any] ?? [:]
        }
        
        public init() {
            store = .init([String: String]())
        }
        
        public init(store: AnyCodable) {
            self.store = store
        }

        public func valueFor<T: Codable>(_ key: String) -> T? {
            return (store.value as? [String: Any])?[key] as? T
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(store)
        }

        public static func == (lhs: CodableRecord, rhs: CodableRecord) -> Bool {
            return lhs.store == rhs.store
        }
    }
}

#if DEBUG

    func generateDictionaryGetter(_ input: AnyCodable?) {
        var gen = [String]()
        
        (input?.value as? [String: Any])?.forEach { pair in
            let key = pair.key
            
            guard !key.isEmpty else {
                return
            }
        
            let keyName = key.first!.lowercased() + String(key.dropFirst())
            let value = pair.value
            let valueType = type(of: value)
            gen.append("public var \(keyName): \(valueType)? { decode(\"\(key)\") }")
        }
    
        gen.sort()
        gen.forEach { print($0) }
    }

#endif
