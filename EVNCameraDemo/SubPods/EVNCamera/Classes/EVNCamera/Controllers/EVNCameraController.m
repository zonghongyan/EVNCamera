//
//  EVNCameraController.m
//  EVNCamera
//
//  Created by developer on 2017/6/9.
//  Copyright © 2017年 仁伯. All rights reserved.
//

#import "EVNCameraController.h"
#import "EVNCameraWarnView.h"
#import "EVNCameraView.h"
#import "EVNCameraShowImageView.h"
#import "EVNCameraPlayMovieView.h"
#import "EVNCameraTakePhotosView.h"
#import "Masonry.h"

static NSString * const kGWCameraBundleName = @"EVNCamera.bundle";

@interface EVNCameraController () <EVNCameraShowImageViewDelegate, EVNCameraTakePhotosViewDelegate>

/// 取消拍摄
@property (nonatomic, strong) UIButton             *cancleButton;

/// 前置后置摄像头切换
@property (nonatomic, strong) UIButton             *swapButton;

/// 拍完照后的视图
@property (nonatomic, strong) EVNCameraShowImageView *showImageView;

/// 录制视频后的视图
@property (nonatomic, strong) EVNCameraPlayMovieView *playMovieView;

/// 拍照或录制小视频按钮
@property (nonatomic, strong) EVNCameraTakePhotosView *photoButton;

/// 提醒文字
@property (nonatomic, strong) EVNCameraWarnView       *cameraWarnView;

/// 相机视图
@property (nonatomic, strong) EVNCameraView           *cameraView;

@end
@implementation EVNCameraController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self customCameraView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

/**
 * MARK: 初始化相机所需视图
 */
- (void)customCameraView
{
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.cameraView];
    [self.view addSubview:self.photoButton];
    [self.view addSubview:self.cameraWarnView];
    [self.view addSubview:self.swapButton];
    [self.view addSubview:self.cancleButton];
    [self.view addSubview:self.showImageView];
    [self.view addSubview:self.playMovieView];
    [self.cameraView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.top.bottom.equalTo(self.view);
    }];
    
    [self.photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.height.equalTo(@110);
        make.centerX.equalTo(self.view.mas_centerX);
        if (@available(iOS 11.0, *)) {

            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-20);
        } else {
            make.bottom.equalTo(self.view.mas_bottom).offset(-20);
        }
    }];
    
    [self.cameraWarnView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.photoButton.mas_top).offset(-40);
        make.height.equalTo(@60);
    }];
    
    [self.swapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.height.equalTo(@45);
        make.right.equalTo(self.view.mas_right).offset(-40);
        make.centerY.equalTo(self.photoButton.mas_centerY);
    }];
    
    [self.cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.width.height.equalTo(self.swapButton.mas_height);
        make.left.equalTo(self.view.mas_left).offset(40);
        make.centerY.equalTo(self.photoButton.mas_centerY);
    }];
    
    [self.showImageView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.right.top.bottom.equalTo(self.view);
    }];
    
    [self.playMovieView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.top.bottom.equalTo(self.view);
    }];
}

#pragma mark - system delegate && datasource

#pragma mark - custom delegate
/// 拍照回调
/// @param faceDectCamera 当前对象
/// @param photo 照片
- (void)faceDectCamera:(EVNCameraView *)faceDectCamera didTakePhoto:(UIImage *)photo
{
    if (photo == nil) return;
    self.showImageView.image = photo;
    self.showImageView.hidden = NO;
}

/// 拍视频
/// @param faceDectCamera 当前对象
/// @param videoPath 视频缓存地址
- (void)faceDectCamera:(EVNCameraView *)faceDectCamera didTakeVideo:(NSURL *)videoPathURL
{
    if (videoPathURL == nil) return;
    self.playMovieView.hidden = NO;
    self.playMovieView.fileUrl = videoPathURL;
    [self.playMovieView play];
}

// MARK: GWCameraShowImageViewDelegate methods
// 重拍
- (void)didClickRetakeButonInView:(EVNCameraShowImageView *)showImageView
{
    [self.cameraView startCapture];
    self.showImageView.hidden = YES;
}

// 使用图片
- (void)didClickUseButtonInView:(EVNCameraShowImageView *)showImageView
{
    if ([self.delegate respondsToSelector:@selector(cameraController:didFinishShootWithCameraImage:)])
    {
        [self.delegate cameraController:self didFinishShootWithCameraImage:showImageView.image];
    }
}

