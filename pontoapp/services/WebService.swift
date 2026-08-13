//
//  WebService.swift
//  pontoapp
//
//  Created by Joao Carlos Lima on 11/11/24.
//

import Foundation

class WebService: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    private var calendarTask: URLSessionDataTask?
    
    public let apiKey = EnviromentVariables.airtableApiToken
    public let urlStudentsTable = EnviromentVariables.urlStudentsTable
    public let urlTimelogTable = EnviromentVariables.urlTimelogTable
    public let urlEventsTable = EnviromentVariables.urlEventsTable
    public let urlSummaryTable = EnviromentVariables.urlSummaryTable
    public let urlVacationDates = EnviromentVariables.urlVacationDates
    
    func authenticateStudent(appleID: String, name: String, email: String, completion: @escaping(Result<String, Error>) -> Void) {
        print("Iniciando a busca:")
        print("ESTUDANTE - \(name)")
        print("APPLEID - \(appleID)")
        print("EMAIL - \(email)")
        
        fetchStudentExistence(appleUserID: appleID, appleEmail: email) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let id):
                if let id = id {
                    print("Estudante já cadastrado. ID: \(id)")
                    completion(.success(id))
                } else {
                    let studentRecord = StudentRecord(appleID: appleID, name: name, memojiURL: [], email: email)
                    self.postNewStudent(studentRecord: studentRecord) { result in
                        switch result {
                        case .success(let newId):
                            print("Estudante cadastrado com sucesso. ID: \(newId)")
                            completion(.success(newId))
                        case .failure(let error):
                            print("Erro ao cadastrar estudante: \(error)")
                            completion(.failure(error))
                        }
                    }
                    
                }
            case .failure(let error):
                print("Erro ao buscar estudante: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    func updateStudentAppleID(recordId: String, appleID: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "\(self.urlStudentsTable)/\(recordId)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = ["fields": ["AppleID": appleID]]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error { completion(.failure(error)); return }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "APIError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Erro ao atualizar AppleID"])))
                return
            }
            completion(.success(true))
        }.resume()
    }
    
    func fetchStudentExistence(appleUserID: String, appleEmail: String, completion: @escaping (Result<String?, Error>) -> Void) {
        guard var components = URLComponents(string: self.urlStudentsTable) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL base inválida"])))
            return
        }
        
        let formula = "OR({AppleID} = '\(appleUserID)', {Email} = '\(appleEmail)')"
        components.queryItems = [
            URLQueryItem(name: "filterByFormula", value: formula)
        ]
        
        guard let url = components.url else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Falha ao montar parâmetros da URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue( "Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Resposta inválida do servidor"])))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let data = data, let jsonErro = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print("ERRO DO AIRTABLE: \(jsonErro)")
                }
                
                let erro = NSError(
                    domain: "APIError",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Erro no servidor. Status \(httpResponse.statusCode)"]
                )
                
                completion(.failure(erro))
                return
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let records = json["records"] as? [[String: Any]] {
                        
                        if let firstRecord = records.first, let recordId = firstRecord["id"] as? String {
                            
                            let fields = firstRecord["fields"] as? [String: Any]
                            let savedAppleID = fields?["AppleID"] as? String ?? ""

                            if savedAppleID.isEmpty {
                                self.updateStudentAppleID(recordId: recordId, appleID: appleUserID) { _ in }
                            }

                            completion(.success(recordId))
                        } else {
                            completion(.success(nil))
                        }
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Falha ao ler JSON do Airtable"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()

    }
    
    func updateStudentMemoji(recordId: String, memojiPublicUrl: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        guard let url = URL(string: "\(self.urlStudentsTable)/\(recordId)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let fields: [String: Any] = [
            "Memoji": [
                ["url": memojiPublicUrl]
            ]
        ]
        
        let body: [String: Any] = [
            "fields": fields,
            "typecast": true
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                if let data = data, let errorBody = String(data: data, encoding: .utf8) {
                    print("Erro Airtable (\((response as? HTTPURLResponse)?.statusCode ?? -1)): \(errorBody)")
                }
                completion(.failure(NSError(domain: "APIError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Erro ao atualizar"])))
                return
            }
            
            completion(.success(true))
        }.resume()
    }
    
    func postNewStudent(studentRecord: StudentRecord, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: self.urlStudentsTable) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue( "Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let fields: [String: Any] = [
            "AppleID": studentRecord.appleID,
            "Name": studentRecord.name,
            "Email": studentRecord.email
        ]
        
        let body: [String: Any] = [
            "fields": fields,
            "typecast": true
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Resposta inválida do servidor"])))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let data = data, let jsonErro = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print("ERRO DO AIRTABLE: \(jsonErro)")
                }
                
                let erro = NSError(
                    domain: "APIError",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Erro no servidor. Status \(httpResponse.statusCode)"]
                )
                
                completion(.failure(erro))
                return
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let newRecordId = json["id"] as? String {
                        completion(.success(newRecordId))
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Falha ao ler ID criado no JSON"])))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
    
    func postRecord(record: RecordModel, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: self.urlTimelogTable) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        var fields: [String: Any] = [
            "latitude": record.latitude,
            "longitude": record.longitude,
            "student": [record.studentId],
            "Status": record.status.rawValue,
            "IsAtAcademy": record.isAtAcademy.rawValue
        ]
        
        if let justifyText = record.justifyText, !justifyText.isEmpty {
            fields["Justify"] = justifyText
        }
        
        if let files = record.filesURL, !files.isEmpty {
            let attachmentsArray = files.map { url in
                return ["url": url]
            }
            
            fields["Attach"] = attachmentsArray
        }
        
        let body: [String: Any] = [
            "fields": fields,
            "typecast": true
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Resposta inválida do servidor"])))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if let data = data, let jsonErro = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print("ERRO DO AIRTABLE: \(jsonErro)")
                }
                
                let erro = NSError(
                    domain: "APIError",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Erro no servidor. Status \(httpResponse.statusCode)"]
                )
                
                completion(.failure(erro))
                return
            }
            
            completion(.success(true))
        }.resume()
    }
    
    func fetchCalendar(studentId: String, month: Int, year: Int, completion: @escaping (Result<[Int: RecordStatus], Error>) -> Void) {
        calendarTask?.cancel()
        
        var components = URLComponents(string: self.urlTimelogTable)
        
        components?.queryItems = [
            URLQueryItem(name: "filterByFormula", value: "AND(SEARCH('\(studentId)', {Record ID (from student)} & ''), MONTH({Created Time}) = \(month), YEAR({Created Time}) = \(year))")
        ]
        
        guard let url = components?.url else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let urlError = error as? URLError, urlError.code == .cancelled { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(AirtableCalendarResponse.self, from: data)
                
                var calendarInfos: [Int: RecordStatus] = [:]
                
                for record in decodedResponse.records {
                    if let date = self.isoFormatter.date(from: record.fields.createdTime) {
                        let day = Calendar.academy.component(.day, from: date)
                        let status = RecordStatus(rawValue: record.fields.status)
                        
                        calendarInfos[day] = status
                    }
                }
                
                completion(.success(calendarInfos))
            } catch {
                print("Erro ao decodificar: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func fetchEvents(completion: @escaping (Result<[EventDetail], Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        var components = URLComponents(string: self.urlEventsTable)
        
        let filterFormula = "{Datetime} >= TODAY()"
        
        components?.queryItems = [
            URLQueryItem(name: "filterByFormula", value: filterFormula),
            URLQueryItem(name: "sort[0][field]", value: "Datetime"),
            URLQueryItem(name: "sort[0][direction]", value: "asc")
        ]
        
        guard let url = components?.url else {
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Dados não encontrados"])
                    self?.errorMessage = "Dados não encontrados"
                    completion(.failure(error))
                    return
                }
                
                do {
                    let response = try JSONDecoder().decode(AirtableEventDetailResponse.self, from: data)

                    print(response)
                    let timeFmt = DateFormatter()
                    timeFmt.dateFormat = "HH:mm"
                    let isoFmt = ISO8601DateFormatter()
                    isoFmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

                    let events: [EventDetail] = response.records.compactMap { record in
                        guard let eventDate = isoFmt.date(from: record.fields.datetime) else { return nil }
                        
                        return EventDetail(
                            id: record.id,
                            name: record.fields.name,
                            typeEvent: record.fields.typeEvent.first!,
                            time: eventDate,
                            icon: record.fields.icon.first!,
                            colorHex: record.fields.colorHex.first!,
                            description: record.fields.description,
                            supportMaterial: record.fields.supportMaterial,
                            deliverableLinks: record.fields.deliverableLinks
                        )
                    }

                    completion(.success(events))
                } catch {
                    self?.errorMessage = "Erro ao processar dados"
                    completion(.failure(error))
                }

            }
        }.resume()
    }
    
    func fetchEventsForMonth(month: Int, year: Int, completion: @escaping (Result<[EventDetail], Error>) -> Void) {
        let calendar = Calendar.academy
        
        guard
            let startOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)
        else {
            completion(.success([]))
            return
        }
        
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withInternetDateTime]
        let startStr = fmt.string(from: startOfMonth)
        let endStr   = fmt.string(from: endOfMonth)
        
        let formula = "AND(IS_AFTER({Datetime}, '\(startStr)'), IS_BEFORE({Datetime}, '\(endStr)'))"
        
        var components = URLComponents(string: self.urlEventsTable)
        components?.queryItems = [
            URLQueryItem(name: "filterByFormula", value: formula),
            URLQueryItem(name: "sort[0][field]", value: "Datetime"),
            URLQueryItem(name: "sort[0][direction]", value: "asc")
        ]
        
        guard let url = components?.url else {
            completion(.failure(NSError(domain: "", code: -1)))
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
                let isoFmt = ISO8601DateFormatter()
                isoFmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                let events: [EventDetail] = response.records.compactMap { record in
                    guard let eventDate = isoFmt.date(from: record.fields.datetime) else { return nil }
                    return EventDetail(
                        id: record.fields.recordId,
                        name: record.fields.name,
                        typeEvent: record.fields.typeEvent.first!,
                        time: eventDate,
                        icon: record.fields.icon.first!,
                        colorHex: record.fields.colorHex.first!,
                        description: record.fields.description,
                        supportMaterial: record.fields.supportMaterial,
                        deliverableLinks: record.fields.deliverableLinks
                    )
                }
                completion(.success(events))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchSummaryDebug(completion: @escaping (Result<SummaryDetailFields, Error>) -> Void) {
        guard let url = URL(string: self.urlSummaryTable) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let raw = String(data: data, encoding: .utf8) {
                print("📦 RESPOSTA CRUA DO AIRTABLE:")
                print(raw)
            }
        }.resume()
    }
    
    func fetchSummary(studentId: String, completion: @escaping (Result<SummaryDetailFields, Error>) -> Void) {
        fetchSummaryDebug(){ teste in
            print(teste)
        }
        
        guard var components = URLComponents(string: self.urlSummaryTable) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL base inválida"])))
            return
        }
        
        let formula = "ARRAYJOIN({Record ID (from student)}) = '\(studentId)'"
        components.queryItems = [
            URLQueryItem(name: "filterByFormula", value: formula)
        ]
        
        print("🔍 Formula: \(formula)")
        print("🔍 URL: \(components.url?.absoluteString ?? "nil")")
        
        guard let url = components.url else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Falha ao montar parâmetros da URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue( "Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let status = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "", code: status, userInfo: [NSLocalizedDescriptionKey: "Erro no servidor: \(status)"])
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Dados não encontrados"])
                completion(.failure(error))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(AirtableSummaryDetailResponse.self, from: data)
                
                if let firstRecord = decodedResponse.records.first {
                    let field = firstRecord.fields
                    var summary = SummaryDetailFields(
                        id: field.id,
                        studentId: field.studentId,
                        recordId: field.recordId,
                        presences: field.presences,
                        absences: field.absences,
                        delays: field.delays
                    )
                    
                    summary.summaryRecordId = firstRecord.id
                    DispatchQueue.main.async { completion(.success(summary)) }
                } else {
                    let error = NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Estudante não encontrado na base para fazer o resumo"])
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    func fetchVacationDates() async throws -> [VacationDate]{
        guard let url = URL(string: self.urlVacationDates) else {
            throw URLError(.badURL)
        }
        
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

            let (data, _) = try await URLSession.shared.data(for: request)
            let vacationsResponse = try JSONDecoder().decode(AirtableResponse<VacationDate>.self, from: data)
            
            return vacationsResponse.records.map(\.fields)
            
        } catch let error as DecodingError {
            switch error {
            case .keyNotFound(let key, let context):
                print("❌ Chave faltando: '\(key.stringValue)' — \(context.debugDescription)")
            case .typeMismatch(let type, let context):
                print("❌ Tipo errado: esperava \(type) em \(context.codingPath.map(\.stringValue))")
            case .valueNotFound(let type, let context):
                print("❌ Valor nulo: \(type) em \(context.codingPath.map(\.stringValue))")
            case .dataCorrupted(let context):
                print("❌ Dado corrompido: \(context.debugDescription)")
            @unknown default:
                print("❌ Erro de decode desconhecido")
            }
            throw error
        }
        catch(let error){
            print("O ERRO AO LOCALIZAR AS DATAS DAS FERIAS FOI: \(error.localizedDescription)")
            throw error
        }
    }
    
    func updateSummaryStudent(summaryRecord: SummaryRecord, completion: @escaping(Result<Bool, Error>) -> Void) {
        
        guard let url = URL(string: "\(self.urlSummaryTable)/\(summaryRecord.summaryId)") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "URL inválida"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let fields: [String: Int] = [
            "presences": summaryRecord.presences,
            "absences": summaryRecord.absences,
            "delays": summaryRecord.delays,
        ]
        
        let body: [String: Any] = [
            "fields": fields,
            "typecast": true
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                if let data = data, let errorBody = String(data: data, encoding: .utf8) {
                    print("Erro Airtable (\((response as? HTTPURLResponse)?.statusCode ?? -1)): \(errorBody)")
                }
                completion(.failure(NSError(domain: "APIError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Erro ao atualizar"])))
                return
            }
            
            completion(.success(true))
        }.resume()
    }
}

