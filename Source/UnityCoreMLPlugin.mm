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

#include "IUnityRenderingExtensions.h"

#import "UnityCoreML-Swift.h"

static UnityCoreML* _unityCoreML = [[UnityCoreML alloc] init];

extern "C" void UnityCoreML_LoadModel(const char* path) {
    NSLog(@"load model");
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithUTF8String:path]];
    [_unityCoreML loadModel:url];
}

extern "C" void UnityCoreML_Delegate(void* func) {
    NSLog(@"set delegate");
}

extern "C" void UnityCoreML_Predict_Texture(int32_t texPtr) {
    NSLog(@"start predict");
    
//    _unityCoreML
}
