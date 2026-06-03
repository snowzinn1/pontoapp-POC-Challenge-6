//
//  AirtableDTO.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 30/04/26.
//
import Foundation

struct AirtableStudentResponse: Decodable {
    let records: [StudentRecord]
    let offset: String?

    struct StudentRecord: Decodable {
        let id: String
        let fields: Fields

        struct Fields: Decodable {
            let name: String?
            let memoji: [Attachment]?

            enum CodingKeys: String, CodingKey {
                case name = "Name"
                case memoji = "Memoji"
            }
        }
    }

    struct Attachment: Decodable {
        let url: String?
    }
}

struct AirtableTimeLogResponse: Decodable {
    let records: [TimeLogRecord]
    let offset: String?

    struct TimeLogRecord: Decodable {
        let id: String
        let fields: Fields

        struct Fields: Decodable {
            let datetime: String?
            let status: String?
            let nameFromStudent: [String]?
            let recordIDFromStudent: [String]?

            enum CodingKeys: String, CodingKey {
                case datetime               = "datetime"
                case status                 = "Status"
                case nameFromStudent        = "Name (from student)"
                case recordIDFromStudent    = "Record ID (from student)"
            }
        }
    }
}

