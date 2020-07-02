//
//  EVNCameraController.h
//  EVNCamera
//
//  Created by developer on 2017/6/9.
//  Copyright © 2017年 仁伯. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EVNCameraController;

/**
 * 相机拍摄代理
 */
@protocol EVNCameraControllerDelegate <NSObject>


/// 拍照之使用图片回调
/// @param cameraController 相机对象
/// @param cameraImage 图片
- (void)cameraController:(EVNCameraController *)cameraController didFinishShootWithCameraImage:(UIImage *)cameraImage;


/// 录制之使用视频
/// @param cameraController 摄像机对象
/// @param videoURL 视频暂存本地的路径
- (void)cameraController:(EVNCameraController *)cameraController didFinishVideo:(NSURL *)videoURL;


@end


/**
 * 自定义相机视图控制器
 */
@interface EVNCameraController : UIViewController


@property (nonatomic, weak  ) id<EVNCameraControllerDelegate> delegate;

/// 是否允许视频拍摄
@property (nonatomic, getter=isVideoEnabled) BOOL videoEnabled;

/// 是否将图片或者视频保存到相册
@property (nonatomic, assign) BOOL isSaveToAlbum;

/// 是否需要提示
@property (nonatomic, assign) BOOL isShowWarn;

/// 最大录制时长时长
@property (nonatomic, assign) NSTimeInterval maxInterval;

@end

