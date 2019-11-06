//
//  UnityCoreMLPlugin.m
//  DeepLabTest
//
//  Created by Koki Ibukuro on 2019/11/06.
//  Copyright © 2019 Koki Ibukuro. All rights reserved.
//

#include <TargetConditionals.h>

#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#endif

#if TARGET_OS_OSX
#import <AppKit/AppKit.h>
#endif

#import <MetalKit/MetalKit.h>
#import <CoreML/CoreML.h>
#import "Unity/IUnityGraphicsMetal.h"
#import "Unity/IUnityRenderingExtensions.h"

#import "UnityCoreML-Swift.h"

typedef void (*CallbackFunc)(void *dataPointer);

@interface PluginEntry: NSObject<UnityCoreMLResultDelegate>
{
    CallbackFunc _callback;
}
@property CallbackFunc callback;
@end

@implementation PluginEntry

@synthesize callback = _callback;

- (void)onUnityCoreMLResultWithArray:(MLMultiArray * _Nonnull)array {
    NSLog(@"get array");
    if(self.callback != nil) {
        self.callback(array.dataPointer);
    }
}
@end

static UnityCoreML* _unityCoreML = [[UnityCoreML alloc] init];
static PluginEntry* _entry = nullptr;

extern "C" void UnityCoreML_LoadModel(const char* path) {
    NSLog(@"load model");
    NSURL* url = [NSURL URLWithString:[NSString stringWithUTF8String:path]];
    [_unityCoreML loadModel:url];
}

extern "C" void UnityCoreML_Delegate(CallbackFunc callback) {
    NSLog(@"set delegate");
    _entry = [[PluginEntry alloc] init];
    _entry.callback = callback;
    _unityCoreML.delegate = _entry;
}

extern "C" void UnityCoreML_Predict_Texture(int32_t texRef) {
    NSLog(@"start predict");
}

extern "C" void UnityCoreML_Predict_File(const char* path) {
    NSURL* url = [NSURL URLWithString:[NSString stringWithUTF8String:path]];
    [_unityCoreML predictWithUrl:url];
}
