//
//  Config.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 30/04/26.
//

import Foundation

enum Config {
    static let airtableToken: String = {
        Bundle.main.infoDictionary?["AIRTABLE_TOKEN"] as? String ?? ""
    }()

    static let pontoAPIURL: String = {
        Bundle.main.infoDictionary?["AIRTABLE_PONTO_API_URL"] as? String ?? ""
    }()

    static let studentsAPIURL: String = {
        Bundle.main.infoDictionary?["AIRTABLE_STUDENTS_API_URL"] as? String ?? ""
    }()
}
