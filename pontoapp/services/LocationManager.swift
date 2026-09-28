//
//  LocationManager.swift
//  pontoapp
//
//  Created by Joao Carlos Lima on 08/11/24.
//

import CoreLocation
import UserNotifications

class LocationManager: NSObject, ObservableObject{
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var permissionDenied = false
    @Published var isInsideAcademy = false
    
    static let shared = LocationManager()
    
    //coordenadas da academy
    private let academyCoordinate = CLLocationCoordinate2D(
      latitude:  -23.668777973166964,
      longitude: -46.6992374689516
    )

    private let academyRadius: CLLocationDistance = 50.0
    private let geofenceRadius: CLLocationDistance = 80.0
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        
        requestSendUserNotification()
        monitorarGeofence()
    }
    
    func requestLocation(){
        manager.requestAlwaysAuthorization()
    }
    
    func monitorarGeofence(){
        let region = CLCircularRegion(center: academyCoordinate, radius: geofenceRadius, identifier: "Academy")
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        manager.startMonitoring(for: region)
    }
    
    func checkIfInsideAcademy() {
        guard let userLocation = userLocation else { return }
 
        let academyLocation = CLLocation(
            latitude:  academyCoordinate.latitude,
            longitude: academyCoordinate.longitude
        )
        
        let distance = userLocation.distance(from: academyLocation)
        let clampedAccuracy = min(userLocation.horizontalAccuracy, 50.0)
        
        let effectiveRadius = academyRadius + clampedAccuracy
        
        print("Distancia efetiva: \(effectiveRadius) - Distancia: \(distance)")
        
        DispatchQueue.main.async {
            self.isInsideAcademy = distance <= effectiveRadius
        }
    }
    
    private func requestSendUserNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Erro ao pedir permissão de notificação: \(error)")
            }
        }
    }
    
    private func sendUserNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Hora de bater o ponto!"
        content.body = "Você chegou na Academy, não esqueça de bater seu ponto."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "PontoNotificacao", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private func isOnTime() -> Bool{
        let time = Date()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        
        let nowMinutes = hour * 60 + minute
        
        //13:30 até 14:30
        let startMinutes: Int = 13 * 60 + 40
        let endMinutes: Int = 14 * 60 + 20
        
        return nowMinutes >= startMinutes && nowMinutes <= endMinutes
    }
}

extension LocationManager: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("Not determined")
        case .restricted:
            print("Restricted")
        case .denied:
            permissionDenied = true
        case .authorizedAlways:
            print("Authorized Always")
        case .authorizedWhenInUse:
            print("Authorized When In Use")
        @unknown default:
            break
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        guard location.horizontalAccuracy <= 100 else { return }
        self.userLocation = location
        checkIfInsideAcademy()
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        if region.identifier == "Academy"{
            Task{
                guard let serverDate = try? await TimeService.shared.fetchServerTime() else {
                    if isOnTime() { sendUserNotification() }
                    return
                }
                
                let calendar = Calendar.academy
                let totalMinutes = calendar.component(.hour, from: serverDate) * 60
                                 + calendar.component(.minute, from: serverDate)

                let inicio = 13 * 60 + 40  // 13:40
                let fim    = 14 * 60 + 20  // 14:20
                
                if totalMinutes >= inicio && totalMinutes <= fim {
                    sendUserNotification()
                }
            }
            
            print("ENTROU na região no horário: \(region.identifier)")
            DispatchQueue.main.async {
                self.isInsideAcademy = true
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == "Academy" {
            print("SAIU da região: \(region.identifier)")
            DispatchQueue.main.async { self.isInsideAcademy = false }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Falha ao monitorar região: \(error.localizedDescription)")
    }
}
