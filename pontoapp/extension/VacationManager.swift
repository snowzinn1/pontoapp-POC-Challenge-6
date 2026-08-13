//
//  VacationManager.swift
//  pontoapp
//
//  Created by Erick Costa on 19/06/26.
//

import Foundation

struct VacationInterval {
    let title: String
    let start: Date
    let end: Date
}

@MainActor
class VacationManager: ObservableObject {
    static var shared = VacationManager()
    private var webService = WebService()
    
    @Published private(set) var intervals: [VacationInterval] = []
    private var loaded = false
    
    func getVacationDates(_ forceLoad: Bool = false) async {
        if loaded && !forceLoad { return }
        
        do {
            let dates = try await webService.fetchVacationDates()
            let calendar = Calendar.academy
            
            intervals = dates.compactMap{ result in
                guard let title = result.title,
                     let beginStr = result.beginDate,
                     let endStr = result.endDate,
                     let beginDate = parse(beginStr),
                     let endDate = parse(endStr) else {
                   return nil
               }
                
                return VacationInterval(
                    title: title,
                    start: calendar.startOfDay(for: beginDate),
                    end: calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) ?? endDate
                )
            }
            
            loaded = true
        } catch {
            print("ERRO NA CHAMADA DA API: \(error.localizedDescription)")
        }
    }
    
    func currentVacation(for date: Date) -> VacationInterval? {
        intervals.first { date >= $0.start && date <= $0.end }
    }
    
    func vacationTitle(for date: Date) -> String? {
        intervals.first { date >= $0.start && date <= $0.end }?.title
    }

    func isVacation(_ date: Date) -> Bool {
        vacationTitle(for: date) != nil
    }
    
    private func parse(_ date: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "America/Sao_Paulo")
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let dateFormatted = formatter.date(from: date) {
            return dateFormatted
        }
        
        return ISO8601DateFormatter().date(from: date)
    }
}
