//
//  EVNCameraController.m
//  EVNCamera
//
//  Created by developer on 2017/6/9.
//  Copyright © 2017年 仁伯安. All rights reserved.
//

#import "EVNCameraController.h"
#import <AVFoundation/AVFoundation.h>
//#import <CoreMotion/CoreMotion.h>

#define kEVNScreenWidth [UIScreen mainScreen].bounds.size.width
#define kEVNScreenHeight [UIScreen mainScreen].bounds.size.height

@interface EVNCameraController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    BOOL isflashOn; // 是否开启了闪光灯
}

/**
 * 捕获设备，通常是前置摄像头，后置摄像头
 */
@property (nonatomic, strong) AVCaptureDevice *device;

/**
 * AVCaptureDeviceInput: 输入设备, 使用AVCaptureDevice初始化
 */
@property (nonatomic, strong) AVCaptureDeviceInput *input;

/**
 * 捕捉摄像头输出
 */
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutPut;

/**
 * 启动捕获摄像头
 */
@property (nonatomic, strong) AVCaptureSession *session;

/**
 * 实时捕获图像层，图片预览
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

/**
 * 白圈拍照
 */
@property (nonatomic, strong) UIButton *photoButton;

/**
 * 开启闪光灯按钮
 */
@property (nonatomic, strong) UIButton *flashButton;

/**
 * 拍摄成功后回显到屏幕
 */
@property (nonatomic, strong) UIImageView *imageView;

/**
 * 对焦绿框
 */
@property (nonatomic, strong) UIView *focusView;

/**
 * 拍的图片数据
 */
@property (nonatomic, strong) UIImage *image;

/**
 * 是否开启相机权限
 */
@property (nonatomic, assign) BOOL canUseCamera;

/**
 * 取消拍摄
 */
@property (nonatomic, strong) UIButton *cancleButton;

/**
 * 前置后置摄像头切换
 */
@property (nonatomic, strong) UIButton *swapButton;

/**
 * 重新拍摄
 */
@property (nonatomic, strong) UIButton *againTakePictureBtn;

/**
 * 使用图片
 */
@property (nonatomic, strong) UIButton *usePictureBtn;




@end

@implementation EVNCameraController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if (self.isCanUseCamera)
    {
        [self customCamera];
        [self customCameraView];
    }
    else
    {
        return;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"%ld", (long)toInterfaceOrientation);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // MARK: 第一次启动自动对焦
    [self focusAtPoint:CGPointMake(kEVNScreenWidth/2.0f, kEVNScreenHeight/2.0f)];
}

/**
 * MARK: 是否开启相机权限
 @return 返回canUseCamera
 */
- (BOOL)isCanUseCamera
{
    if (!_canUseCamera)
    {
        _canUseCamera = [self validateCanUseCamera];
    }
    return _canUseCamera;
}


/**
 * MARK: 初始化相机所需视图
 */
