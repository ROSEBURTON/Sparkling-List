//
//  Keychain.swift
//  Sparkling List
//
//  Created by IAL VECTOR on 4/21/24.
//

import Foundation
import Security

class KeychainService {
    
    private static let service = Bundle.main.bundleIdentifier ?? "Sparkling-List"
    private static let key = "paying_customer"
    
    static func savePayingCustomerStatus(_ payingCustomer: Bool) {
        let data = payingCustomer ? Data([1]) : Data([0])
        save(key: key, data: data)
    }
    
    static func loadPayingCustomerStatus() -> Bool? {
        if let data = load(key: key) {
            return data[0] == 1
        }
        return nil
    }
    
    static func save(key: String, data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Failed to save data to Keychain")
            return
        }
    }
    
    private static func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            print("Failed to load data from Keychain")
            return nil
        }
        return data
    }
}
