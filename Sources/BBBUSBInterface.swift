//
//  BBBUSBInterface.swift
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/07.
//
//

import Foundation
import BBBUSBKitPrivate

public class BBBUSBInterface {
    let service: io_service_t
    let interface: USBInterfaceInterface
    
    init?(service: io_service_t) {
        self.service = service
        
        guard let plugInInterface = USBPlugInInterface(service), let interface = plugInInterface.queryUSBInterfaceInterface() else {
            IOObjectRelease(service)
            return nil // `deinit` is not called
        }
        self.interface = interface
    }
    
    deinit {
        IOObjectRelease(service)
    }
}
