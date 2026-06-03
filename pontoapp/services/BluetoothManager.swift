//
//  BluetoothManager.swift
//  pontoapp
//
//  Created by Erick Costa on 08/05/26.
//

import Foundation
import CoreBluetooth

class BluetoothManager:  NSObject, CBCentralManagerDelegate, ObservableObject {
    static let shared = BluetoothManager()
    var centralManager: CBCentralManager!
    @Published var isBluetoothTurnedOn: Bool = false
    
    override init() {
        super.init()
        
        let options = [CBCentralManagerOptionShowPowerAlertKey: true]
        centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async {
            self.isBluetoothTurnedOn = (central.state == .poweredOn)
        }
        
        switch central.state {
        case .poweredOn:
            print("Bluetooth Ativo")
        case .poweredOff:
            print("Bluetooth desativado... pedindo para o usuário ativar!")
        default:
            break
        }
    }
}
