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
        um.debugPrintAllDevices()
    }
    
}
