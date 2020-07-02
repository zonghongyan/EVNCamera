//
//  EVNCameraPlayMovieView.m
//  EVNCamera
//
//  Created by developer on 2017/6/9.
//  Copyright © 2017年 仁伯. All rights reserved.
//

#import "EVNCameraPlayMovieView.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"

static NSString * const kGWCameraBundleName = @"EVNCamera.bundle";

@interface EVNCameraPlayMovieView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

/// 是否已取消掉或暂停掉
@property (nonatomic, assign) BOOL isPause;

@end
@implementation EVNCameraPlayMovieView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor blackColor];
        self.contentMode = UIViewContentModeScaleAspectFill;
        [self setupView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishPlayMovie:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}

- (void)setupView
{
    UIImageView *whiteView = [[UIImageView alloc] init];
    whiteView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@/camea_round_gray", kGWCameraBundleName]];
    UITapGestureRecognizer *retakeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(retakeAction)];
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
    UITapGestureRecognizer *sendTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(sendAction)];
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
    if (_delegate && [_delegate respondsToSelector:@selector(didClickRetakeButonInPlayView:)])
    {
        [_delegate didClickRetakeButonInPlayView:self];
    }
}

- (void)sendAction
{
    if (_delegate && [_delegate respondsToSelector:@selector(didClickSendButtonInPlayView:)])
    {
        [_delegate didClickSendButtonInPlayView:self];
    }
}

- (void)setFileUrl:(NSURL *)fileUrl
{
    _fileUrl = fileUrl;
    [self resetPlayer];
    self.playerItem = [AVPlayerItem playerItemWithURL:fileUrl];
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    self.playerLayer.frame = self.frame;
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//AVLayerVideoGravityResizeAspectFill;
    [self.layer insertSublayer:_playerLayer atIndex:0];
    self.isPause = NO;
}

- (void)resetPlayer
{
    if (_player)
    {
        [_player pause];
    }
    if (_playerLayer)
    {
        [_playerLayer removeFromSuperlayer];
    }
}

- (void)play
{
    [_player play];
    self.isPause = NO;
}

- (void)pause
{
    [_player pause];
    self.isPause = YES;
}

// 重复播放视频。
- (void)didFinishPlayMovie:(NSNotification *)notification
{
    [_player seekToTime:CMTimeMake(0, 1)];
    if (self.isPause)
    {
        return;
    }
    [_player play];
}

@end
