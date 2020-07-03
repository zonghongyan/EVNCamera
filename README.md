## EVNCamera

[![Build Status](https://travis-ci.org/zonghongyan/EVNCamera.svg?branch=master)](https://travis-ci.org/zonghongyan/EVNTouchIDDemo)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/EVNCamera.svg)](https://img.shields.io/cocoapods/v/EVNCamera.svg)
[![License](https://img.shields.io/github/license/zonghongyan/EVNCamera.svg?style=flat)](https://github.com/zonghongyan/EVNCamera/blob/master/LICENSE)

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build EVNCamera.

To integrate EVNCamera into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
#use_frameworks!

target '<Your Target Name>' do

pod 'EVNCamera', '~> 1.0.0'

end
```

Then, run the following command:

```bash
$ pod install
```

## Use
#### Use in swift
```
class ViewController: UIViewController, EVNCameraControllerDelegate // To follow the protocol EVNCameraControllerDelegate
......

let cameraController:EVNCameraController = EVNCameraController.init()
cameraController.cameraControllerDelegate = self;
self.present(cameraController, animated: true, completion: nil)
        
func cameraController(_ cameraController: EVNCameraController!, didFinishShootWithCameraImage cameraImage: UIImage!) {
    
    self.previewImageView.image = cameraImage
    cameraController.dismiss(animated: true) {
        
    };
}

func cameraController(_ cameraController: EVNCameraController!, didFinishVideo videoURL: URL!) {
    // 视频路径
    print("\(videoURL.path)")
}
```

#### Use in Objective-C
```
@import EVNCamera; // Or #import "EVNCameraController.h"

@interface ViewController ()<EVNCameraControllerDelegate>
......

EVNCameraController *cameraController = [[EVNCameraController alloc] init];
cameraController.cameraControllerDelegate = self;
[self presentViewController:cameraController animated:YES completion:nil];
    
#pragma mark: EVNCameraControllerDelegate method
/// 拍照之使用图片回调
/// @param cameraController 相机对象
/// @param cameraImage 图片
- (void)cameraController:(EVNCameraController *)cameraController didFinishShootWithCameraImage:(UIImage *)cameraImage


/// 录制之使用视频
/// @param cameraController 摄像机对象
/// @param videoURL 视频暂存本地的路径
- (void)cameraController:(EVNCameraController *)cameraController didFinishVideo:(NSURL *)videoURL
```

### 预览图

<img src="https://github.com/zonghongyan/EVNCamera/blob/master/ShootImags/101593753280.jpg" width="20%" height="20%" alt="Show the figure" ><img src="https://github.com/zonghongyan/EVNCamera/blob/master/ShootImags/91593753279.jpg" width="20%" height="20%" alt="Show the figure" >
