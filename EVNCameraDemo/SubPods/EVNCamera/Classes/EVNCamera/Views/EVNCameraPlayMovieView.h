//
//  EVNCameraController.h
//  EVNCamera
//
//  Created by developer on 2017/6/9.
//  Copyright © 2017年 仁伯. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EVNCameraPlayMovieViewDelegate;

@interface EVNCameraPlayMovieView : UIView

@property (nonatomic, strong) NSURL *fileUrl;

@property (nonatomic, assign) id<EVNCameraPlayMovieViewDelegate> delegate;

- (void)play;

- (void)pause;

@end


@protocol EVNCameraPlayMovieViewDelegate <NSObject>

/// 重拍
- (void)didClickRetakeButonInPlayView:(EVNCameraPlayMovieView *)playMovieView;

/// 发送视频
- (void)didClickSendButtonInPlayView:(EVNCameraPlayMovieView *)playMovieView;

@end
