//
//  STMCamera.m
//  STMCamera
//
//  Created by suntongmian on 16/3/17.
//  Copyright © 2016年 suntongmian@163.com. All rights reserved.
//

#import "STMCamera.h"

@interface STMCamera () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession            *captureSession;
    AVCaptureDevice             *captureDevice;
    AVCaptureDeviceInput        *captureDeviceInput;
    AVCaptureVideoDataOutput    *captureVideoDataOutput;
    
    AVCaptureVideoPreviewLayer  *videoPreviewLayer;
}
@end

@implementation STMCamera

// AVCaptureVideoDataOutputSampleBufferDelegate callback method
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    [self bufferCaptured:CMSampleBufferGetImageBuffer(sampleBuffer)];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        captureSession = nil;
        captureDevice = nil;
        captureDeviceInput = nil;
        captureVideoDataOutput = nil;
    }
    return self;
}

- (void)setupCameraFPS:(int)fps sessionPreset:(NSString *)sessionPreset {
    captureSession = [[AVCaptureSession alloc] init];
    if (sessionPreset) {
        captureSession.sessionPreset = sessionPreset;
    }
    
    captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *deviceError = nil;
    [captureDevice lockForConfiguration:&deviceError];
    /**
     * set capture frames per second
     */
    if (deviceError == nil) {
        if (captureDevice.activeFormat.videoSupportedFrameRateRanges) {
            [captureDevice setActiveVideoMinFrameDuration:CMTimeMake(1, fps)];
            [captureDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, fps)];
        } else {
            // handle deviceError
        }
    }
    [captureDevice unlockForConfiguration];
    
    NSError *inputError = nil;
    captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&inputError];
    
    captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    /**
     * about videoSettings
     * On iOS, the only supported key is kCVPixelBufferPixelFormatTypeKey. Supported pixel formats are kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, kCVPixelFormatType_420YpCbCr8BiPlanarFullRange and kCVPixelFormatType_32BGRA.
     */
    captureVideoDataOutput.videoSettings = @{(NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
    
    dispatch_queue_t cameraQueue = dispatch_queue_create("com.camera.queue", NULL);
    [captureVideoDataOutput setSampleBufferDelegate:self queue:cameraQueue];
    
    if ([captureSession canAddInput:captureDeviceInput]) {
        [captureSession addInput:captureDeviceInput];
    }
    if ([captureSession canAddOutput:captureVideoDataOutput]) {
        [captureSession addOutput:captureVideoDataOutput];
    }
    
    [captureSession startRunning];
}

- (void)getCaptureVideoPreviewLayer:(AVCaptureVideoPreviewLayer**)captureVideoPreviewLayer {
    videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    *captureVideoPreviewLayer = videoPreviewLayer;
}

- (void)stopCamera {
    [captureSession stopRunning];
    [videoPreviewLayer removeFromSuperlayer];
    captureSession = nil;
    captureDevice = nil;
    captureDeviceInput = nil;
    captureVideoDataOutput = nil;
}

/*--------------------------------------------------------*/
// --- private functions
- (void)bufferCaptured:(CVPixelBufferRef)pixelBuffer {
    /*
     int pixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer);
     switch (pixelFormat) {
     case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
     NSLog(@"capture pixel format=kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange");
     break;
     case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:
     NSLog(@"capture pixel format=kCVPixelFormatType_420YpCbCr8BiPlanarFullRange");
     break;
     default:
     NSLog(@"capture pixel format=kCVPixelFormatType_32BGRA");
     break;
     }
     */
    
    [self.delegate getCameraVideoOutput:pixelBuffer];
}

@end
