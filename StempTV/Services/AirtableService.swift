//
//  AirtableService.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 30/04/26.
//

import Foundation

final class AirtableService {
    static let shared = AirtableService()
    private init() {}
    
    private var headers: [String: String] {
        ["Authorization": "Bearer \(Config.airtableToken)"]
    }
    
    // MARK: - Students
    func fetchStudents() async throws -> [Student] {
        var allStudents: [Student] = []
        var offset: String? = nil
        
        repeat {
            var urlStr = Config.studentsAPIURL + "?pageSize=100"
            if let offset { urlStr += "&offset=\(offset)" }
            
            var request = URLRequest(url: URL(string: urlStr)!)
            headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoded = try JSONDecoder().decode(AirtableStudentResponse.self, from: data)
            
            let students = decoded.records.compactMap { record -> Student? in
                guard let name = record.fields.name else { return nil }
                let memojiURL = record.fields.memoji?.first?.url.flatMap { URL(string: $0) }
                return Student(id: record.id, name: name, memojiURL: memojiURL)
            }
            
            allStudents.append(contentsOf: students)
            offset = decoded.offset
        } while offset != nil
        
        return allStudents.sorted { $0.name < $1.name }
    }
    
    // MARK: - TimeLog (hoje)
    func fetchTodayTimeLogs() async throws -> [TimeLogEntry] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC") // Airtable armazena em UTC
        let todayStr = dateFormatter.string(from: Date()) // "2026-05-06"

        let formula = "DATESTR({Created Time}) = '\(todayStr)'"
        let encoded = formula.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let sortField = "sort%5B0%5D%5Bfield%5D=datetime&sort%5B0%5D%5Bdirection%5D=asc"
        let urlStr = Config.pontoAPIURL + "?filterByFormula=\(encoded)&\(sortField)"
        
        print("URL:", urlStr)
        
        var request = URLRequest(url: URL(string: urlStr)!)
        headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        print("RESPOSTA DA API:", String(data: data, encoding: .utf8) ?? "nil")
        
        let decoded = try JSONDecoder().decode(AirtableTimeLogResponse.self, from: data)
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return decoded.records.compactMap { record -> TimeLogEntry? in
            guard
                let dateStr = record.fields.datetime,
                let date    = formatter.date(from: dateStr),
                let name    = record.fields.nameFromStudent?.first,
                let rid     = record.fields.recordIDFromStudent?.first
            else { return nil }
            
            let status = AttendanceStatus(rawValue: record.fields.status ?? "") ?? .pending
            
            return TimeLogEntry(
                id: record.id,
                studentRecordID: rid,
                studentName: name,
                datetime: date,
                status: status
            )
        }
    }
}

