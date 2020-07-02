//
//  EVNCameraTakePhotosView.m
//  EVNCamera
//
//  Created by developer on 2017/6/9.
//  Copyright © 2017年 仁伯. All rights reserved.
//

#import "EVNCameraTakePhotosView.h"

@interface EVNCameraTakePhotosView ()
{
    NSTimeInterval __tempInterval;
    CGRect __circleFrame;
}

@property (nonatomic, assign) BOOL isCancel;
@property (nonatomic, assign) BOOL isPressed;
@property (nonatomic, assign) BOOL isTimeOut;
@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) CAShapeLayer *centerLayer;

@property (nonatomic, strong) CAShapeLayer *circleLayer;

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@property (nonatomic, strong) CADisplayLink *link;

@end

@implementation EVNCameraTakePhotosView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _isPressed = NO;
        _isCancel = NO;
        _isTimeOut = NO;
        _progress = 0.0;
        __tempInterval = 0;
        _interval = 10;
        self.backgroundColor = [UIColor clearColor];
        self.centerLayer.fillColor = [UIColor whiteColor].CGColor;
        self.circleLayer.fillColor = [UIColor colorWithRed:255.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:0.6].CGColor;
        [self addGestureRecognizer];
    }
    return self;
}

/// 添加手势事件
- (void)addGestureRecognizer
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGesture:)];
    [self addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:tap];
}

/// 单击事件
/// @param gesture 拍照
- (void)tapGesture:(UITapGestureRecognizer *)gesture
{
    [self  actionRecordWithCameraTakePhotoState:EVNCameraTakePhotoStateClick];
}

/// 录制小视频
/// @param gesture 长按手势
- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture
{
    /// 如果允许录制视频才允许长按事件相应
    if (self.isVideoEnabled)
    {
        switch (gesture.state)
        {
            case UIGestureRecognizerStateBegan:
            {
                [self link];
                _isPressed = YES;
                [self actionRecordWithCameraTakePhotoState:EVNCameraTakePhotoStateBegin];
            }
                break;
            case UIGestureRecognizerStateChanged:
            {
                CGPoint point = [gesture locationInView:self];
                if (CGRectContainsPoint(__circleFrame, point))
                {
                    _isCancel = NO;
                    [self actionRecordWithCameraTakePhotoState:EVNCameraTakePhotoStateMoving];
                }
                else
                {
                    _isCancel = YES;
                    [self  actionRecordWithCameraTakePhotoState:EVNCameraTakePhotoStateWillCancel];
                    
                }
            }
                break;
            case UIGestureRecognizerStateFailed:
            case UIGestureRecognizerStateCancelled:
            {
                _isCancel = YES;
                [self  actionRecordWithCameraTakePhotoState:EVNCameraTakePhotoStateDidCancel];
            }
                break;
            case UIGestureRecognizerStateEnded:
            {
                if (_isCancel)
                {
                    [self actionRecordWithCameraTakePhotoState:EVNCameraTakePhotoStateDidCancel];
                }
                else if(!_isTimeOut)
                {
                    
                    [self actionRecordWithCameraTakePhotoState:EVNCameraTakePhotoStateEnd];
                }
                _isTimeOut = NO;
                [self stop];
                [self setNeedsDisplay];
            }
                break;
            default:
                break;
        }
    }
}

/// 回调
/// @param cameraTakePhotoState 回调类型
- (void)actionRecordWithCameraTakePhotoState:(EVNCameraTakePhotoState)cameraTakePhotoState
{
    if (_delegate && [_delegate respondsToSelector:@selector(actionTakePhotoWithCameraTakePhotoState:)])
    {
        [_delegate actionTakePhotoWithCameraTakePhotoState:cameraTakePhotoState];
    }
}

- (void)beginRun:(CADisplayLink *)link
{
    __tempInterval += 1/60.0;
    _progress = __tempInterval/self.interval;
    if (__tempInterval >= self.interval)
    {
        _isTimeOut = YES;
        [self actionRecordWithCameraTakePhotoState:EVNCameraTakePhotoStateEnd];
        [self stop];
    }
    
    [self setNeedsDisplay];
//    NSLog(@"进度: %f，__tempInterval：%f", _progress, __tempInterval);
}

