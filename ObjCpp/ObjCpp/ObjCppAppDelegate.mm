//
//  ObjCppAppDelegate.m
//  ObjCpp
//  Simple Objective-C/C++/C communication test
//  Created by Dragan Petrovic on 01/11/2013.
//  Copyright (c) 2013 Polytonic. All rights reserved.
//

#import "ObjCppAppDelegate.h"
#import <objc/objc-runtime.h>
#include <typeinfo>

typedef void(*function_c)(id,SEL,void*);

template <class T>
class Cpp {
public:
    Cpp() {
        if(typeid(T) == typeid(ObjCppAppDelegate*)) {
            SEL selector = NSSelectorFromString(@"test_it:");
            id result = objc_msgSend([ObjCppAppDelegate class], selector, @"My name is Cpp and i am C++ class");
            NSLog(@"%@", result);
        }
    }
    void Cpp_method(id sender, SEL selector, function_c function) {
        NSLog(@"Hello %s from C++ method", typeid(T).name());
        sleep(1);
        function(sender, selector, this);
    }
private:
    T object;
};

void c_function(id sender, SEL selector, void* object) {
    NSLog(@"Hello from C");
    sleep(1);
    auto block_function = ^(id sender, SEL selector, void* object) {
        NSLog(@"Hello from Block function");
        sleep(1);
        auto lambda_function = [](id sender, SEL selector, void* object) {
            NSLog(@"Hello from Lambda function");
            sleep(1);
            objc_msgSend(sender, selector, object); // go back to ObjC
        };
        lambda_function(sender, selector, object);
    };
    block_function(sender, selector, object);
}

@interface ObjC : NSObject
@end
@implementation ObjC
+ (void) ObjC_method:(void*)object {
    NSLog(@"Hello %s from Objective-C method", typeid(object).name());
    sleep(1);
    Cpp<ObjCppAppDelegate*>().Cpp_method(self, _cmd, c_function);
}
@end

@implementation ObjCppAppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    [ObjC ObjC_method:NULL];
}

+ (id) test_it:(NSString*)input {
    NSLog(@"%@", input);
    return @1234;
}

@end
