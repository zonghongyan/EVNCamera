//
//  EVNCameraView.m
//  EVNCamera
//
//  Created by developer on 2017/6/9.
//

#import "EVNCameraView.h"
#import "Masonry.h"
#import "EVNCameraUtil.h"

/// 资源的名称
static NSString * const kGWCameraBundleName = @"EVNCamera.bundle";
/// 动画间隔
static CGFloat GWFaceCameraAnimationDuration = 0.3;

@interface EVNCameraView ()<UIGestureRecognizerDelegate, AVCaptureFileOutputRecordingDelegate>
{
    CGFloat _currentZoomFactor;
}

/// 前置后置
@property (nonatomic, assign) AVCaptureDevicePosition     position;
/// 闪光灯模式
@property (nonatomic, assign) AVCaptureTorchMode         flashMode;

/// 捕捉设备
@property (nonatomic, strong) AVCaptureDevice            *captureDevice;

@property (nonatomic, strong) AVCaptureSession           *captureSession;

/// 视频输入输出
@property (nonatomic, strong) AVCaptureDeviceInput       *deviceInput;

/// 照片输出
@property (nonatomic, strong) AVCaptureStillImageOutput  *captureStillImageOutput;
@property (nonatomic, strong) AVCapturePhotoOutput       *imageOutput API_AVAILABLE(ios(10.0));

/// 视频输出
@property (nonatomic, strong) AVCaptureMovieFileOutput   *captureMovieFileOutput;

/// 拍照预览
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, assign) CGPoint                     focusPoint;

/// 切换摄像头时模糊
@property (nonatomic, strong) UIVisualEffectView          *blurView;

/// 聚焦图片
@property (nonatomic, strong) UIImageView                 *focusImageView;

/// 单击手势，聚焦使用
@property (nonatomic, strong) UITapGestureRecognizer      *tapGesture;

/// 捏合手势，放大缩小焦距使用
@property (nonatomic, strong) UIPinchGestureRecognizer    *pinGesture;

/// 视频地址
@property (nonatomic, strong) NSURL                       *recodingURL;

/// 拍摄后获取的的图像方向
@property (nonatomic, assign) UIImageOrientation           imgOrientation;

@end
@implementation EVNCameraView

- (instancetype)initWithFrame:(CGRect)frame position:(AVCaptureDevicePosition)position
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _position = position;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.layer addSublayer:self.previewLayer];
        [self addSubview:self.blurView];
        [self addSubview:self.focusImageView];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:self.tapGesture];
        [self startCapture];
        self.flashMode = AVCaptureFlashModeAuto;
        self.imgOrientation = UIImageOrientationUp;
    });
}

- (void)startCapture
{
    if (!self.captureSession.isRunning) {
        [self.captureSession startRunning];
    }
}

- (void)stopCapture
{
    if (self.captureSession.isRunning) {
        [self.captureSession stopRunning];
    }
}

- (void)switchCamera
{
    [self.captureSession stopRunning];
    
    AVCaptureDevicePosition newPosition = _position == AVCaptureDevicePositionFront ? AVCaptureDevicePositionBack : AVCaptureDevicePositionFront;
    _position = newPosition;
    
    // 如果前置,自动关闭闪光灯
    if (newPosition == AVCaptureDevicePositionFront) {
        
        [self.captureDevice lockForConfiguration:nil];
        self.captureDevice.torchMode = AVCaptureTorchModeOff;
        [self.captureDevice unlockForConfiguration];
    }
    
    [self.captureSession removeInput:self.deviceInput];
    self.captureDevice = nil;
    self.deviceInput = nil;
    
    if ([self.captureSession canAddInput:self.deviceInput]) {
        [self.captureSession addInput:self.deviceInput];
    }
    
    [self.captureSession beginConfiguration];
    if ([self.captureDevice lockForConfiguration:nil]) {
        // 采样帧频
        [self.captureDevice setActiveVideoMinFrameDuration:CMTimeMake(1, 30)];
        [self.captureDevice unlockForConfiguration];
    }
    [self.captureSession commitConfiguration];
    [self.captureSession startRunning];
    
    self.blurView.hidden = NO;
    self.imgOrientation = _position == AVCaptureDevicePositionFront ? UIImageOrientationLeftMirrored : UIImageOrientationUp;
    __weak __typeof(self)weakSelf = self;
    [UIView transitionWithView:self duration:GWFaceCameraAnimationDuration options:_position == AVCaptureDevicePositionFront ? UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        
    } completion:^(BOOL finished) {
        
        if (finished) {
            weakSelf.blurView.hidden = YES;
        }
    }];
}

