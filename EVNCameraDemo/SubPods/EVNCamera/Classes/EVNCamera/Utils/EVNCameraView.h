//
//  GWFaceCameraView.h
//  EVNCamera
//
//  Created by developer on 2017/6/9.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
@class EVNCameraView;

@protocol EVNCameraViewDelegate <NSObject>

@optional
/**
  相机采集流
  @parma faceDectCamera 当前对象
  @param sampleBuffer 流
 */
- (void)faceDectCamera:(EVNCameraView *)faceDectCamera didOutputVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/// 拍照回调
/// @param faceDectCamera 当前对象
/// @param photo 照片
- (void)faceDectCamera:(EVNCameraView *)faceDectCamera didTakePhoto:(UIImage *)photo;

/// 拍视频
/// @param faceDectCamera 当前对象
/// @param videoPath 视频缓存地址
- (void)faceDectCamera:(EVNCameraView *)faceDectCamera didTakeVideo:(NSURL *)videoPathURL;

@end

// Info.plist Privacy - Camera Usage Description Privacy - Microphone Usage Description
@interface EVNCameraView : UIView

@property (nonatomic) CMSampleBufferRef latestSampleBuffer;

@property (nonatomic, weak) id<EVNCameraViewDelegate> delegate;

/// 闪光灯模式
@property (nonatomic, assign, readonly) AVCaptureTorchMode flashMode;

/// 摄像头位置
@property (nonatomic, assign, readonly) AVCaptureDevicePosition position;

/// 是否捏合缩放,默认NO
@property (nonatomic, assign) BOOL shouldScaleEnable;

/// 是否点击为聚焦点, 默认YES
@property (nonatomic, assign) BOOL shouldFocusEnable;


/// 聚焦点图片, 如果需要设置的赋值, 否则使用默认
@property (nonatomic, strong) UIImage *focusImage;


/**
  初始化
  @param frame 坐标
  @param mode 相机模式
  @param position 摄像头方向
 */
- (instancetype)initWithFrame:(CGRect)frame position:(AVCaptureDevicePosition)position;

/// 开始捕捉
- (void)startCapture;

/// 停止捕捉
- (void)stopCapture;

/// 点击拍照
- (void)takePhoto;

/// 转换摄像头
- (void)switchCamera;

/// 切换闪光灯
- (void)switchFlash;

/// 是否允许视频拍摄
@property (nonatomic, getter=isVideoEnabled) BOOL videoEnabled;

/// 是否保存到相册
@property (nonatomic, assign) BOOL isSaveToAlbum;

/// 开始录制视频
- (void)startRecording;

/// 停止录制
- (void)stopRecording;


@end

NS_ASSUME_NONNULL_END
