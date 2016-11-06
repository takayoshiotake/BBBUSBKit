//
//  BBBUSBDevice.swift
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//  Copyright © 2016 OTAKE Takayoshi. All rights reserved.
//

import Foundation
import BBBUSBKitPrivate

class BBBUSBDevice {
    let service: io_service_t
    let name: String
    let path: String
    let vendorID: UInt16
    let productID: UInt16
    
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
        vendorID = interface.vendorID
        productID = interface.productID
    }
    
    deinit {
        IOObjectRelease(service)
    }
}
