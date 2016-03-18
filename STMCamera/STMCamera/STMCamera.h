//
//  STMCamera.h
//  STMCamera
//
//  Created by suntongmian on 16/3/17.
//  Copyright © 2016年 suntongmian@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class STMCamera;

@protocol STMCameraDelegate <NSObject>
@required

- (void)getCameraVideoOutput:(CVPixelBufferRef)pixelBufferRef;

@end


@interface STMCamera : NSObject

@property (nonatomic, weak) id<STMCameraDelegate> delegate;

- (void)setupCameraFPS:(int)fps sessionPreset:(NSString *)sessionPreset;
- (void)getCaptureVideoPreviewLayer:(AVCaptureVideoPreviewLayer**)captureVideoPreviewLayer;
- (void)stopCamera;

@end