// 拍照，将当前采样模式切换为拍照
- (void)takePhoto
{
    if (@available(iOS 10.0, *))
    {
        NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecJPEG};
        AVCapturePhotoSettings *outputSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
        [self.imageOutput capturePhotoWithSettings:outputSettings delegate:self];
    }
    else
    {
        //根据设备输出获得连接。
        AVCaptureConnection *captureConnection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        if (!captureConnection) {
            NSLog(@"拍照失败！");
            return;
        }
        __weak __typeof(self)weakSelf = self;
        [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (imageDataSampleBuffer == nil) {
                NSLog(@"获取照片失败！");
                return;
            }
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage * tempImage = [UIImage imageWithData:imageData];
            
            UIImage *photoImage = nil;
            if (weakSelf.imgOrientation == UIImageOrientationUp) {
                photoImage = tempImage;
            }
            else
            {
                photoImage = [[UIImage alloc] initWithCGImage:tempImage.CGImage scale:1.0f orientation:weakSelf.imgOrientation];
            }
            
            if (self.isSaveToAlbum)
            {
                [EVNCameraUtil saveImage:photoImage completionHandler:^(BOOL success, NSError * _Nullable error) {
                    success ? NSLog(@"已将图片保存至相册") : NSLog(@"未能保存图片到相册");
                }];
            }
            
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(faceDectCamera:didTakePhoto:)]) {
                [weakSelf.delegate faceDectCamera:weakSelf didTakePhoto:photoImage];
            }
            [weakSelf stopCapture];
        }];
    }
    
}

#pragma mark - capture
/// 开始录制
- (void)startRecording
{
    // 根据设备输出获得连接。
    AVCaptureConnection *captureConnection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!captureConnection) {
        NSLog(@"录像失败！");
        return;
    }
    if (![self.captureMovieFileOutput isRecording])
    {
        self.recodingURL = [NSURL fileURLWithPath:[self buildVideoPath]];
        [self.captureMovieFileOutput startRecordingToOutputFileURL:self.recodingURL recordingDelegate:self];
    }
}

/// 结束录制
- (void)stopRecording
{
    if ([self.captureMovieFileOutput isRecording]) {
        [self.captureMovieFileOutput stopRecording];
    }
}

- (void)switchFlash
{
    AVCaptureTorchMode newMode = AVCaptureTorchModeOff;
    if (self.captureDevice.torchMode == AVCaptureTorchModeOff) {
        newMode = AVCaptureTorchModeAuto;
    } else if (self.captureDevice.torchMode == AVCaptureTorchModeAuto) {
        newMode = AVCaptureTorchModeOn;
    } else {
        newMode = AVCaptureTorchModeOff;
    }
    
    [self.captureDevice lockForConfiguration:nil];
    self.captureDevice.torchMode = newMode;
    [self.captureDevice unlockForConfiguration];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.previewLayer.frame = self.bounds;
}

- (void)setVideoZoom:(CGFloat)zoom
{
    if (self.captureDevice.activeFormat.videoMaxZoomFactor > zoom && zoom >= 1.0) {
        [self.captureDevice lockForConfiguration:nil];
        [self.captureDevice rampToVideoZoomFactor:zoom withRate:4.0];
        [self.captureDevice unlockForConfiguration];
    }
    
    if (zoom < 1.0 && self.captureDevice.videoZoomFactor >= 1) {
        [self.captureDevice lockForConfiguration:nil];
        [self.captureDevice rampToVideoZoomFactor:(self.captureDevice.videoZoomFactor - zoom) withRate:4.0];
        [self.captureDevice unlockForConfiguration];
    }
}

