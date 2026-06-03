//
//  TimelogEntry.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 30/04/26.
//
import Foundation

struct TimeLogEntry: Identifiable {
    let id: String
    let studentRecordID: String
    let studentName: String
    let datetime: Date
    let status: AttendanceStatus
}

enum AttendanceStatus: String {
    case present = "Present"
    case lated   = "Lated"
    case absent  = "Absent"
    case pending
}