- (void)customCameraView
{
    _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _photoButton.frame = CGRectMake(kEVNScreenWidth/2.0-30, kEVNScreenHeight-100, 60, 60);
    [_photoButton setImage:[UIImage imageNamed:@"EVNCamera.bundle/photo.png"] forState: UIControlStateNormal];
    [_photoButton setImage:[UIImage imageNamed:@"EVNCamera.bundle/photoSelect.png"] forState:UIControlStateNormal];
    [_photoButton addTarget:self action:@selector(shutterCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_photoButton];

    _focusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    _focusView.layer.borderWidth = 0.51;
    _focusView.backgroundColor = [UIColor clearColor];
    _focusView.layer.borderColor = [UIColor greenColor].CGColor;
    [self.view addSubview:_focusView];
    _focusView.hidden = YES;

    _cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancleButton.frame = CGRectMake(32, kEVNScreenHeight-92.5, 45, 45);
    [_cancleButton setImage:[UIImage imageNamed:@"EVNCamera.bundle/closeButton.png"] forState:UIControlStateNormal];

    _cancleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_cancleButton addTarget:self action:@selector(cancleButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancleButton];


    _againTakePictureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _againTakePictureBtn.frame = CGRectMake(32, kEVNScreenHeight-85, 45, 30);
    _againTakePictureBtn.backgroundColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:56/255.0 alpha:0.66];
    [_againTakePictureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_againTakePictureBtn setTitle:@"重拍" forState:UIControlStateNormal];
    _againTakePictureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _againTakePictureBtn.hidden = YES;
    _againTakePictureBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _againTakePictureBtn.layer.cornerRadius = 5;
    [_againTakePictureBtn addTarget:self action:@selector(againTakePictureBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_againTakePictureBtn];

    _usePictureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _usePictureBtn.backgroundColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:56/255.0 alpha:0.66];
    [_usePictureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _usePictureBtn.frame = CGRectMake(kEVNScreenWidth - 112, _againTakePictureBtn.frame.origin.y, 80, _againTakePictureBtn.frame.size.height);
    [_usePictureBtn setTitle:@"使用图片" forState:UIControlStateNormal];
    _usePictureBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _usePictureBtn.hidden = YES;
    _usePictureBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    _usePictureBtn.layer.cornerRadius = 5;
    [_usePictureBtn addTarget:self action:@selector(usePictureBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_usePictureBtn];


    _swapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _swapButton.frame = CGRectMake(kEVNScreenWidth - 77, 44, 45, 45);
    [_swapButton setImage:[UIImage imageNamed:@"EVNCamera.bundle/swapButton.png"] forState:UIControlStateNormal];
    _swapButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_swapButton addTarget:self action:@selector(swapCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_swapButton];

    _flashButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _flashButton.tintColor = [UIColor whiteColor];
    _flashButton.frame = CGRectMake(_cancleButton.frame.origin.x, _swapButton.frame.origin.y, _swapButton.frame.size.width, _swapButton.frame.size.height);
    [_flashButton setImage:[UIImage imageNamed:@"EVNCamera.bundle/cameraFlash.png"] forState:UIControlStateNormal];
    [_flashButton addTarget:self action:@selector(flashOn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashButton];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}


- (AVCaptureSession *)extracted {
    return self.session;
}

/**
 * 自定义相机
 */
- (void)customCamera
{
    self.view.backgroundColor = [UIColor whiteColor];

    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]; // 使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化

    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil]; // 使用设备初始化输入

    self.imageOutPut = [[AVCaptureStillImageOutput alloc] init];

    self.session = [[AVCaptureSession alloc] init]; // 生成会话，用来结合输入输出
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720])
    {
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    if ([self.session canAddInput:self.input])
    {
        [[self extracted] addInput:self.input];
    }

    if ([self.session canAddOutput:self.imageOutPut])
    {
        [self.session addOutput:self.imageOutPut];
    }

    // 使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = CGRectMake(0, 0, kEVNScreenWidth, kEVNScreenHeight);
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];

    [self.session startRunning]; // 开始启动
    if ([_device lockForConfiguration:nil])
    {
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto])
        {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) // 自动白平衡
        {
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
}


/**
 * MARK: 开启关闭闪光灯
 @param sender 闪光灯Button
 */
- (void)flashOn:(UIButton *)sender
{
    if ([_device lockForConfiguration:nil])
    {
        if (isflashOn)
        {
            if ([_device isFlashModeSupported:AVCaptureFlashModeOff])
            {
                sender.selected = NO;
                sender.tintColor = [UIColor whiteColor];
                [_device setFlashMode:AVCaptureFlashModeOff];
                isflashOn = NO;
            }
        }
        else
        {
            if ([_device isFlashModeSupported:AVCaptureFlashModeOn])
            {
                sender.selected = YES;
                sender.tintColor = [UIColor yellowColor];
                [_device setFlashMode:AVCaptureFlashModeOn];
                isflashOn = YES;

            }
        }
        [_device unlockForConfiguration];
    }
}

/**
 * 切换摄像头，前置/后置
 */
- (void)swapCamera:(UIButton *)sender
{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1)
    {
        NSError *error;

        CATransition *animation = [CATransition animation];

        animation.duration = .5f;

        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

        animation.type = @"oglFlip";
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[_input device] position];
        if (position == AVCaptureDevicePositionFront)
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
        }
        else
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
        }

        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.previewLayer addAnimation:animation forKey:nil];
        if (newInput != nil)
        {
            [self.session beginConfiguration];
            [self.session removeInput:_input];
            if ([self.session canAddInput:newInput])
            {
                [self.session addInput:newInput];
                self.input = newInput;
            }
            else
            {
                [self.session addInput:self.input];
            }

            [self.session commitConfiguration];

        }
        else if (error)
        {
            NSLog(@"切换相机失败, error = %@", error);
        }
    }
}


