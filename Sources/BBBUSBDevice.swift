//
//  BBBUSBDevice.swift
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//  Copyright © 2016 OTAKE Takayoshi. All rights reserved.
//

import Foundation
import BBBUSBKitPrivate

public enum BBBUSBDeviceError: Error {
    case IOReturn(err: IOReturn)
}

public class BBBUSBDevice: CustomStringConvertible {
    let service: io_service_t
    let interface: USBDeviceInterface
    public let name: String
    public let path: String
    public let vendorID: UInt16
    public let productID: UInt16
    
    init?(service: io_service_t) {
        self.service = service
        name = { () -> String in
            let nameBytes = UnsafeMutablePointer<Int8>.allocate(capacity: MemoryLayout<io_name_t>.size)
            _ = IORegistryEntryGetName(service, nameBytes)
            defer {
                nameBytes.deallocate(capacity: MemoryLayout<io_name_t>.size)
            }
            return String(cString: nameBytes)
        }()
        path = { () -> String in
            let pathBytes = UnsafeMutablePointer<Int8>.allocate(capacity: MemoryLayout<io_name_t>.size)
            _ = IORegistryEntryGetPath(service, kIOUSBPlane, pathBytes)
            defer {
                pathBytes.deallocate(capacity: MemoryLayout<io_name_t>.size)
            }
            return String(cString: pathBytes)
        }()
        
        guard let plugInInterface = USBPlugInInterface(service), let interface = plugInInterface.queryInterface() else {
            IOObjectRelease(service)
            return nil // `deinit` is not called
        }
        self.interface = interface
        vendorID = interface.vendorID
        productID = interface.productID
    }
    
    deinit {
        IOObjectRelease(service)
    }
    
    
    public func open() {
        
    }
    
    public func close() {
        
    }
    
    public var description: String {
        get {
            return String(format: "BBBUSBKit.BBBUSBDevice = { name=\"\(name)\", path=\"\(path)\", vendorID=0x%04x, productID=0x%04x }", vendorID, productID)
        }
    }
}
