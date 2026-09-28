//
//  TimeService.swift
//  pontoapp
//
//  Created by Erick Costa on 27/04/26.
//

import Foundation

struct TimeAPIResponse: Codable {
    let unixtime: TimeInterval
    let timezone: String
}

class TimeService {
    static let shared = TimeService()
    private init() {}
    private var apiUrl = EnviromentVariables.timeZoneApi

    func fetchServerTime() async throws -> Date {
        guard let url = URL(string: apiUrl) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(TimeAPIResponse.self, from: data)
        return Date(timeIntervalSince1970: response.unixtime)
    }
    
//    func formatTime(_ response: TimeAPIResponse) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.timeZone = TimeZone(identifier: "America/Sao_Paulo")
//
//        if let date = formatter.date(from: response.dateTime) {
//            let iso = ISO8601DateFormatter()
//            iso.formatOptions = [.withInternetDateTime]
//            return iso.string(from: date)
//        }
//
//        return response.dateTime
//    }
}
