//
//  Extension.swift
//  recipe
//
//  Created by Wyatt Cheang on 10/10/2024.
//

import Foundation

extension String {
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
                                             options: .caseInsensitive)
        
        return regex.firstMatch(in: self, range: NSRange(location: 0, length: count)) != nil
    }
    
    func isValidPassword() -> Bool {
        // minimum 6 characters long
        // 1 uppercase character
        // 1 special char
        let passwordRegex = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[A-Z])(?=.*[$@$#!%*?&]).{6,}$")
        return passwordRegex.evaluate(with: self)
    }
    
    var dropHexPrefix: String {
        return self.replacingOccurrences(of: "0x", with: "")
            .replacingOccurrences(of: "U+", with: "")
            .replacingOccurrences(of: "#", with: "")
    }
    
    var toUnicode: String {
        if let charCode = UInt32(self.dropHexPrefix, radix: 16),
           let unicode = UnicodeScalar(charCode) {
            let str = String(unicode)
            return str
        }
        return "error"
    }
    
}