// MARK: GWCameraTakePhotosViewDelegate methods
/// 事件回调
/// @param state 手势状态
- (void)actionTakePhotoWithCameraTakePhotoState:(EVNCameraTakePhotoState)state
{
    if (state == EVNCameraTakePhotoStateClick)
    {
        // 拍照
        [self.cameraView takePhoto];
    }
    else
    {
        // 开始长按
        if (state == EVNCameraTakePhotoStateBegin)
        {
            [self.cameraView startRecording];
        }
        // 正常结束
        else if (state == EVNCameraTakePhotoStateEnd)
        {
            [self.cameraView stopRecording];
        }
    }
}

// MARK: GWCameraPlayMovieViewDelegate methods
/// 重拍
- (void)didClickRetakeButonInPlayView:(EVNCameraPlayMovieView *)playMovieView
{
    [self.cameraView startCapture];
    [self.playMovieView pause];
    self.playMovieView.hidden = YES;
}

/// 发送视频
- (void)didClickSendButtonInPlayView:(EVNCameraPlayMovieView *)playMovieView
{
    if (_delegate && [_delegate respondsToSelector:@selector(cameraController:didFinishVideo:)])
    {
        [_delegate cameraController:self didFinishVideo:playMovieView.fileUrl];
    }    
}

#pragma mark - event && response

/// MARK: 切换摄像头，前置/后置
- (void)swapCamera:(UIButton *)sender
{
    [self.cameraView switchCamera];
}

#pragma mark - private methods
/// MARK: 取消拍摄
- (void)cancleButtonAction
{
//    [self.imageView removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getters && setters
- (EVNCameraWarnView *)cameraWarnView
{
    if (!_cameraWarnView)
    {
        _cameraWarnView = [[EVNCameraWarnView alloc] init];
        _cameraWarnView.hidden = !self.isShowWarn;
    }
    return _cameraWarnView;
}

/// 自定义相机视图
- (EVNCameraView *)cameraView
{
    if (!_cameraView)
    {
        _cameraView = [[EVNCameraView alloc] initWithFrame:CGRectZero position:AVCaptureDevicePositionBack];
        _cameraView.delegate = self;
        _cameraView.shouldScaleEnable = YES;
        _cameraView.shouldFocusEnable = YES;
        _cameraView.videoEnabled = self.videoEnabled;
    }
    return _cameraView;
}

- (EVNCameraTakePhotosView *)photoButton
{
    if (!_photoButton)
    {
        _photoButton = [[EVNCameraTakePhotosView alloc] init];
        _photoButton.videoEnabled = self.videoEnabled;
        _photoButton.delegate = self;
        // 最大录制时长默认15
        _photoButton.interval = self.maxInterval<= 0 ? 15 : self.maxInterval;
    }
    return _photoButton;
}

- (UIButton *)swapButton
{
    if (!_swapButton)
    {
        _swapButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_swapButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/swapButton.png", kGWCameraBundleName]] forState:UIControlStateNormal];
        _swapButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_swapButton addTarget:self action:@selector(swapCamera:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _swapButton;
}

- (UIButton *)cancleButton
{
    if (!_cancleButton)
    {
        _cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancleButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/closeButton.png", kGWCameraBundleName]] forState:UIControlStateNormal];

        _cancleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_cancleButton addTarget:self action:@selector(cancleButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancleButton;
}

- (EVNCameraShowImageView *)showImageView
{
    if (!_showImageView)
    {
        _showImageView = [[EVNCameraShowImageView alloc] init];
        _showImageView.delegate = self;
        _showImageView.hidden = YES;
    }
    return _showImageView;
}

- (EVNCameraPlayMovieView *)playMovieView
{
    if (!_playMovieView)
    {
        _playMovieView = [[EVNCameraPlayMovieView alloc] init];
        _playMovieView.delegate = self;
        _playMovieView.hidden = YES;
    }
    return _playMovieView;
}

- (void)setIsShowWarn:(BOOL)isShowWarn
{
    _isShowWarn = isShowWarn;
    self.cameraWarnView.hidden = !isShowWarn;
}

- (void)setIsSaveToAlbum:(BOOL)isSaveToAlbum
{
    _isSaveToAlbum = isSaveToAlbum;
    self.cameraView.isSaveToAlbum = isSaveToAlbum;
}

- (void)dealloc
{
    NSLog(@"%@, %s", NSStringFromClass([self class]), __func__);
}

@end
