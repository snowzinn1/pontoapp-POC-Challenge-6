//
//  DayDetailService.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 25/03/26.
//

import Foundation

struct AirtableTimelogDetailResponse: Decodable{
    let records: [TimelogDetailRecord]
}

struct TimelogDetailRecord: Decodable{
    let fields: TimelogDetailFields
}

struct TimelogDetailFields: Decodable{
    let createdTime: String
    let status: String
    let justifyText: String?
    
    enum CodingKeys: String, CodingKey {
        case createdTime = "Created Time"
        case status = "Status"
        case justifyText = "Justify"
    }
}

struct AirtableEventDetailResponse: Decodable{
    let records: [EventDetailRecord]
}

struct EventDetailRecord: Decodable{
    let id: String
    let fields: EventDetailFields
}

struct AirtableAttachment: Codable {
    let id: String
    let url: String
    let filename: String
}

struct EventDetailFields: Decodable{
    let recordId: String
    let name: String
    let typeEvent: [String]
    let datetime: String
    let icon: [String]
    let colorHex: [String]
    let description: String?
    let supportMaterial: [AirtableAttachment]?
    let deliverableLinks: String?

    enum CodingKeys: String, CodingKey {
        case recordId = "Record ID"
        case name     = "Name"
        case typeEvent = "Type Event"
        case datetime = "Datetime"
        case icon     = "Icon"
        case colorHex = "Color"
        case description     = "Descrição"
        case supportMaterial = "Material de Apoio"
        case deliverableLinks   = "Deliverable Links"
    }
}


extension WebService{
    func fetchCheckInDetail(
        studentId: String,
        date: Date,
        completion: @escaping (Result<CheckInDetail?, Error>) -> Void
    ){
        let calendar = Calendar.academy
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        guard
            let startOfDay = calendar.date(from: DateComponents(year: year, month: month, day: day)),
            let endOfDay   = calendar.date(byAdding: .day, value: 1, to: startOfDay)
        else {
           completion(.success(nil))
           return
        }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let startStr = formatter.string(from: startOfDay)
        let endStr   = formatter.string(from: endOfDay)

        let formula = "AND(SEARCH('\(studentId)', {Record ID (from student)} & ''), IS_AFTER({Created Time}, '\(startStr)'), IS_BEFORE({Created Time}, '\(endStr)'))"

        var components = URLComponents(string: self.urlTimelogTable)
        components?.queryItems = [URLQueryItem(name: "filterByFormula", value: formula)]
        
        guard let url = components?.url else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data, let self = self else { completion(.success(nil)); return }

            do {
                let response = try JSONDecoder().decode(AirtableTimelogDetailResponse.self, from: data)
                guard let record = response.records.first else {
                    completion(.success(nil))
                    return
                }

                if let date = self.isoFormatter.date(from: record.fields.createdTime) {
                    let timeFmt = DateFormatter()
                    timeFmt.dateFormat = "HH:mm"
                    let timeStr = timeFmt.string(from: date)
                    let status  = RecordStatus(rawValue: record.fields.status) ?? .present
                    completion(.success(CheckInDetail(time: timeStr, status: status, justifyText: record.fields.justifyText)))
                } else {
                    completion(.success(nil))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchEventsForDay(
            date: Date,
            completion: @escaping (Result<[EventDetail], Error>) -> Void
        ) {
            let calendar = Calendar.academy
            let year  = calendar.component(.year,  from: date)
            let month = calendar.component(.month, from: date)
            let day   = calendar.component(.day,   from: date)

            guard
                let startOfDay = calendar.date(from: DateComponents(year: year, month: month, day: day)),
                let endOfDay   = calendar.date(byAdding: .day, value: 1, to: startOfDay)
            else {
                completion(.success([]))
                return
            }

            let fmt = ISO8601DateFormatter()
            fmt.formatOptions = [.withInternetDateTime]
            let startStr = fmt.string(from: startOfDay)
            let endStr   = fmt.string(from: endOfDay)

            let formula = "AND(IS_AFTER({Datetime}, '\(startStr)'), IS_BEFORE({Datetime}, '\(endStr)'))"

            var components = URLComponents(string: self.urlEventsTable)
            components?.queryItems = [URLQueryItem(name: "filterByFormula", value: formula)]

            guard let url = components?.url else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error { completion(.failure(error)); return }
                guard let data = data else { completion(.success([])); return }

                do {
                    let response = try JSONDecoder().decode(AirtableEventDetailResponse.self, from: data)

                    let timeFmt = DateFormatter()
                    timeFmt.dateFormat = "HH:mm"
                    let isoFmt = ISO8601DateFormatter()
                    isoFmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

                    let events: [EventDetail] = response.records.compactMap { record in
                        // O Airtable retorna datetime como "2026-01-28T17:39:00.000Z"
                        guard let eventDate = isoFmt.date(from: record.fields.datetime) else { return nil }
                        return EventDetail(
                            id:       record.id,
                            name:     record.fields.name,
                            typeEvent: record.fields.typeEvent.first!,
                            time:     eventDate,
                            icon:     record.fields.icon.first!,
                            colorHex: record.fields.colorHex.first!,
                            description:     record.fields.description,
                            supportMaterial: record.fields.supportMaterial,
                            deliverableLinks:   record.fields.deliverableLinks
                        )
                    }

                    completion(.success(events))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }
}

