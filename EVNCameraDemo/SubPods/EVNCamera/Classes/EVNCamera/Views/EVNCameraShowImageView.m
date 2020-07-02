//
//  EVNCameraShowImageView.h
//  EVNCamera
//
//  Created by developer on 2017/6/9.
//  Copyright © 2017年 仁伯. All rights reserved.
//

#import "EVNCameraShowImageView.h"
#import "Masonry.h"

static NSString * const kGWCameraBundleName = @"EVNCamera.bundle";

@interface EVNCameraShowImageView()<UIGestureRecognizerDelegate>

@end
@implementation EVNCameraShowImageView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor blackColor];
        self.contentMode = UIViewContentModeScaleAspectFit;//UIViewContentModeScaleAspectFill;
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    UIImageView *whiteView = [[UIImageView alloc] init];
    whiteView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@/camea_round_gray", kGWCameraBundleName]];
    UITapGestureRecognizer *retakeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(retakeAction)];
    retakeTap.delegate = self;
    [whiteView addGestureRecognizer:retakeTap];
    whiteView.userInteractionEnabled = YES;
    [self addSubview:whiteView];
    UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    retakeButton.backgroundColor = [UIColor clearColor];
    retakeButton.center = whiteView.center;
    [retakeButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/camera_retake", kGWCameraBundleName]] forState:UIControlStateNormal];
    [retakeButton addTarget:self action:@selector(retakeAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:retakeButton];
        
    UIImageView *grayView = [[UIImageView alloc] init];
    grayView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@/camea_round_gray", kGWCameraBundleName]];
    UITapGestureRecognizer* sendTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sendAction)];
    sendTap.delegate = self;
    [grayView addGestureRecognizer:sendTap];
    grayView.userInteractionEnabled = YES;
    [self addSubview:grayView];
        
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@/camera_send", kGWCameraBundleName]] forState:UIControlStateNormal];
    [sendButton addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendButton];
    
    [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.mas_left).offset(40);
        make.width.height.equalTo(@60);
        make.bottom.equalTo(self.mas_bottom).offset(-60);
    }];
    
    [retakeButton mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(whiteView.mas_centerX);
        make.centerY.equalTo(whiteView.mas_centerY);
        make.width.height.equalTo(@25);
    }];

    [grayView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(self.mas_right).offset(-40);
        make.width.height.equalTo(whiteView.mas_height);
        make.bottom.equalTo(whiteView.mas_bottom);
    }];
    [sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(grayView.mas_centerX);
        make.centerY.equalTo(grayView.mas_centerY);
        make.width.height.equalTo(retakeButton.mas_height);
    }];
}

- (void)retakeAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(didClickRetakeButonInView:)])
    {
        [_delegate didClickRetakeButonInView:self];
    }
}

- (void)sendAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(didClickUseButtonInView:)])
    {
        [_delegate didClickUseButtonInView:self];
    }
}

@end