- (void)actionTapGesture:(UITapGestureRecognizer *)sender
{
    self.focusImageView.hidden = NO;
    // 单击的焦点
    CGPoint center = [sender locationInView:sender.view];
    CGFloat xValue = center.y / self.bounds.size.height;
    CGFloat yValue = _position == AVCaptureDevicePositionFront ? (center.x / self.bounds.size.width) : (1 - center.x / self.bounds.size.width);
    self.focusPoint = CGPointMake(xValue,yValue);
    self.focusImageView.center = center;
    self.focusImageView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:GWFaceCameraAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
        self.focusImageView.transform = CGAffineTransformMakeScale(0.67, 0.67);
    } completion:nil];
    
    [self hidenFocusImageView];
}

/// 隐藏聚焦视图
- (void)hidenFocusImageView
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.focusImageView.hidden = YES;
        });
    });
}

/// 手势捏合设置摄像机远近
/// @param sender UIPinchGestureRecognizer
- (void)actionPinGesture:(UIPinchGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
        CGFloat currentZoomFactor = _currentZoomFactor * sender.scale;
        if (currentZoomFactor < self.captureDevice.activeFormat.videoMaxZoomFactor && currentZoomFactor > 1.0) {
            [self setVideoZoom:currentZoomFactor];
        }
    }
}

#pragma mark - delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    NSLog(@"start record video");
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"end record");
    if (!error)
    {
        NSString *path = [NSString stringWithFormat:@"%@", outputFileURL];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(faceDectCamera:didTakeVideo:)])
        {
            [self.delegate faceDectCamera:self didTakeVideo:outputFileURL];
        }
        
        if (self.isSaveToAlbum)
        {
            // 将视频保存到相册
            [EVNCameraUtil cameraUtilSaveVideoUrl:outputFileURL completionHandler:^(BOOL success, NSError * _Nullable saveError) {
                success ? NSLog(@"已将视频保存至相册") : NSLog(@"未能保存视频到相册");
            }];
        }
        [self stopCapture];
    }
    else
    {
        NSLog(@"录制失败");
    }
}

- (void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings error:(nullable NSError *)error API_AVAILABLE(ios(10.0))
{
    if (!photoSampleBuffer || error)
    {
        return;
    }
    NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
    UIImage *tempImage = [UIImage imageWithData:data];
    UIImage *photoImage = nil;
    if (self.imgOrientation == UIImageOrientationUp) {
        photoImage = tempImage;
    }
    else
    {
        photoImage = [[UIImage alloc] initWithCGImage:tempImage.CGImage scale:1.0f orientation:self.imgOrientation];
    }
    
    if (self.isSaveToAlbum)
    {
        [EVNCameraUtil saveImage:photoImage completionHandler:^(BOOL success, NSError * _Nullable error) {
            success ? NSLog(@"已将图片保存至相册") : NSLog(@"未能保存图片到相册");
        }];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceDectCamera:didTakePhoto:)]) {
        [self.delegate faceDectCamera:self didTakePhoto:photoImage];
    }
    [self stopCapture];
}

#pragma mark - setter && getter
- (AVCaptureDevice *)captureDevice
{
    if (!_captureDevice)
    {
        _captureDevice = [self captureDeviceWithPosition:_position];
    }
    return _captureDevice;
}

- (AVCaptureDeviceInput *)deviceInput
{
    if (!_deviceInput)
    {
        _deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureDevice error:nil];
    }
    return _deviceInput;
}

