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
platform :ios, '8.0'
#use_frameworks!

target '<Your Target Name>' do

pod 'EVNCamera', '~> 0.0.3'

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
        
func cameraDidFinishShoot(withCameraImage cameraImage: UIImage!)
{
   self.previewImageView.image = cameraImage
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
- (void)cameraDidFinishShootWithCameraImage:(UIImage *)cameraImage
{
    [self.previewImageView setImage:cameraImage];
}
```

### 预览图

<img src="https://github.com/zonghongyan/EVNCamera/blob/master/EVNCameraDemo/ShotImages/Screen%20Shot%202017-06-09%20at%2010.54.34.png" width="20%" height="20%" alt="Show the figure" ><img src="https://github.com/zonghongyan/EVNCamera/blob/master/EVNCameraDemo/ShotImages/Screen%20Shot%202017-06-09%20at%2010.55.46.png" width="20%" height="20%" alt="Show the figure" ><img src="https://github.com/zonghongyan/EVNCamera/blob/master/EVNCameraDemo/ShotImages/Screen%20Shot%202017-06-09%20at%2010.55.46.png" width="20%" height="20%" alt="Show the figure" ><img src="https://github.com/zonghongyan/EVNCamera/blob/master/EVNCameraDemo/ShotImages/Screen%20Shot%202017-06-09%20at%2010.55.46.png" width="20%" height="20%" alt="Show the figure" >
