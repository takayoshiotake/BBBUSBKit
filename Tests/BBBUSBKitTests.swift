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
                print(device)
            }
        }
    }
    
    func testOpen() {
        let um = BBBUSBManager()
        if let device = um.listDevices()?.first {
            device.open()
        }
    }
    
}
