//
//  EVNCameraTakePhotosView.h
//  EVNCamera
//
//  Created by developer on 2017/6/9.
//  Copyright © 2017年 仁伯. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, EVNCameraTakePhotoState)
{
    /// 开始长按
    EVNCameraTakePhotoStateBegin = 0,
    /// 移动
    EVNCameraTakePhotoStateMoving,
    /// 将要取消
    EVNCameraTakePhotoStateWillCancel,
    /// 已经取消
    EVNCameraTakePhotoStateDidCancel,
    /// 正常结束
    EVNCameraTakePhotoStateEnd,
    /// 单击
    EVNCameraTakePhotoStateClick,
};


@protocol EVNCameraTakePhotosViewDelegate <NSObject>

/// 事件回调
/// @param state 手势状态
- (void)actionTakePhotoWithCameraTakePhotoState:(EVNCameraTakePhotoState)state;


@end

/// 拍照或者视频录制按钮
@interface EVNCameraTakePhotosView : UIView

@property (nonatomic, weak) id <EVNCameraTakePhotosViewDelegate> delegate;

/// 是否允许视频拍摄
@property (nonatomic, getter=isVideoEnabled) BOOL videoEnabled;

/// 计时时长
@property (nonatomic, assign) NSTimeInterval interval;

/// 中间圆点的颜色
@property (nonatomic, strong) UIColor *centerColor;

/// 圆环的颜色
@property (nonatomic, strong) UIColor *ringColor;

/// 进度条的颜色
@property (nonatomic, strong) UIColor *progressColor;


@end
