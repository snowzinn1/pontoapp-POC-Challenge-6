//
//  HolidayManager.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 24/03/26.
//

import Foundation

class HolidayManager {
    static let shared = HolidayManager()
    
    private var cachedYear: Int?
    private var cachedHolidays: [String: String] = [:]
    
    private init() {}

    func getHolidays(for year: Int) -> [String: String] {
        if let cachedYear = cachedYear, cachedYear == year {
            return cachedHolidays
        }
        
        var holidays: [String: String] = [:]
        let calendar = Calendar.academy
        
        let baseHolidays = getBaseHolidays(for: year)
        
        for holiday in baseHolidays {
            let key = dateToKey(holiday.date)
            holidays[key] = holiday.name
        }
        
        for holiday in baseHolidays {
            let date = holiday.date
            let name = holiday.name
            let weekday = calendar.component(.weekday, from: date)
            var bridgeDate: Date?
            
            if weekday == 3 {
                bridgeDate = calendar.date(byAdding: .day, value: -1, to: date)
            } else if weekday == 5 {
                bridgeDate = calendar.date(byAdding: .day, value: 1, to: date)
            }
            
            if let bridge = bridgeDate {
                let bridgeKey = dateToKey(bridge)
                if holidays[bridgeKey] == nil {
                    holidays[bridgeKey] = "Emenda (\(name))"
                }
            }
        }
        
        self.cachedYear = year
        self.cachedHolidays = holidays
        
        return holidays
    }
    
    private func getBaseHolidays(for year: Int) -> [(date: Date, name: String)]{
        var base: [(date: Date, name: String)] = []
        let calendar = Calendar.academy
        
        let fixedHolidays = [
            (1, 1, "Ano Novo"),
            (1, 25, "Aniversário de São Paulo"),
            (4, 21, "Tiradentes"),
            (5, 1, "Dia do Trabalho"),
            (7, 9, "Revolução Constitucionalista"),
            (9, 7, "Independência"),
            (10, 12, "Nossa Senhora Aparecida"),
            (11, 2, "Finados"),
            (11, 15, "Proclamação da República"),
            (11, 20, "Consciência Negra"),
            (12, 25, "Natal")
        ]

        for fixed in fixedHolidays {
            if let day = calendar.date(from: DateComponents(year: year, month: fixed.0, day: fixed.1)) {
                base.append((day, fixed.2))
            }
        }
        
        base.append(contentsOf: calculateMovableHolidays(for: year))
        
        return base
    }
    
    private func dateToKey(_ date: Date) -> String {
        let calendar = Calendar.academy
        let d = calendar.component(.day, from: date)
        let m = calendar.component(.month, from: date)
        return String(format: "%02d-%02d", d, m)
    }
    
    private func calculateMovableHolidays(for year: Int) -> [(date: Date, name: String)] {
        // Algoritmo de Butcher-Meeus (Páscoa)
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = ((h + l - 7 * m + 114) % 31) + 1
        
        let comps = DateComponents(year: year, month: month, day: day)
        let calendar = Calendar.academy
        guard let easter = calendar.date(from: comps) else { return [] }
        
        let carnivalMon = calendar.date(byAdding: .day, value: -48, to: easter)!
        let carnivalTue = calendar.date(byAdding: .day, value: -47, to: easter)!
        let goodFriday  = calendar.date(byAdding: .day, value: -2, to: easter)!
        let corpus      = calendar.date(byAdding: .day, value: 60, to: easter)!
        
        return [
            (easter, "Páscoa"),
            (carnivalMon, "Carnaval"),
            (carnivalTue, "Carnaval"),
            (goodFriday, "Sexta-feira Santa"),
            (corpus, "Corpus Christi")
        ]
    }
}
