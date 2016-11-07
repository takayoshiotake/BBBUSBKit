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
    case IOReturnError(err: Int)
}

public class BBBUSBDevice: CustomStringConvertible {
    let service: io_service_t
    let device: USBDeviceInterface
    public let name: String
    public let path: String
    
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
        
        guard let plugInInterface = USBPlugInInterface(service), let device = plugInInterface.queryInterface() else {
            IOObjectRelease(service)
            return nil // `deinit` is not called
        }
        self.device = device
    }
    
    deinit {
        IOObjectRelease(service)
    }
    
    
    public func open() throws {
        let err = device.open()
        if err != kIOReturnSuccess {
            throw BBBUSBDeviceError.IOReturnError(err: Int(err))
        }
    }
    
    public func close() throws {
        let err = device.close()
        if (err == kIOReturnNotOpen) {
            // Ignore
        }
        else if (err != kIOReturnSuccess) {
            throw BBBUSBDeviceError.IOReturnError(err: Int(err))
        }
    }
    
    public var description: String {
        get {
            return String(format: "BBBUSBKit.BBBUSBDevice = { name=\"\(name)\", path=\"\(path)\", vendorID=0x%04x, productID=0x%04x }", device.deviceDescriptor.idVendor, device.deviceDescriptor.idProduct)
        }
    }
}
