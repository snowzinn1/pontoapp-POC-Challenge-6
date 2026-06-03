//
//  DashboardViewModel.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 30/04/26.
//

import Foundation

class DashboardMock {
    var viewModel = DashboardViewModel()
    
    init(){
        viewModel.students = [
            Student(id: "1",  name: "Ana Carolina",     memojiURL: nil),
            Student(id: "2",  name: "Beatriz Lima",     memojiURL: nil),
            Student(id: "3",  name: "Bruno Rodrigues",  memojiURL: nil),
            Student(id: "4",  name: "Carlos Mendes",    memojiURL: nil),
            Student(id: "5",  name: "Daniel Pereira",   memojiURL: nil),
            Student(id: "6",  name: "Eduardo Silva",    memojiURL: nil),
            Student(id: "7",  name: "Fernanda Alves",   memojiURL: nil),
            Student(id: "8",  name: "Gabriel Torres",   memojiURL: nil),
            Student(id: "9",  name: "Helena Wagner",    memojiURL: nil),
            Student(id: "10", name: "Igor Viana",       memojiURL: nil),
            Student(id: "11", name: "Joana Ferreira",   memojiURL: nil),
            Student(id: "12", name: "João Lima",        memojiURL: nil),
            Student(id: "13", name: "Karina Souza",     memojiURL: nil),
            Student(id: "14", name: "Lucas Oliveira",   memojiURL: nil),
            Student(id: "15", name: "Mariana Costa",    memojiURL: nil),
            Student(id: "16", name: "Nicolas Martins",  memojiURL: nil),
            Student(id: "17", name: "Olivia Ramos",     memojiURL: nil),
            Student(id: "18", name: "Pedro Henrique",   memojiURL: nil),
            Student(id: "19", name: "Quésia Almeida",   memojiURL: nil),
            Student(id: "20", name: "Rafael Barbosa",   memojiURL: nil),
            Student(id: "21", name: "Sofia Cardoso",    memojiURL: nil),
            Student(id: "22", name: "Thiago Nunes",     memojiURL: nil),
            Student(id: "23", name: "Ursula Ribeiro",   memojiURL: nil),
            Student(id: "24", name: "Vinícius Castro",  memojiURL: nil),
            Student(id: "25", name: "William Tavares",  memojiURL: nil),
            Student(id: "26", name: "Xavier Moreira",   memojiURL: nil),
            Student(id: "27", name: "Yasmin Duarte",    memojiURL: nil),
            Student(id: "28", name: "Zeca Pinheiro",    memojiURL: nil),
            Student(id: "29", name: "Amanda Rocha",     memojiURL: nil),
            Student(id: "30", name: "Bernardo Faria",   memojiURL: nil)
        ]
        
        // Mock timelogs — mix de presentes, atrasados e ausentes
        // Os que não tiverem registro aqui aparecem como "pending"
        let now = Date()
        let calendar = Calendar.current
        
        func time(hour: Int, minute: Int) -> Date {
            calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) ?? now
        }
        
        viewModel.timeLogs = [
            // Presentes (chegaram no horário)
            TimeLogEntry(id: "t1",  studentRecordID: "1",  studentName: "Ana Carolina",    datetime: time(hour: 13, minute: 35), status: .present),
            TimeLogEntry(id: "t2",  studentRecordID: "4",  studentName: "Carlos Mendes",   datetime: time(hour: 13, minute: 38), status: .present),
            TimeLogEntry(id: "t3",  studentRecordID: "5",  studentName: "Daniel Pereira",  datetime: time(hour: 13, minute: 32), status: .present),
            TimeLogEntry(id: "t4",  studentRecordID: "7",  studentName: "Fernanda Alves",  datetime: time(hour: 13, minute: 39), status: .present),
            TimeLogEntry(id: "t5",  studentRecordID: "8",  studentName: "Gabriel Torres",  datetime: time(hour: 13, minute: 30), status: .present),
            TimeLogEntry(id: "t6",  studentRecordID: "10", studentName: "Igor Viana",      datetime: time(hour: 13, minute: 36), status: .present),
            TimeLogEntry(id: "t7",  studentRecordID: "12", studentName: "João Lima",       datetime: time(hour: 13, minute: 33), status: .present),
            TimeLogEntry(id: "t8",  studentRecordID: "14", studentName: "Lucas Oliveira",  datetime: time(hour: 13, minute: 37), status: .present),
            TimeLogEntry(id: "t9",  studentRecordID: "15", studentName: "Mariana Costa",   datetime: time(hour: 13, minute: 31), status: .present),
            TimeLogEntry(id: "t10", studentRecordID: "17", studentName: "Olivia Ramos",    datetime: time(hour: 13, minute: 40), status: .present),
            TimeLogEntry(id: "t11", studentRecordID: "20", studentName: "Rafael Barbosa",  datetime: time(hour: 13, minute: 34), status: .present),
            TimeLogEntry(id: "t12", studentRecordID: "21", studentName: "Sofia Cardoso",   datetime: time(hour: 13, minute: 36), status: .present),
            TimeLogEntry(id: "t13", studentRecordID: "24", studentName: "Vinícius Castro", datetime: time(hour: 13, minute: 38), status: .present),
            TimeLogEntry(id: "t14", studentRecordID: "27", studentName: "Yasmin Duarte",   datetime: time(hour: 13, minute: 35), status: .present),
            TimeLogEntry(id: "t15", studentRecordID: "29", studentName: "Amanda Rocha",    datetime: time(hour: 13, minute: 32), status: .present),
            
            // Atrasados
            TimeLogEntry(id: "t16", studentRecordID: "2",  studentName: "Beatriz Lima",    datetime: time(hour: 14, minute: 12), status: .lated),
            TimeLogEntry(id: "t17", studentRecordID: "9",  studentName: "Helena Wagner",   datetime: time(hour: 14, minute: 25), status: .lated),
            TimeLogEntry(id: "t18", studentRecordID: "16", studentName: "Nicolas Martins", datetime: time(hour: 14, minute: 8),  status: .lated),
            TimeLogEntry(id: "t19", studentRecordID: "22", studentName: "Thiago Nunes",    datetime: time(hour: 14, minute: 33), status: .lated),
            TimeLogEntry(id: "t20", studentRecordID: "26", studentName: "Xavier Moreira",  datetime: time(hour: 14, minute: 18), status: .lated),
            
            // Ausentes
            TimeLogEntry(id: "t21", studentRecordID: "3",  studentName: "Bruno Rodrigues", datetime: now, status: .absent),
            TimeLogEntry(id: "t22", studentRecordID: "11", studentName: "Joana Ferreira",  datetime: now, status: .absent),
            TimeLogEntry(id: "t23", studentRecordID: "19", studentName: "Quésia Almeida",  datetime: now, status: .absent),
            TimeLogEntry(id: "t24", studentRecordID: "25", studentName: "William Tavares", datetime: now, status: .absent),
            
            // Os demais (6, 13, 18, 23, 28, 30) ficam como pending — sem registro
        ]
        
        viewModel.lastUpdated = Date()
        viewModel.isLoading = false
    }
}
