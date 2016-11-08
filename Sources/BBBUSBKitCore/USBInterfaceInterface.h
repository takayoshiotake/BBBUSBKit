//
//  USBInterfaceInterface.h
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/08.
//
//

#import <Foundation/Foundation.h>

#import "BBBUSBKitCore.h"

@interface USBInterfaceInterface : NSObject

@property (assign, nonatomic, readonly) IOUSBInterfaceInterfaceLatest ** interface;

- (instancetype)initWithInterface:(IOUSBInterfaceInterfaceLatest **)interface;

@end