/**
 * MARK: 摄像头切换操作
 @param position 摄像头位置，前置:AVCaptureDevicePositionFront 后置:AVCaptureDevicePositionBack
 @return AVCaptureDevice
 */
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices )
    {
        if (device.position == position)
        {
            return device;
        }
    }
    return nil;
}

/**
 * MARK: 对焦手势，获取对焦坐标
 @param gesture tap手势
 */
- (void)focusGesture:(UITapGestureRecognizer*)gesture
{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}


/**
 * MARK: 对焦
 @param point 对焦的坐标点
 */
- (void)focusAtPoint:(CGPoint)point
{
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error])
    {

        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus])
        {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }

        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ])
        {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }

        [self.device unlockForConfiguration];
        _focusView.center = point;
        _focusView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _focusView.transform = CGAffineTransformMakeScale(1.25, 1.25);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                _focusView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                _focusView.hidden = YES;
            }];
        }];
    }
}

/**
 * MARK: 截取图片
 */
- (void)shutterCamera:(UIButton *)sender
{
    AVCaptureConnection * videoConnection = [self.imageOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection)
    {
        NSLog(@"拍照失败!");
        return;
    }

    [self.imageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error){

        if (imageDataSampleBuffer == NULL) return;

        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        self.image = [UIImage imageWithData:imageData];
        [self.session stopRunning]; // 停止会话

        self.imageView = [[UIImageView alloc] initWithFrame:self.previewLayer.frame];
        [self.view insertSubview:_imageView belowSubview:sender];
        self.imageView.layer.masksToBounds = YES;
        self.imageView.image = _image;

        // 隐藏切换取消闪光灯按钮
        _swapButton.hidden = YES;
        _cancleButton.hidden = YES;
        _flashButton.hidden = YES;

        _againTakePictureBtn.hidden = NO;
        _usePictureBtn.hidden = NO;
    }];
}

/**
 * MARK: 重新拍摄
 @param sender 重新拍摄按钮
 */
- (void)againTakePictureBtn:(UIButton *)sender
{
    NSLog(@"重新拍摄");
    [self.session startRunning];
    [self.imageView removeFromSuperview];
    self.imageView = nil;

    _swapButton.hidden = NO;
    _cancleButton.hidden = NO;
    _flashButton.hidden = NO;

    _againTakePictureBtn.hidden = YES;
    _usePictureBtn.hidden = YES;
}

/**
 * MARK: 重新拍摄
 @param sender sender
 */
- (void)usePictureBtn:(UIButton *)sender
{
    NSLog(@"使用图片");
    // MARK: 保存至相册
    UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(cameraImage:didFinishSavingWithError:contextInfo:), NULL);
    [self cancleButtonAction];
}

/**
 * MARK: 指定回调方法
 @param cameraImage image
 @param error error
 @param contextInfo contextInfo
 */
- (void)cameraImage:(UIImage *)cameraImage didFinishSavingWithError:(NSError *)error contextInfo:(NSDictionary<NSString *,id> *)contextInfo
{
    if(error != NULL)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"保存图片失败" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [rootViewController presentViewController:alertController animated:NO completion:nil];
    }
    else
    {
        if ([self.cameraControllerDelegate respondsToSelector:@selector(cameraDidFinishShootWithCameraImage:)])
        {
            [self.cameraControllerDelegate cameraDidFinishShootWithCameraImage:cameraImage];
        }
    }
}

/**
 * MARK: 取消拍摄
 */
- (void)cancleButtonAction
{
    [self.imageView removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 * MARK: 检查相机权限
 @return 是否检查相机权限
 */
- (BOOL)validateCanUseCamera
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied)
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请打开相机权限" message:@"请到设置中去允许应用访问您的相机: 设置-隐私-相机" preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"不需要" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 跳转至设置开启权限
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];

        UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [rootViewController presentViewController:alertController animated:NO completion:nil];
        return NO;
    }
    else
    {
        return YES;
    }
}

// 开始晃动的时候触发
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"开始晃动");
}

// 结束晃动的时候触发
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"晃动结束");
}

// 中断晃动的时候触发
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"取消晃动,晃动终止");
}

- (void)dealloc
{
    NSLog(@"%@, %s", NSStringFromClass([self class]), __func__);
}






@end