- (void)stop
{
    [self.link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.link invalidate];
    self.link = nil;
    _isPressed = NO;
    _isCancel = NO;
    __tempInterval = 0;
    _progress = 0;
    [self.progressLayer removeFromSuperlayer];
    self.progressLayer = nil;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat mainWidth = width * 0.5;
    CGRect mainFrame = CGRectMake(mainWidth/2.0, mainWidth/2.0, mainWidth, mainWidth);
    CGRect circleFrame = CGRectInset(mainFrame, -0.2*mainWidth/2.0, -0.2*mainWidth/2.0);
    if (_isPressed)
    {
        circleFrame = CGRectInset(mainFrame, -0.4*mainWidth/2.0, -0.4*mainWidth/2.0);
    }
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:circleFrame cornerRadius:CGRectGetWidth(circleFrame)/2.0];
    self.circleLayer.path = circlePath.CGPath;
    if (_isPressed)
    {
        mainWidth *= 0.8;
        mainFrame = CGRectMake((width - mainWidth)/2.0, (width - mainWidth)/2.0, mainWidth, mainWidth);
    }
    UIBezierPath *mainPath = [UIBezierPath bezierPathWithRoundedRect:mainFrame cornerRadius:mainWidth/2.0];
    self.centerLayer.path = mainPath.CGPath;
    if (_isPressed)
    {
        CGRect progressFrame = CGRectInset(circleFrame, 2.0, 2.0);
        UIBezierPath *progressPath = [UIBezierPath bezierPathWithRoundedRect:progressFrame cornerRadius:CGRectGetWidth(progressFrame)/2.0];
        self.progressLayer.path = progressPath.CGPath;
        self.progressLayer.strokeEnd = _progress;
        __circleFrame = progressFrame;
    }
}

#pragma mark - getter && setter
- (CAShapeLayer *)centerLayer
{
    if (_centerLayer == nil)
    {
        _centerLayer = [CAShapeLayer layer];
        _centerLayer.frame = self.bounds;
        _centerLayer.fillColor = [UIColor whiteColor].CGColor;
        [self.layer addSublayer:_centerLayer];
    }
    return _centerLayer;
}

- (CAShapeLayer *)circleLayer
{
    if (_circleLayer == nil)
    {
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.frame = self.bounds;
        _circleLayer.fillColor = [UIColor colorWithRed:255.0/255.0f green:255.0/255.0f blue:255.0/255.0f alpha:0.6].CGColor;
        [self.layer addSublayer:_circleLayer];
    }
    return _circleLayer;
}

- (CAShapeLayer *)progressLayer
{
    if (_progressLayer == nil)
    {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.frame = self.bounds;
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeColor = [UIColor colorWithRed:31/255.0 green:185/255.0 blue:34/255.0 alpha:1.0].CGColor;
        _progressLayer.lineWidth = 4;
        _progressLayer.lineCap = kCALineCapRound;
        [self.layer addSublayer:_progressLayer];
    }
    return _progressLayer;
}

- (CADisplayLink *)link
{
    if (_link == nil)
    {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(beginRun:)];
        _link.preferredFramesPerSecond = 60;
        [_link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return _link;
}

- (void)setCenterColor:(UIColor *)centerColor
{
    _centerColor = centerColor;
    self.centerLayer.fillColor = centerColor.CGColor;
}

- (void)setRingColor:(UIColor *)ringColor
{
    _ringColor = ringColor;
    self.circleLayer.fillColor = ringColor.CGColor;
}

- (void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    self.progressLayer.strokeColor = progressColor.CGColor;
}

- (void)dealloc
{
    if (self.link)
    {
        [self.link removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [self.link invalidate];
        self.link = nil;
    }
//    NSLog(@"%s", __func__);
}

@end
