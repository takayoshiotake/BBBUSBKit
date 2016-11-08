//
//  BBBUSBKitTests.swift
//  BBBUSBKitTests
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//
//

import XCTest
@testable import BBBUSBKit

class BBBUSBKitTests: XCTestCase {
    
    func testExample() {
        let um = BBBUSBManager()
        if let devices = um.listDevices() {
            for device in devices {
                do {
                    let deviceDescriptor = device.deviceDescriptor
                    let configurationDescriptor = try device.getConfigurationDescriptor()
                    
                    print("deviceDescriptor=\(deviceDescriptor)")
                    print("configurationDescriptor=\(configurationDescriptor)")
                }
                catch {
                }
            }
        }
    }
    
    func testOpen() {
        let um = BBBUSBManager()
        if let device = um.listDevices()?.first {
            do {
                try device.open()
                try device.listInterfaces()
            }
            catch BBBUSBDeviceError.IOReturnError(let err) {
                print(String(format: "err=0x%08x", err))
            }
            catch {
            }
            try! device.close() // will ignore error `kIOReturnNotOpen`
        }
    }
    
    func testMyUSBDevice() {
        // PIC18F14K50
        let idVendor = 0x04d8 as UInt16
        let idProduct = 0x003f as UInt16
        let um = BBBUSBManager()
        if let device = um.listDevices()?.filter({ $0.deviceDescriptor.idVendor == idVendor && $0.deviceDescriptor.idProduct == idProduct }).first {
            XCTAssertEqual(device.deviceDescriptor.product, "Simple HID Device Demo")
            
            do {
//                try device.open()
                try device.listInterfaces()
            }
            catch {
                
            }
            try! device.close()
        }
    }
    
}
