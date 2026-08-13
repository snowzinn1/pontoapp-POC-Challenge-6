//
//  RegistrationViewModel.swift
//  pontoapp
//
//  Created by Erick Costa on 19/01/26.
//

import Foundation
import CoreLocation
import SwiftUI

enum CheckInWindowResult {
    case onTime
    case late
    case outsideWindow
    case invalidDay
    case error
}

enum CheckInWindowState {
    case loading
    case open
    case closed
}

@MainActor
class RegistrationViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var showSuccess: Bool = false
    @Published var successMessage: String = ""
    @Published var calendarStatus: [Int: RecordStatus] = [:]
    @Published var selectedDayDetail: DayDetail? = nil
    @Published var isLoadingDayDetail: Bool = false
    @Published var daysWithEvents: [Int] = []
    @Published var checkInWindowState: CheckInWindowState = .loading
    @Published var showBluetoothAlert: Bool = false
        
    @Published var isLoadingCalendar: Bool = false
    @Published var currentCalendarDate: Date = Date()
    private var calendarTask: Task<Void, Never>?

    @Published var showOutsideAcademyAlert: Bool = false
    private var pendingCheckIn: (() -> Void)?
    private var isSyncing = false
    
    @Published private(set) var checkedInDay: Date? = nil
    private var serverOffset: TimeInterval = 0
    
    private let maxPlausibleOffset: TimeInterval = 10 //10 minutos

    private let openMinutes:   Int = 13 * 60 + 40   // 13:40
    private let closeMinutes:  Int = 18 * 60        // 18:00
    private let onTimeMinutes: Int = 14 * 60 + 20   // 14:20
    
    private var serverNow: Date {
        Date().addingTimeInterval(serverOffset)
    }
    
    var referenceDate: Date {
        Calendar.academy.startOfDay(for: serverNow)
    }
    
    private var referenceMinutes: Int {
        let calendar = Calendar.academy
        return calendar.component(.hour, from: serverNow) * 60
             + calendar.component(.minute, from: serverNow)
    }
    
    @AppStorage("pendingSync") private var pendingSync: Bool = false
    
    private var studentId: String {
        UserDefaults.standard.string(forKey: "studentId") ?? ""
    }
    
    private var studentName: String {
        UserDefaults.standard.string(forKey: "name") ?? ""
    }

    private let webService = WebService()
    private let dropboxService = DropboxService()
        
    func loadInitialData() {
        guard !studentId.isEmpty else { return }

        let today = Date.now

        if calendarStatus.isEmpty {
            getCalendarInfos(month: today.month, year: today.year)
            loadEvents(month: today.month, year: today.year)
        }
    }
    
    func loadCheckInWindowState() async {
        isSyncing = true
        checkInWindowState = .loading
        
        await VacationManager.shared.getVacationDates()
        
        if let serverTime = try? await TimeService.shared.fetchServerTime() {
            syncServerOffset(with: serverTime)
        }
        
        isSyncing = false
        recomputeWindowState()
    }
    
    func recomputeWindowState() {
        guard !isSyncing else { return }
        
        let minutes = referenceMinutes
        let isOpen = isValidDay(referenceDate)
                  && minutes >= openMinutes
                  && minutes <  closeMinutes

        let newState: CheckInWindowState = isOpen ? .open : .closed
        if checkInWindowState != newState {
            checkInWindowState = newState
        }
    }
    
    private func syncServerOffset(with serverDate: Date) {
        let candidate = serverDate.timeIntervalSince(Date())

        guard abs(candidate) < maxPlausibleOffset else {
            print("Hora errada entre bases: \(Int(candidate / 60)) min — offset ignorado")
            return
        }

        serverOffset = candidate
    }
    
    func validateWithServerTime() async -> CheckInWindowResult {
        guard let serverDate = try? await TimeService.shared.fetchServerTime() else {
            return .error
        }
        
        syncServerOffset(with: serverDate)
        
        await VacationManager.shared.getVacationDates()
        
        let calendar = Calendar.academy
        let day = calendar.startOfDay(for: serverDate)
        let totalMinutes = calendar.component(.hour, from: serverDate) * 60
                         + calendar.component(.minute, from: serverDate)
    
        guard isValidDay(day) else { return .invalidDay }
        guard totalMinutes >= openMinutes && totalMinutes < closeMinutes else { return .outsideWindow }

        return totalMinutes <= onTimeMinutes ? .onTime : .late
    }
    
    func isOnTime() -> Bool {
        return referenceMinutes <= onTimeMinutes
    }
    
    func isValidDay(_ date: Date) -> Bool{
        let calendar = Calendar.academy
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let key = String(format: "%02d-%02d", day, month)

        let isWeekend = calendar.isDateInWeekend(date)
        let isHoliday = HolidayManager.shared.getHolidays(for: year)[key] != nil
        let isVacation = VacationManager.shared.isVacation(date)
        
        return !isWeekend && !isHoliday && !isVacation
    }
    
    func nextValidDay(skippingToday: Bool = false) -> Date{
        let calendar = Calendar.academy
        var candidate = referenceDate
        
        if !skippingToday && isValidDay(candidate) && referenceMinutes < closeMinutes {
            return candidate
        }
        
        for _ in 1...90 {
            candidate = calendar.date(byAdding: .day, value: 1, to: candidate)!
            if isValidDay(candidate) {
                return candidate
            }
        }
        
        return candidate
    }
    
    func nextValidDayMessage(alreadyCheckedIn: Bool = false) -> String {
        let calendar = Calendar.academy
        
        if let vacation = VacationManager.shared.currentVacation(for: self.referenceDate){
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "pt_BR")
            fmt.dateFormat = "d 'de' MMMM"

            let fimFerias = fmt.string(from: vacation.end)
            let retorno = nextValidDay(skippingToday: alreadyCheckedIn)
            
            if calendar.isDate(retorno, inSameDayAs: vacation.end) ||
               retorno > vacation.end {
                let diaRetorno = fmt.string(from: retorno)
                return "Estamos em férias. A academy volta em \(diaRetorno) — bata seu ponto às 13:40."
            }
            
            return "Estamos em férias, até \(fimFerias)."
        }
        
        let next = nextValidDay(skippingToday: alreadyCheckedIn)
        
        if calendar.isDateInTomorrow(next) {
            return "Volte amanhã às 13:40 para bater seu ponto"
        }
        
        if calendar.isDateInToday(next) {
            return "Volte às 13:40 para bater seu ponto"
        }
        
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "pt_BR")
        fmt.dateFormat = "EEEE, d 'de' MMMM"
        
        return "Volte em \(fmt.string(from: next).capitalized) às 13:40 para bater seu ponto"
    }
    
    func hasAlreadyCheckedInToday() -> Bool {
        guard let day = checkedInDay else { return false }
        return Calendar.academy.isDate(day, inSameDayAs: referenceDate)
    }
    
    func loadEvents(month: Int, year: Int) {
        webService.fetchEventsForMonth(month: month, year: year) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let events):
                    self?.updateDaysWithEvents(from: events)
                case .failure(let error):
                    print("Erro ao buscar eventos: \(error.localizedDescription)")
                }
            }
        }
    }

    private func updateDaysWithEvents(from events: [EventDetail]) {
        self.daysWithEvents = events.map { event in
            Calendar.academy.component(.day, from: event.time)
        }
    }
    
    func fetchDayDetail(date: Date) {
        isLoadingDayDetail = true

        let calendar = Calendar.academy
        let year  = calendar.component(.year,  from: date)
        let month = calendar.component(.month, from: date)
        let day   = calendar.component(.day,   from: date)
        let key   = String(format: "%02d-%02d", day, month)
        let holidayName = HolidayManager.shared.getHolidays(for: year)[key]
        let vacation = VacationManager.shared.currentVacation(for: date)

        let group = DispatchGroup()
        var checkIn: CheckInDetail? = nil
        var events: [EventDetail]   = []

        group.enter()
        webService.fetchCheckInDetail(studentId: studentId, date: date) { result in
            if case .success(let detail) = result { checkIn = detail }
            group.leave()
        }

        group.enter()
        webService.fetchEventsForDay(date: date) { result in
            if case .success(let list) = result { events = list }
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            self?.isLoadingDayDetail = false
            self?.selectedDayDetail = DayDetail(
                date:    date,
                checkIn: checkIn,
                events:  events,
                holiday: holidayName,
                vacation: vacation
            )
        }
    }
    
    func requestCheckIn(studentId: String, status: RecordStatus, location: CLLocation?, justifyText: String? = nil, files: [URL]? = nil) {
        
        guard !hasAlreadyCheckedInToday() else { return }
        checkedInDay = referenceDate
                
        let isInsideAcademy = BeaconManager.shared.isInsideAcademy
        
        var isAtAcademy: RecordLocation
        
        switch isInsideAcademy {
            case true:
                isAtAcademy = .isAtAcademy
            case false:
                isAtAcademy = .isntAtAcademy
        }
        
        let checkInAction: () -> Void = { [weak self] in
            self?.registerEvent(
                studentId: studentId,
                status: status,
                location: location,
                justifyText: justifyText,
                files: files,
                isAtAcademy: isAtAcademy
            )
        }
 
        if isInsideAcademy {
            checkInAction()
        } else {
            pendingCheckIn = checkInAction
            DispatchQueue.main.async {
                self.showOutsideAcademyAlert = true
            }
        }
    }
 
    func confirmCheckInOutsideAcademy() {
        pendingCheckIn?()
        pendingCheckIn = nil
    }
 
    func cancelCheckIn() {
        pendingCheckIn = nil
        checkedInDay = nil
    }
    
    func registerEvent(studentId: String, status: RecordStatus, location: CLLocation?, justifyText: String? = nil, files: [URL]? = nil, isAtAcademy: RecordLocation){
        guard let location = location else{
            DispatchQueue.main.async {
                self.errorMessage = "Localização não encontrada"
                self.showError = true
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        if let files = files, !files.isEmpty {
            uploadFilesToDropbox(files: files){ [weak self] dropboxFiles in
                DispatchQueue.main.async {
                    self?.sendToAirtable(studentId: studentId, status: status, location: location, justifyText: justifyText, fileLinks: dropboxFiles, isAtAcademy: isAtAcademy)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.sendToAirtable(studentId: studentId, status: status, location: location, justifyText: justifyText, fileLinks: nil, isAtAcademy: isAtAcademy)
            }
        }
    }
    
    func uploadFilesToDropbox(files: [URL], completion: @escaping ([String]) -> Void){
        let group = DispatchGroup()
        var uploadedLinks: [String] = []
        
        for file in files {
            group.enter()
            let accessGranted = file.startAccessingSecurityScopedResource()
            
            do{
                let fileData = try Data(contentsOf: file)
                let fileName = file.lastPathComponent
                
                dropboxService.uploadFileAndGetLink(studentId: self.studentId, studentName: self.studentName, fileData: fileData, fileName: fileName){ link in
                    if let link = link{
                        uploadedLinks.append(link)
                    }
                    
                    if accessGranted{
                        file.stopAccessingSecurityScopedResource()
                    }
                    group.leave()
                }
            } catch {
                print("Erro ao ler arquivo local: \(error.localizedDescription)")
                if accessGranted {
                    file.stopAccessingSecurityScopedResource()
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            completion(uploadedLinks)
        }
    }
        
    func resetToCurrentMonth() {
        calendarStatus = [:]
        getCalendarInfos(month: currentCalendarDate.month, year: currentCalendarDate.year)
    }
    
    func getCalendarInfos(month: Int, year: Int) {
        isLoadingCalendar = true
        daysWithEvents = []
        loadEvents(month: month, year: year)
        
        webService.fetchCalendar(studentId: studentId, month: month, year: year) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.isLoadingCalendar = false
                
                switch result {
                case .success(let status):
                    self.calendarStatus = status
                    
                    let today = self.referenceDate
                    if month == today.month && year == today.year, status[today.day] != nil {
                        self.checkedInDay = today
                    }
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                }
            }
        }
    }
    
    func sendToAirtable(studentId: String, status: RecordStatus, location: CLLocation, justifyText: String?, fileLinks: [String]?, isAtAcademy: RecordLocation){
        
        let record = RecordModel(
            studentId: studentId,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            status: status,
            filesURL: fileLinks,
            justifyText: justifyText,
            isAtAcademy: isAtAcademy
        )
        
        webService.postRecord(record: record) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success:
                    switch status {
                        case .present:
                            let current = UserDefaults.standard.integer(forKey: "presences")
                            UserDefaults.standard.set(current + 1, forKey: "presences")
                        case .absent:
                            let current = UserDefaults.standard.integer(forKey: "absences")
                            UserDefaults.standard.set(current + 1, forKey: "absences")
                        case .lated:
                            let current = UserDefaults.standard.integer(forKey: "delays")
                            UserDefaults.standard.set(current + 1, forKey: "delays")
                        default:
                            break
                    }
                    
                    self?.pendingSync = true
                    self?.successMessage = (status == .absent) ? "Falta justificada com sucesso!" : "Presença registrada com sucesso!"
                    self?.showSuccess = true
                    self?.resetToCurrentMonth()
                    
                    self?.checkedInDay = self?.referenceDate
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.showError = true
                }
            }
        }
    }
}
