//
//  EVNCameraShowImageView.h
//  EVNCamera
//
//  Created by developer on 2017/6/9.
//  Copyright © 2017年 仁伯. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EVNCameraShowImageViewDelegate;

@interface EVNCameraShowImageView : UIImageView

@property (nonatomic, assign) id<EVNCameraShowImageViewDelegate> delegate;

@end


@protocol EVNCameraShowImageViewDelegate <NSObject>

// 重拍
- (void)didClickRetakeButonInView:(EVNCameraShowImageView *)showImageView;

// 使用图片
- (void)didClickUseButtonInView:(EVNCameraShowImageView *)showImageView;

@end
