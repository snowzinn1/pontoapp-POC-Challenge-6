//
//  EnviromentVariables.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 25/03/26.
//

import Foundation

struct EnviromentVariables {
    static var dropboxApiKey: String {
        return Bundle.main.object(forInfoDictionaryKey: "DropboxKey") as? String ?? ""
    }
    
    static var dropboxAppSecret: String {
        return Bundle.main.object(forInfoDictionaryKey: "DropboxAppSecret") as? String ?? ""
    }
    
    static var dropboxAcessToken: String {
        return Bundle.main.object(forInfoDictionaryKey: "DropboxAcessToken") as? String ?? ""
    }
    
    static var dropboxRefreshToken: String {
        return Bundle.main.object(forInfoDictionaryKey: "DropboxRefreshToken") as? String ?? ""
    }
    
    static var urlStudentsTable: String {
        return Bundle.main.object(forInfoDictionaryKey: "AirtableStudentsApi") as? String ?? ""
    }
    
    static var urlVacationDates: String {
        return Bundle.main.object(forInfoDictionaryKey: "AirtableVacationDates") as? String ?? ""
    }
    
    static var urlTimelogTable: String {
        return Bundle.main.object(forInfoDictionaryKey: "AirtablePontoApi") as? String ?? ""
    }
    
    static var urlEventsTable: String {
        return Bundle.main.object(forInfoDictionaryKey: "AirtableEventsApi") as? String ?? ""
    }
    
    static var urlSummaryTable: String {
        return Bundle.main.object(forInfoDictionaryKey: "AirtableSummaryApi") as? String ?? ""
    }
    
    static var airtableApiToken: String {
        return Bundle.main.object(forInfoDictionaryKey: "AirtableToken") as? String ?? ""
    }
    
    static var timeZoneApi: String {
        return Bundle.main.object(forInfoDictionaryKey: "TimeZoneApi") as? String ?? ""
    }
}