- (AVCaptureSession *)captureSession
{
    if (!_captureSession)
    {
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
        //初始化输出。
        self.captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([_captureSession canAddInput:self.deviceInput]) {
            [_captureSession addInput:self.deviceInput];
        }
        if (self.isVideoEnabled)
        {
            NSError *error = nil;
            //初始化音频输入对象
            AVCaptureDevice *audioCatureDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
            error = nil;
            AVCaptureDeviceInput *audioCaptureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioCatureDevice error:&error];
            if ([_captureSession canAddInput:audioCaptureDeviceInput]) {
                [_captureSession addInput:audioCaptureDeviceInput];
            }
        }
        
        if (@available(iOS 10.0, *))
        {
            self.imageOutput = [[AVCapturePhotoOutput alloc] init];
            NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecJPEG};
            AVCapturePhotoSettings *outputSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
            [self.imageOutput setPhotoSettingsForSceneMonitoring:outputSettings];
            if ([_captureSession canAddOutput:self.imageOutput])
            {
                [_captureSession addOutput:self.imageOutput];
            }
        }
        else
        {
            self.captureStillImageOutput = [[AVCaptureStillImageOutput alloc]init];
            if ([_captureSession canAddOutput:self.captureStillImageOutput]) {
                [_captureSession addOutput:self.captureStillImageOutput];
            }
        }
        
        if ([_captureSession canAddOutput:self.captureMovieFileOutput]) {
            [_captureSession addOutput:self.captureMovieFileOutput];
        }
        [_captureSession beginConfiguration];
        if ([self.captureDevice lockForConfiguration:nil]) {
            [self.captureDevice setActiveVideoMinFrameDuration:CMTimeMake(1, 30)];
            [self.captureDevice unlockForConfiguration];
        }
        [_captureSession commitConfiguration];
    }
    return _captureSession;
}

- (NSString *)buildVideoPath
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddhhmmssSSS"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSString *videoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",dateString]];
    return videoPath;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (!_previewLayer)
    {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        _previewLayer.frame = self.bounds;
    }
    return _previewLayer;
}

- (AVCaptureDevice *)captureDeviceWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = nil;
    if (@available(iOS 10.0, *))
    {
        AVCaptureDeviceDiscoverySession *deviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
        devices  = deviceDiscoverySession.devices;
    }
    else
    {
        devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    }
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (UIVisualEffectView *)blurView
{
    if (!_blurView)
    {
        UIBlurEffect * effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
        _blurView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height);
        _blurView.hidden = YES;
    }
    return _blurView;
}

- (UIImageView *)focusImageView
{
    if (!_focusImageView)
    {
        _focusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/camera_focus", kGWCameraBundleName]]];
        _focusImageView.contentMode = UIViewContentModeScaleAspectFit;
        _focusImageView.frame = CGRectMake(0, 0, 70, 70);
        _focusImageView.center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);
        _focusImageView.hidden = YES;
    }
    return _focusImageView;
}

- (UITapGestureRecognizer *)tapGesture
{
    if (!_tapGesture)
    {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
    }
    return _tapGesture;
}

- (UIPinchGestureRecognizer *)pinGesture
{
    if (!_pinGesture)
    {
        _pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(actionPinGesture:)];
        _pinGesture.delegate = self;
    }
    return _pinGesture;
}

#pragma mark - Gesture
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.pinGesture) {
        _currentZoomFactor = self.captureDevice.videoZoomFactor;
    }
    return YES;
}

#pragma mark - Setter
- (void)setFocusPoint:(CGPoint)focusPoint
{
    _focusPoint = focusPoint;
    
    if (!self.captureDevice.focusPointOfInterestSupported) return;
    if (![self.captureDevice lockForConfiguration:nil]) return;
    self.captureDevice.focusPointOfInterest = focusPoint;
    self.captureDevice.focusMode = AVCaptureFocusModeAutoFocus;
    [self.captureDevice unlockForConfiguration];
}

- (void)setFocusImage:(UIImage *)focusImage
{
    _focusImage = focusImage;
    self.focusImageView.image = focusImage;
}

- (void)setShouldScaleEnable:(BOOL)shouldScaleEnable
{
    _shouldScaleEnable = shouldScaleEnable;
    
    if (shouldScaleEnable) {
        [self addGestureRecognizer:self.pinGesture];
    } else {
        [self removeGestureRecognizer:self.pinGesture];
    }
}

- (void)setShouldFocusEnable:(BOOL)shouldFocusEnable
{
    _shouldFocusEnable = shouldFocusEnable;
    
    if (shouldFocusEnable)
    {
        [self addGestureRecognizer:self.tapGesture];
    }
    else
    {
        [self removeGestureRecognizer:self.tapGesture];
    }
}

- (AVCaptureTorchMode)flashMode
{
    return self.captureDevice.torchMode;
}

@end
