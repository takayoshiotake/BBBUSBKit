//
//  USBInterfaceInterface.m
//  BBBUSBKit
//
//  Created by OTAKE Takayoshi on 2016/11/08.
//
//

#import "USBInterfaceInterface.h"

@interface USBInterfaceInterface ()

@property (assign, nonatomic, readwrite) IOUSBInterfaceInterfaceLatest ** interface;

@end

@implementation USBInterfaceInterface

- (instancetype)initWithInterface:(IOUSBInterfaceInterfaceLatest **)interface {
    self = [super init];
    if (self) {
        _interface = interface;
        [self setup];
    }
    return self;
}

- (void)dealloc {
    IOReturn err = (*_interface)->Release(_interface);
    if (err != kIOReturnSuccess) {
        NSLog(@"Warning: 0x%08x at %s, line %d", err, __PRETTY_FUNCTION__, __LINE__);
    }
}

- (void)setup {
    
}

@end
