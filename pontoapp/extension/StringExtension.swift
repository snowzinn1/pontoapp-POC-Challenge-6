//
//  StringExtension.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 17/03/26.
//

import Foundation

extension String {
    func trimingWhitespaces() -> String {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        let realString = trimmed.split(separator: " ").joined(separator: "-")
        let realStringWithOutSpecialCharacter = realString.folding(options: .diacriticInsensitive, locale: .current)
        return realStringWithOutSpecialCharacter
    }
}
