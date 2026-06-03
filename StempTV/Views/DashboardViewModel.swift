//
//  DashboardViewModel.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 30/04/26.
//

import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var students: [Student] = []
    @Published var timeLogs: [TimeLogEntry] = []
    @Published var lastUpdated: Date? = nil
    @Published var isLoading: Bool = true

    private var pollingTask: Task<Void, Never>?

    struct StudentStatus: Identifiable {
        let id: String
        let name: String
        let memojiURL: URL?
        let status: AttendanceStatus
        let checkinTime: Date?
    }

    var studentStatuses: [StudentStatus] {
        students.map { student in
            let log = timeLogs
                .filter { $0.studentRecordID == student.id }
                .sorted { $0.datetime > $1.datetime }
                .first

            return StudentStatus(
                id: student.id,
                name: student.name,
                memojiURL: student.memojiURL,
                status: log?.status ?? .pending,
                checkinTime: log?.datetime
            )
        }
    }

    var countPresent: Int { studentStatuses.filter { $0.status == .present }.count }
    var countLated:   Int { studentStatuses.filter { $0.status == .lated   }.count }
    var countAbsent:  Int { studentStatuses.filter { $0.status == .absent  }.count }
    var countPending: Int { studentStatuses.filter { $0.status == .pending }.count }

    func start() async {
        await fetchStudents()
        await fetchTimeLogs()
        isLoading = false
        startPolling()
    }

    func stop() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    private func fetchStudents() async {
        do {
            students = try await AirtableService.shared.fetchStudents()
        } catch {
            print("Erro ao buscar students: \(error)")
        }
    }

    private func fetchTimeLogs() async {
        do {
            timeLogs = try await AirtableService.shared.fetchTodayTimeLogs()
            lastUpdated = Date()
        } catch {
            print("Erro ao buscar timelogs: \(error)")
        }
    }

    private func startPolling() {
        pollingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                guard !Task.isCancelled else { break }
                await fetchTimeLogs()
            }
        }
    }
}
