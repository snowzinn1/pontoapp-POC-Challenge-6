//
//  AirtableModel.swift
//  pontoapp
//
//  Created by Joao Carlos Lima on 26/11/25.
//

import Foundation

struct AirtableResponse<Fields: Codable>: Codable {
    let records: [AirtableRecord<Fields>]
}

struct AirtableRecord<Fields: Codable>: Codable, Identifiable {
    let id: String
    let fields: Fields
    let createdTime: String
}

struct StudentRecord: Codable, Identifiable {
    let appleID: String
    let name: String
    let memojiURL: [String]
    let email: String
    
    var id: String {
        return appleID
    }
}

struct VacationDate: Codable{
    let title: String?
    let beginDate: String?
    let endDate: String?
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case beginDate = "Begin Date"
        case endDate = "End Date"
    }
}

struct EventFields: Codable {
    let name: String
    let date: String
    let icon: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case date = "Datetime"
        case icon = "Icon"
    }
    
    var eventDate: Date? {
        let fixedDateString = date.replacingOccurrences(of: ":000Z", with: ".000Z")
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let parsedDate = formatter.date(from: fixedDateString) {
            return parsedDate
        }
        
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: fixedDateString)
    }
    
    var formattedDate: String {
        guard let eventDate = eventDate else {
            print("Erro ao converter data:", date)
            return date
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEE, dd/MM - HH:mm"
        return formatter.string(from: eventDate)
    }
}
