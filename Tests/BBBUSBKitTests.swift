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
                print("deviceDescriptor=\(device.descriptor)")
                print("configurationDescriptor=\(device.configurationDescriptor)")
            }
        }
    }
    
    func testOpen() {
        let um = BBBUSBManager()
        if let device = um.listDevices()?.first {
            do {
                try device.open()
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
        if let device = um.listDevices()?.filter({ $0.descriptor.idVendor == idVendor && $0.descriptor.idProduct == idProduct }).first {
            XCTAssertEqual(device.descriptor.productString, "Simple HID Device Demo")
            
            do {
//                try device.open()
                let interfaces = try device.listInterfaces()
                for interface in interfaces {
                    print("interfaceDescriptor=\(interface.descriptor)")
                }
            }
            catch {
                
            }
            try! device.close()
        }
    }
    
    func testMyKeyboard() {
        let idVendor = 0x05d5 as UInt16
        let idProduct = 0x624c as UInt16
        let um = BBBUSBManager()
        if let device = um.listDevices()?.filter({ $0.descriptor.idVendor == idVendor && $0.descriptor.idProduct == idProduct }).first {
            XCTAssertEqual(device.descriptor.productString, "USB KB")
            
            let interface = try! device.listInterfaces().first!
            let endpoint = interface.listEndpoints().first!
            XCTAssertEqual(endpoint.direction, .in)
            XCTAssertEqual(endpoint.transferType, .interrupt)
        }
    }
    
}
