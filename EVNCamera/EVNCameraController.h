//
//  EVNCameraController.h
//  EVNCamera
//
//  Created by developer on 2017/6/9.
//  Copyright © 2017年 仁伯安. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 相机拍摄代理
 */
@protocol EVNCameraControllerDelegate <NSObject>

- (void)cameraDidFinishShootWithCameraImage:(UIImage *)cameraImage;

@end


/**
 * 自定义相机视图控制器
 */
@interface EVNCameraController : UIViewController


@property (weak, nonatomic) id<EVNCameraControllerDelegate> cameraControllerDelegate;


@end

