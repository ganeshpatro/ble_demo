//
//  DeviceManager.swift
//  BleExampleDemo
//
//  Created by KaHa Admin on 18/04/18.
//  Copyright © 2018 KaHa Admin. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol DeviceManagerDelegate: class {
    
    func centralManagerState(_ state: CBManagerState)
    func discovered(_ peripheral: CBPeripheral, with advertisement: [String: Any], and rssi: NSNumber)
    func connected(_ peripheral: CBPeripheral)
    func disconnected(_ peripheral: CBPeripheral, with error: Error?)
    func failToConnect(_ peripheral: CBPeripheral, with error: Error?)
}

class DeviceManager: NSObject {

    static let shared = DeviceManager()
    weak var delegate: DeviceManagerDelegate?

    private var centralManager: CBCentralManager?
    private var cPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self,
                                          queue: nil,
                                          options: nil)
        /*      centralManager = CBCentralManager(delegate: self,
         queue: nil,
         options: [CBCentralManagerOptionRestoreIdentifierKey: "com.coveiot.RAGA.centralManager",
         CBCentralManagerOptionShowPowerAlertKey: NSNumber(value: true)])*/
    }
    
    // MARK: - Util Functions
    func startScan(_ uuids: [CBUUID]?) {
        
        centralManager?.scanForPeripherals(withServices: uuids, options: nil)
    }
    
    func stopScan() {
        
        centralManager?.stopScan()
    }
    
    func connect(_ peripheral: CBPeripheral, with options: [String: Any]? = nil) {
        
        centralManager?.connect(peripheral, options: options)
    }
    
    func disconnect (_ peripheral: CBPeripheral?) {
        
        if let peripheral = peripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
    }
    
    func connectToPeripheralWith(_ uuid: UUID) {
        
        if let peripherals = centralManager?.retrievePeripherals(withIdentifiers: [uuid as UUID]) {
            if  peripherals.count > 0 {
                if let peripheral = (peripherals.first) {
                    cPeripheral = peripheral
                    centralManager?.connect(peripheral, options: nil)
                } else {
                    // startScan(nil)
                }
            }
        }
    }
}

extension DeviceManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        delegate?.centralManagerState(central.state)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        
        delegate?.discovered(peripheral, with: advertisementData, and: RSSI)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        delegate?.connected(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        
        delegate?.disconnected(peripheral, with: error)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        
        delegate?.failToConnect(peripheral, with: error)
    }
    
}





