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
            }
            catch BBBUSBDeviceError.IOReturnError(let err) {
                print(String(format: "err=0x%08x", err))
            }
            catch {
            }
            try! device.close() // will ignore error `kIOReturnNotOpen`
        }
    }
    
}
