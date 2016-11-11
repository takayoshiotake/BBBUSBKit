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

enum DeviceRequestRequestTypeDirection: UInt8 {
    case toDevice = 0
    case toHost = 1
}

enum DeviceRequestRequestTypeType: UInt8 {
    case standard = 0
    case `class` = 1
    case vendor = 2
}

enum DeviceRequestRequestTypeRecipient: UInt8 {
    case device = 0
    case interface = 1
    case endpoint = 2
    case other = 3
}

enum DeviceRequestRequestType {
    case requestType(DeviceRequestRequestTypeDirection, DeviceRequestRequestTypeType, DeviceRequestRequestTypeRecipient)
    var rawValue: UInt8 {
        get {
            switch self {
            case let .requestType(d7, d6_5, d4_0):
                return d7.rawValue << 7 | d6_5.rawValue << 5 | d4_0.rawValue
            }
        }
    }
}

enum DeviceRequestParticularRequest: UInt8 {
    case getDescriptor = 6
}


public class BBBUSBDevice: CustomStringConvertible {
    let service: io_service_t
    let device: USBDeviceInterface
    public let name: String
    public let path: String
    
    public var deviceDescriptor: USBDeviceDescriptor
    
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
        
        guard let plugInInterface = USBPlugInInterface(service: service, plugInType: .device), let device = plugInInterface.queryUSBDeviceInterface() else {
            IOObjectRelease(service)
            return nil // `deinit` is not called
        }
        self.device = device
        
        var devDesc = IOUSBDeviceDescriptor()
        _ = withUnsafeMutablePointer(to: &devDesc) {
            device.deviceRequest(withRequestType: DeviceRequestRequestType.requestType(.toHost, .standard, .device).rawValue, request: DeviceRequestParticularRequest.getDescriptor.rawValue, value: UInt16(USBDescriptorType.device.rawValue) << 8, index: 0, length: 18, data: $0)
        }
        do {
            deviceDescriptor = try withBridgingIOReturnError {
                let manufacturerString: String? = try? device.getStringDescriptor(of: devDesc.iManufacturer)
                let productString: String? = try? device.getStringDescriptor(of: devDesc.iProduct)
                let serialNumberString: String? = try? device.getStringDescriptor(of: devDesc.iSerialNumber)
                return USBDeviceDescriptor(bLength: devDesc.bLength, bDescriptorType: devDesc.bDescriptorType, bcdUSB: devDesc.bcdUSB, bDeviceClass: devDesc.bDeviceClass, bDeviceSubClass: devDesc.bDeviceSubClass, bDeviceProtocol: devDesc.bDeviceProtocol, bMaxPacketSize0: devDesc.bMaxPacketSize0, idVendor: devDesc.idVendor, idProduct: devDesc.idProduct, bcdDevice: devDesc.bcdDevice, iManufacturer: devDesc.iManufacturer, iProduct: devDesc.iProduct, iSerialNumber: devDesc.iSerialNumber, bNumConfigurations: devDesc.bNumConfigurations, manufacturerString: manufacturerString, productString: productString, serialNumberString: serialNumberString)
            }
        }
        catch {
            IOObjectRelease(service)
            return nil
        }
        
        // DEBUG:
        var configDesc = IOUSBConfigurationDescriptor()
        let requestType = DeviceRequestRequestType.requestType(.toHost, .standard, .device)
        let particularRequest = DeviceRequestParticularRequest.getDescriptor
        _ = withUnsafeMutablePointer(to: &configDesc) {
            device.deviceRequest(withRequestType: requestType.rawValue, request: particularRequest.rawValue, value: UInt16(USBDescriptorType.configuration.rawValue) << 8, index: 0, length: 9, data: $0)
        }
        if configDesc.wTotalLength > 9 {
            // TODO:
        }
    }
    
    deinit {
        IOObjectRelease(service)
    }
    
    public func getConfigurationDescriptor() throws -> USBConfigurationDescriptor {
        let cd = try withBridgingIOReturnError {
            try device.getConfigurationDescriptor().pointee
        }
        return USBConfigurationDescriptor(bLength: cd.bLength, bDescriptorType: cd.bDescriptorType, wTotalLength: cd.wTotalLength, bNumInterfaces: cd.bNumInterfaces, bConfigurationValue: cd.bConfigurationValue, iConfiguration: cd.iConfiguration, bmAttributes: cd.bmAttributes, bMaxPower: cd.MaxPower, configurationString: nil, interfaces: [])
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
            if let interface = BBBUSBInterface(service: service, device: self) { // move service
                interfaces.append(interface)
            }
        }
        return interfaces
    }
    
    public var description: String {
        get {
            return String(format: "BBBUSBKit.BBBUSBDevice = { name=\"\(name)\", path=\"\(path)\", vendorID=0x%04x, productID=0x%04x }", deviceDescriptor.idVendor, deviceDescriptor.idProduct)
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

