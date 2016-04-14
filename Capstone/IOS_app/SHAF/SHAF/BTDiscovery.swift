//
//  BTDiscovery.swift
//  SHAF
//
//  Created by Ahmed Abdulkareem on 4/13/16.
//  Copyright © 2016 Ahmed Abdulkareem. All rights reserved.
//

import UIKit
import CoreBluetooth

let BLEDiscovery = BTDiscovery()

let SHAF_SERVICE_UUID = CBUUID(string: "180D")
let REP_COUNT_CHARACTERISTIC_UUID = CBUUID(string: "2a37")
let FATIGUE_CHARACTERISTIC_UUID = CBUUID(string: "F000AA00-0451-4000-B000-000000000000")
let START_CHARACTERISTIC_UUID = CBUUID(string: "F000AA00-0451-4000-B000-000000000000")


class BTDiscovery: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var centralManager: CBCentralManager? // BLE central manager
    private var peripheralBLE: CBPeripheral?
    private var discoveredDevices = [String]()    // a list of discovered devices
    private var peripherals = [CBPeripheral]()    // a list of all peripheral objects
    private var isConnected: Bool?                // flag to indicate connection
    private var UUIDs = [String: [String]]()      // a dictionary of UUIDs
    
    
    var devicesDiscovered: [String] {
        return self.discoveredDevices
    }
    
    var periphs: [CBPeripheral] {
        return self.peripherals
    }
    
    
    override init() {
        super.init()
        
        let centralQueue = dispatch_queue_create("SHAF", DISPATCH_QUEUE_SERIAL)
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
        }
    
    
    func stopScan() {
        self.centralManager?.stopScan()
    }
    
    func connect(peripheral: Int) {
        
        // stop scanning to save power
        self.centralManager!.stopScan()
        
        self.peripheralBLE = self.peripherals[peripheral]
        self.peripheralBLE?.delegate = self;
        self.centralManager?.connectPeripheral(self.peripheralBLE!, options: nil)
    }

    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        // if bluetooth is on, start searching
        if central.state == CBCentralManagerState.PoweredOn {
            central.scanForPeripheralsWithServices(nil, options: nil)
        }
    }
    
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        let discoveredDeviceName = peripheral.name
        if ((discoveredDeviceName != nil) && !(self.discoveredDevices.contains(discoveredDeviceName!))) {
            self.discoveredDevices += [discoveredDeviceName as String!]
            self.peripherals += [peripheral];
            NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
        }
    }
    
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        self.isConnected = true
        print("Connected to ", peripheral.name);
        peripheral.discoverServices(nil) // discover services
    }
    
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        self.isConnected = false
        print("Failed to connect to peripheral -> ", error)
    }
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("Discovered services for peripheral -> ", peripheral)
        
        // go through services and find the one we want
        // then discover the characteristics of that service
        for service in peripheral.services! {
            if service.UUID == SHAF_SERVICE_UUID {
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        // 0x01 data byte to let the peripheral start sending data
        var startValue = 1
        let startByte = NSData(bytes: &startValue, length: sizeof(UInt8))
        
        
        for characteristic in service.characteristics! {
            // for Rep count, this will set it so that I'll get notified
            // whenever the value of reps change
            if characteristic.UUID == REP_COUNT_CHARACTERISTIC_UUID {
                self.peripheralBLE?.setNotifyValue(true, forCharacteristic: characteristic)
            }
            
            // do same for this fatigue flag
            else if characteristic.UUID == FATIGUE_CHARACTERISTIC_UUID {
                self.peripheralBLE?.setNotifyValue(true, forCharacteristic: characteristic)
            }
            
            else if characteristic.UUID == START_CHARACTERISTIC_UUID {
                self.peripheralBLE?.writeValue(startByte, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithResponse)
            }
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        var reps: NSInteger = 0
        
        print("Characteristic --> ", characteristic.UUID.description, " Just updated value")
        
        if characteristic.UUID == REP_COUNT_CHARACTERISTIC_UUID {
            
            let data = characteristic.value
            let dataLength = data?.length
            characteristic.value?.getBytes(&reps, length: dataLength!)
            
            print("Rep Count: ",  characteristic.value)
            
        }
        else if characteristic.UUID == FATIGUE_CHARACTERISTIC_UUID {
            
            print("Fatigue value: ", characteristic.value)
        }
    }

}
