//
//  DateExtension.swift
//  pontoapp
//
//  Created by Erick Costa on 06/12/25.
//

import Foundation

struct DateValue: Identifiable{
    var id = UUID()
    var day: Int
    var date: Date
    var isDisabledDay: Bool = false
    var holiday: String = ""
}

extension Date {
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
        
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    static func classDurationInYears() -> String {
        let currentYear = Calendar.current.component(.year, from: Date())
        let evenYear = currentYear % 2
        
        return evenYear == 0 ? "\(currentYear) - \(currentYear + 1)" : "\(currentYear - 1) - \(currentYear)"
    }
    
    func formatMonthAndYear() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMM yyyy"
        
        return formatter.string(from: self)
    }
    
    static func getCurrentMinutes() -> Int{
        let time = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        return hour * 60 + minute
    }

    static func dateTimeNow() -> String {
        let formatterDate = ISO8601DateFormatter()
        
        formatterDate.formatOptions = [.withInternetDateTime]
        
        return formatterDate.string(from: Date.now)
    }
    
    @MainActor
    func daysOfMonth() -> [DateValue] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        
        let yearHolidays = HolidayManager.shared.getHolidays(for: year)
        
        guard let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: self)),
                let range = calendar.range(of: .day, in: .month, for: currentMonth) else {
            return []
        }
        
        let daysOfWeek = calendar.component(.weekday, from: currentMonth) - 1
        var days: [DateValue] = []
        
        for _ in 0..<daysOfWeek {
            days.append(DateValue(day: -1, date: Date()))
        }
        
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: currentMonth) {
                // Criamos a chave "DD-MM" para bater com o dicionário
                let dayInt = calendar.component(.day, from: date)
                let monthInt = calendar.component(.month, from: date)
                let key = String(format: "%02d-%02d", dayInt, monthInt)
                
                let holidayName = yearHolidays[key] ?? ""
                let isHoliday = !holidayName.isEmpty
                let isWeekend = calendar.isDateInWeekend(date)
                let vacationTitle = VacationManager.shared.vacationTitle(for: date)
                
                days.append(DateValue(
                    day: day,
                    date: date,
                    isDisabledDay: isHoliday || isWeekend || (vacationTitle != nil),
                    holiday: holidayName.isEmpty ? (vacationTitle ?? "") : holidayName
                ))
            }
        }
        
        return days
    }
}
