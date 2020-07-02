//
//  EVNCameraUtil.h
//  EVNCamera
//
//  Created by admin on 2020/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EVNCameraUtil : NSObject



/// 保存视频到相册
/// @param videoURL 视频URL
/// @param completionHandler 完成回调
+ (void)cameraUtilSaveVideoUrl:(NSURL *)videoURL completionHandler:(nullable void(^)(BOOL success, NSError *__nullable error))completionHandler;

/// 保存图片到相册
/// @param image 图片信息
/// @param completionHandler 完成回调
+ (void)saveImage:(UIImage *)image completionHandler:(nullable void(^)(BOOL success, NSError *__nullable error))completionHandler;


@end

NS_ASSUME_NONNULL_END
