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
    public var configurationDescriptor: USBConfigurationDescriptor
    
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
        
        do {
            deviceDescriptor = try withBridgingIOReturnError {
                var devDesc = IOUSBDeviceDescriptor()
                var request = IOUSBDevRequest()
                request.bmRequestType = DeviceRequestRequestType.requestType(.toHost, .standard, .device).rawValue
                request.bRequest = DeviceRequestParticularRequest.getDescriptor.rawValue
                request.wValue = UInt16(USBDescriptorType.device.rawValue) << 8
                request.wIndex = 0
                request.wLength = 18
                request.pData = UnsafeMutableRawPointer(&devDesc)
                try device.deviceRequest(&request)
                
                var result = USBDeviceDescriptor()
                result.bLength = devDesc.bLength
                result.bDescriptorType = devDesc.bDescriptorType
                result.bcdUSB = devDesc.bcdUSB
                result.bDeviceClass = devDesc.bDeviceClass
                result.bDeviceSubClass = devDesc.bDeviceSubClass
                result.bDeviceProtocol = devDesc.bDeviceProtocol
                result.bMaxPacketSize0 = devDesc.bMaxPacketSize0
                result.idVendor = devDesc.idVendor
                result.idProduct = devDesc.idProduct
                result.bcdDevice = devDesc.bcdDevice
                result.iManufacturer = devDesc.iManufacturer
                result.iProduct = devDesc.iProduct
                result.iSerialNumber = devDesc.iSerialNumber
                result.bNumConfigurations = devDesc.bNumConfigurations
                if result.iManufacturer != 0 {
                    result.manufacturerString = try device.getStringDescriptor(of: result.iManufacturer)
                }
                if result.iProduct != 0 {
                    result.productString = try device.getStringDescriptor(of: result.iProduct)
                }
                if result.iSerialNumber != 0 {
                    result.serialNumberString = try device.getStringDescriptor(of: result.iSerialNumber)
                }
                return result
            }
            
            // DEBUG:
            configurationDescriptor = try withBridgingIOReturnError {
                var configDesc = IOUSBConfigurationDescriptor()
                var request = IOUSBDevRequest()
                request.bmRequestType = DeviceRequestRequestType.requestType(.toHost, .standard, .device).rawValue
                request.bRequest = DeviceRequestParticularRequest.getDescriptor.rawValue
                request.wValue = UInt16(USBDescriptorType.configuration.rawValue) << 8
                request.wIndex = 0
                request.wLength = 9
                request.pData = UnsafeMutableRawPointer(&configDesc)
                try device.deviceRequest(&request)
                
                var result = USBConfigurationDescriptor()
                result.bLength = configDesc.bLength
                result.bDescriptorType = configDesc.bDescriptorType
                result.wTotalLength = configDesc.wTotalLength
                result.bNumInterfaces = configDesc.bNumInterfaces
                result.bConfigurationValue = configDesc.bConfigurationValue
                result.iConfiguration = configDesc.iConfiguration
                result.bmAttributes = configDesc.bmAttributes
                result.bMaxPower = configDesc.MaxPower
                if result.iConfiguration != 0 {
                    result.configurationString = try device.getStringDescriptor(of: result.iConfiguration)
                }
                
                if configDesc.wTotalLength > 9 {
                    // Get interfaceDescriptor, endpointDescriptor
                    var configDescBytes = [UInt8](repeating: 0, count: Int(configDesc.wTotalLength))
                    request.wLength = configDesc.wTotalLength
                    request.pData = UnsafeMutableRawPointer(&configDescBytes[0])
                    try device.deviceRequest(&request)
                    
                    var ptr = withUnsafePointer(to: &configDescBytes[9]) { $0 }
                    var available = configDesc.wTotalLength - 9
                    for _ in 0..<configDesc.bNumInterfaces {
                        guard ptr[0] == 9 && ptr[1] == USBDescriptorType.interface.rawValue && available >= 9 else {
                            // FIXME:
                            return result
                        }
                        var ifDesc = USBInterfaceDescriptor()
                        ifDesc.bLength = ptr[0]
                        ifDesc.bDescriptorType = ptr[1]
                        ifDesc.bInterfaceNumber = ptr[2]
                        ifDesc.bAlternateSetting = ptr[3]
                        ifDesc.bNumEndpoints = ptr[4]
                        ifDesc.bInterfaceClass = ptr[5]
                        ifDesc.bInterfaceSubClass = ptr[6]
                        ifDesc.bInterfaceProtocol = ptr[7]
                        ifDesc.iInterface = ptr[8]
                        ptr = ptr.advanced(by: 9)
                        available -= 9
                        
                        for _ in 0..<ifDesc.bNumEndpoints {
                            guard ptr[0] == 7 && ptr[1] == USBDescriptorType.endpoint.rawValue && available >= 7 else {
                                // FIXME:
                                return result
                            }
                            var epDesc = USBEndpointDescriptor()
                            epDesc.bLength = ptr[0]
                            epDesc.bDescriptorType = ptr[1]
                            epDesc.bEndpointAddress = ptr[2]
                            epDesc.bmAttributes = ptr[3]
                            epDesc.wMaxPacketSize = UInt16(ptr[4]) | UInt16(ptr[5]) << 8
                            epDesc.bInterval = ptr[6]
                            ptr = ptr.advanced(by: 7)
                            available -= 7
                            
                            ifDesc.endpoints.append(epDesc)
                        }
                        
                        result.interfaces.append(ifDesc)
                    }
                    
                    if available != 0 {
                        // TODO: error
                    }
                }
                
                return result
            }
        }
        catch {
            IOObjectRelease(service)
            return nil // `deinit` is not called
        }
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

