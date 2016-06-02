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

// define UUIDs
let SHAF_SERVICE_UUID                    = CBUUID(string: "180D")
let REC_CALIB_ERR_CHARACTERISTIC_UUID    = CBUUID(string: "2a37")
let REC_CALIB_DONE_CHARACTERISTIC_UUID   = CBUUID(string: "2a38")
let REC_REP_COUNT_CHARACTERISTIC_UUID    = CBUUID(string: "2a39")
let REC_FATIGUE_CHARACTERISTIC_UUID      = CBUUID(string: "2a3a")
let REC_TIMEOUT_CHARACTERISTIC_UUID      = CBUUID(string: "2a3b")
let SEND_CALIB_START_CHARACTERISTIC_UUID = CBUUID(string: "2a3c")
let SEND_START_CHARACTERISTIC_UUID       = CBUUID(string: "2a3d")
let SEND_STOP_CHARACTERISTIC_UUID        = CBUUID(string: "2a3e")

class BTDiscovery: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var centralManager: CBCentralManager? // BLE central manager
    private var peripheralBLE: CBPeripheral?
    private var discoveredDevices = [String]()    // a list of discovered devices
    private var peripherals = [CBPeripheral]()    // a list of all peripheral objects
    private var isConnected: Bool?                // flag to indicate connection
    private var service: CBService?
    var characteristics = [String: CBCharacteristic]() // a dicrionary of characteristics
    
    
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
    
    // this function assigns characteristics into a dictionary so 
    // they can be referred to later easily without looping into the
    // array every time
    func assignCharacteristics() {
        dispatch_async(dispatch_get_main_queue()) {
        // get characteristic from current service
        let chars = self.service?.characteristics
        
        // make sure its not empty
        if chars == nil {
            return
        }
        
        // loop through characteristics to find the right one
        for characteristic in chars! {
            if characteristic.UUID == SEND_CALIB_START_CHARACTERISTIC_UUID {
                self.characteristics["SEND_CALIB_START_CHARACTERISTIC"] = characteristic
            }
            else if characteristic.UUID == SEND_START_CHARACTERISTIC_UUID {
                self.characteristics["SEND_START_CHARACTERISTIC"] = characteristic
            }
            else if characteristic.UUID == SEND_STOP_CHARACTERISTIC_UUID {
                self.characteristics["SEND_STOP_CHARACTERISTIC"] = characteristic
            }
            else if characteristic.UUID == REC_REP_COUNT_CHARACTERISTIC_UUID {
                self.characteristics["REC_REP_COUNT_CHARACTERISTIC"] = characteristic
            }
            else if characteristic.UUID == REC_FATIGUE_CHARACTERISTIC_UUID {
                self.characteristics["REC_FATIGUE_CHARACTERISTIC"] = characteristic
            }
            else if characteristic.UUID == REC_TIMEOUT_CHARACTERISTIC_UUID {
                self.characteristics["REC_TIMEOUT_CHARACTERISTIC"] = characteristic
            }
            else if characteristic.UUID == REC_CALIB_ERR_CHARACTERISTIC_UUID {
                self.characteristics["REC_CALIB_ERR_CHARACTERISTIC"] = characteristic
            }
            else if characteristic.UUID == REC_CALIB_DONE_CHARACTERISTIC_UUID {
                self.characteristics["REC_CALIB_DONE_CHARACTERISTIC"] = characteristic
            }
        }
        }

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
    
    func startStopData(start: Bool) {
        var startValue = 1
        var startByte = NSData(bytes: &startValue, length: sizeof(UInt8))
        
        if !start {
            startValue = 0
            startByte = NSData(bytes: &startValue, length: sizeof(UInt8))
        }
        
        print("Start flag: ", startValue)

        self.peripheralBLE?.writeValue(startByte, forCharacteristic: self.characteristics["SEND_START_CHARACTERISTIC"]!, type: CBCharacteristicWriteType.WithResponse)
    }
    
    // asserts the stop flag when called
    func assertStop() {
        var stopValue = 1
        let stopByte = NSData(bytes: &stopValue, length: sizeof(UInt8))
        
        
        // update value
        self.peripheralBLE?.writeValue(stopByte, forCharacteristic: self.characteristics["SEND_STOP_CHARACTERISTIC"]!, type: CBCharacteristicWriteType.WithResponse)
    }
    
    
    // function used to set or clear calibrate flag
    func calibrate(set: Bool) {
        var startValue = 1
        var startByte = NSData(bytes: &startValue, length: sizeof(UInt8))
        
        if !set {
            startValue = 0
            startByte = NSData(bytes: &startValue, length: sizeof(UInt8))
        }
        print("calib start value:", startValue)

        self.peripheralBLE?.writeValue(startByte, forCharacteristic: self.characteristics["SEND_CALIB_START_CHARACTERISTIC"]!, type: CBCharacteristicWriteType.WithResponse)
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
            NSNotificationCenter.defaultCenter().postNotificationName("discoveredPeriph", object: nil)
        }
    }
    
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        self.isConnected = true
        print("Connected to ", peripheral.name);
        peripheral.discoverServices(nil) // discover services
        NSNotificationCenter.defaultCenter().postNotificationName("periphConnected", object: nil)
    }
    
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        self.isConnected = false
        print("Failed to connect to peripheral -> ", error?.description)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
    }
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("Discovered services for peripheral -> ", peripheral.name)
        
        // go through services and find the one we want
        // then discover the characteristics of that service
        for service in peripheral.services! {
            if service.UUID == SHAF_SERVICE_UUID {
                self.service = service
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        for characteristic in service.characteristics! {
            // get notified every time any of the receiving characteristics change value
            if characteristic.UUID == REC_REP_COUNT_CHARACTERISTIC_UUID || characteristic.UUID == REC_FATIGUE_CHARACTERISTIC_UUID || characteristic.UUID == REC_CALIB_ERR_CHARACTERISTIC_UUID || characteristic.UUID == REC_CALIB_DONE_CHARACTERISTIC_UUID || characteristic.UUID == REC_TIMEOUT_CHARACTERISTIC_UUID {
                self.peripheralBLE?.setNotifyValue(true, forCharacteristic: characteristic)
            }
        }
        
        // assign characteristics into a dictionary
        self.assignCharacteristics()
    }
    
    
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if (error != nil) {
            print("Error writing a value --> ", error?.description.debugDescription)
        }
        else {
            print("Successfully wrote value to", characteristic.UUID)
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        print("Characteristic --> ", characteristic.UUID.description, " Just updated value")
        
        if characteristic.UUID == REC_REP_COUNT_CHARACTERISTIC_UUID {
            
            let data = characteristic.value
            let dataLength = data?.length
            var repsArray = [UInt8](count: dataLength!, repeatedValue: 0)

            data!.getBytes(&repsArray, length: dataLength! * sizeof(UInt8))

            print("Rep Count: ",  repsArray)
            let repValue = Double(repsArray[1])
            let repString = NSString(format: "%.0f", repValue)

            NSNotificationCenter.defaultCenter().postNotificationName("repCountChanged", object: nil, userInfo: ["repCount": repString])
        }
        else if characteristic.UUID == REC_FATIGUE_CHARACTERISTIC_UUID {
            print("Fatigue Reached")
            NSNotificationCenter.defaultCenter().postNotificationName("fatigue", object: nil)
        }
        else if characteristic.UUID == REC_CALIB_DONE_CHARACTERISTIC_UUID {
            let data = characteristic.value
            let dataLength = data?.length
            var repsArray = [UInt8](count: dataLength!, repeatedValue: 0)
            
            data!.getBytes(&repsArray, length: dataLength! * sizeof(UInt8))

            print("Calibration COmplete")
            print("Value:", repsArray)
            NSNotificationCenter.defaultCenter().postNotificationName("calibComplete", object: nil)
        }
        else if characteristic.UUID == REC_CALIB_ERR_CHARACTERISTIC_UUID {
            print("Calibration Failed")
            NSNotificationCenter.defaultCenter().postNotificationName("calibFailed", object: nil)
        }
        else if characteristic.UUID == REC_TIMEOUT_CHARACTERISTIC_UUID {
            print("Time out")
            NSNotificationCenter.defaultCenter().postNotificationName("repTimeOut", object: nil)
        }
    }
}
