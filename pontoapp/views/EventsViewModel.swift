//
//  EventsViewModel.swift
//  pontoapp
//
//  Created by Erick Costa Reimberg de Lima on 26/03/26.
//

import Foundation

class EventsViewModel: ObservableObject {
    private let webService = WebService()
    @Published var events: [EventDetail] = []
    
    private let cacheKey: String = "cachedEvents"
    private let seenKey: String = "seenIdEvents"
    
    private var cachedEvents: [EventDetail] {
        get{
            guard let data = UserDefaults.standard.data(forKey: cacheKey),
                  let decoded = try? JSONDecoder().decode([EventDetail].self, from: data)
            else {
                return []
            }
            
            return decoded
        }
        set{
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: cacheKey)
            }
        }
    }
    
    private var seenIdEvents: Set<String> {
        get {
            let array = UserDefaults.standard.stringArray(forKey: seenKey) ?? []
            return Set(array)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: seenKey)
        }
    }
    
    private var futureEvents: [EventDetail] {
        events.filter { $0.time > Date() }
    }
    
    var newEventsCount: Int {
        let seen = seenIdEvents
        return futureEvents.filter { !seen.contains($0.id) }.count
    }
    
    init(){
        self.events = cachedEvents
        fetchEvents()
    }
    
    func fetchEvents() {
        webService.fetchEvents { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let events):
                    self.events = events
                    self.cachedEvents = events
                    self.pruneSeenEventsID()
                    self.objectWillChange.send()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func isNew(_ event: EventDetail) -> Bool{
        let seen = seenIdEvents
        return !seen.contains(event.id)
    }
    
    func markAsSeen(_ event: EventDetail){
        seenIdEvents.insert(event.id)
        objectWillChange.send()
    }
    
    private func pruneSeenEventsID(){
        let currentIds = Set(events.map(\.id))
        seenIdEvents = seenIdEvents.intersection(currentIds)
    }
}
