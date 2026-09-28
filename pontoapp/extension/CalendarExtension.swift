//
//  CalendarExtension.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 13/08/26.
//

import Foundation

extension Calendar{
    
    static let academy: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "America/Sao_Paulo")!
        calendar.locale = Locale(identifier: "pt_BR")
        return calendar
    }()
}
