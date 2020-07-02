//
//  EVNCameraUtil.m
//  EVNCamera
//
//  Created by admin on 2020/5/25.
//

#import "EVNCameraUtil.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@implementation EVNCameraUtil



/// 保存视频到相册
/// @param videoURL 视频URL
/// @param completionHandler 完成回调
+ (void)cameraUtilSaveVideoUrl:(NSURL *)videoURL completionHandler:(nullable void(^)(BOOL success, NSError *__nullable error))completionHandler
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
        
    } completionHandler:completionHandler];
}


/// 保存图片到相册
/// @param image 图片信息
/// @param completionHandler 完成回调
+ (void)saveImage:(UIImage *)image completionHandler:(nullable void(^)(BOOL success, NSError *__nullable error))completionHandler
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        NSData *data = UIImageJPEGRepresentation(image, 0.9);
        PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
        options.shouldMoveFile = YES;
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        [request addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
        request.creationDate = [NSDate date];
    } completionHandler:completionHandler];
}

@end
