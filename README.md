## EVNCamera

[![Build Status](https://travis-ci.org/zonghongyan/EVNCamera.svg?branch=master)](https://travis-ci.org/zonghongyan/EVNTouchIDDemo)
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
use_frameworks!

target '<Your Target Name>' do
    pod 'EVNCamera', '~> 0.0.2'
end
```

Then, run the following command:

```bash
$ pod install
```
## use
```
let cameraController:EVNCameraController = EVNCameraController.init()
cameraController.cameraControllerDelegate = self;
self.present(cameraController, animated: true, completion: nil)
        
func cameraDidFinishShoot(withCameraImage cameraImage: UIImage!)
{
   self.previewImageView.image = cameraImage
}
```
### 预览图

<img src="/EVNCameraDemo/ShotImages/Screen Shot 2017-06-09 at 10.54.34.png" width="20%" height="20%" alt="Show the figure" ><img src="/EVNCameraDemo/ShotImages/Screen Shot 2017-06-09 at 10.55.46.png" width="20%" height="20%" alt="Show the figure" ><img src="/EVNCameraDemo/ShotImages/Screen Shot 2017-06-09 at 10.55.46.png" width="20%" height="20%" alt="Show the figure" ><img src="/EVNCameraDemo/ShotImages/Screen Shot 2017-06-09 at 10.55.46.png" width="20%" height="20%" alt="Show the figure" >
