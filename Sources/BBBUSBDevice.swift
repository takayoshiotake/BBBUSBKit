//
//  BBBUSBDevice.swift
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/06.
//
//

import Foundation
import BBBUSBKitPrivate

public enum BBBUSBDeviceError: Error {
    case IOReturnError(err: Int)
}

public struct USBDeviceDescriptor {
    public let bLength: UInt8
    public let bDescriptorType: UInt8
    public let bcdUSB: UInt16
    public let bDeviceClass: UInt8
    public let bDeviceSubClass: UInt8
    public let bDeviceProtocol: UInt8
    public let bMaxPacketSize0: UInt8
    public let idVendor: UInt16
    public let idProduct: UInt16
    public let bcdDevice: UInt16
    public let iManufacturer: UInt8
    public let iProduct: UInt8
    public let iSerialNumber: UInt8
    public let bNumConfigurations: UInt8
    
    public let manufacturer: String?
    public let product: String?
    public let serialNumber: String?
}

public struct USBConfigurationDescriptor {
    public let bLength: UInt8
    public let bDescriptorType: UInt8
    public let wTotalLength: UInt16
    public let bNumInterfaces: UInt8
    public let bConfigurationValue: UInt8
    public let iConfiguration: UInt8
    public let bmAttributes: UInt8
    public let bMaxPower: UInt8
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
        
        guard let plugInInterface = USBPlugInInterface(service), let device = plugInInterface.queryUSBDeviceInterface() else {
            IOObjectRelease(service)
            return nil // `deinit` is not called
        }
        self.device = device
    }
    
    deinit {
        IOObjectRelease(service)
    }
    
    public var deviceDescriptor: USBDeviceDescriptor {
        get {
            let dd = device.deviceDescriptor
            return USBDeviceDescriptor(bLength: dd.bLength, bDescriptorType: dd.bDescriptorType, bcdUSB: dd.bcdUSB, bDeviceClass: dd.bDeviceClass, bDeviceSubClass: dd.bDeviceSubClass, bDeviceProtocol: dd.bDeviceProtocol, bMaxPacketSize0: dd.bMaxPacketSize0, idVendor: dd.idVendor, idProduct: dd.idProduct, bcdDevice: dd.bcdDevice, iManufacturer: dd.iManufacturer, iProduct: dd.iProduct, iSerialNumber: dd.iSerialNumber, bNumConfigurations: dd.bNumConfigurations, manufacturer: device.deviceManufacturer, product: device.deviceProduct, serialNumber: device.deviceSerialNumber)
        }
    }
    
    public func getConfigurationDescriptor() throws -> USBConfigurationDescriptor {
        let configurationDescriptor = try withBridgingIOReturnError {
            try device.getConfigurationDescriptor()
        }
        return configurationDescriptor.withMemoryRebound(to: USBConfigurationDescriptor.self, capacity: 1) {
            $0.pointee
        }
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
    
    public func listInterfaces() throws -> [BBBUSBInterface] {
        var iterator = io_iterator_t()
        let err = device.getUSBInterfaceIterator(&iterator)
        if err != kIOReturnSuccess {
            throw BBBUSBDeviceError.IOReturnError(err: Int(err))
        }
        defer {
            IOObjectRelease(iterator)
        }
        
        var interfaces: [BBBUSBInterface] = []
        for service in IOServiceSequence(iterator) {
            if let interface = BBBUSBInterface(service: service) { // move service
                interfaces.append(interface)
            }
        }
        return interfaces
    }
    
    public var description: String {
        get {
            return String(format: "BBBUSBKit.BBBUSBDevice = { name=\"\(name)\", path=\"\(path)\", vendorID=0x%04x, productID=0x%04x }", device.deviceDescriptor.idVendor, device.deviceDescriptor.idProduct)
        }
    }
}


private func withBridgingIOReturnError<T>(block: () throws -> T) throws -> T {
    do {
        return try block()
    }
    catch let error as NSError where error.domain == kBBBUSBKitIOReturnErrorDomain {
        throw BBBUSBDeviceError.IOReturnError(err: error.code)
    }
}

