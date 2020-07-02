//
//  CoreMotionViewController.swift
//  EVNCamera
//
//  Created by developer on 2017/7/19.
//  Copyright © 2017年 仁伯安. All rights reserved.
//

import UIKit
import CoreMotion


class CoreMotionViewController: UIViewController {

    @IBOutlet weak var motionContent: UILabel!

    /// 手机方向判断
    var cameraMotionManager:CMMotionManager = CMMotionManager();

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.cameraMotionManager.startAccelerometerUpdates()        // 开始更新，后台线程开始运行。这是Pull方式。
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cameraMotionManager.stopAccelerometerUpdates()        // 开始更新，后台线程开始运行。这是Pull方式。
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white;
        self.motionContent?.text = "您试着转转手机\nO(∩_∩)O~"
        self.useAccelerometerPull()
        UIDevice.current.beginGeneratingDeviceOrientationNotifications() // 感知设备方向-开启监听设备方向
        
//        NotificationCenter.default.addObserver(self, selector: #selector(CoreMotionViewController.receivedRotation), name: NSNotification.Name.UIDevice.orientationDidChangeNotification, object: nil) // 添加通知，监听设备方向改变
        NotificationCenter.default.addObserver(self, selector: #selector(CoreMotionViewController.receivedRotation), name:UIDevice.orientationDidChangeNotification , object: nil);
        UIDevice.current.endGeneratingDeviceOrientationNotifications() // 关闭监听设备方向
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /// 判断设备方向代理方法
    @objc func receivedRotation()
    {
        let device = UIDevice.current

        self.cameraMotionManager.startAccelerometerUpdates()        // 开始更新，后台线程开始运行。这是Pull方式。

        var deviceOrientation:String = "";

        if device.orientation == UIDeviceOrientation.unknown
        {
            deviceOrientation = "未知状态"
            print("Unknown")
        }
        else if device.orientation == UIDeviceOrientation.portrait
        {
            print("Portrait")
            deviceOrientation = "手机竖直向上，摄像头在上"
        }
        else if device.orientation == UIDeviceOrientation.portraitUpsideDown
        {
            print("PortraitUpsideDown")
            deviceOrientation = "手机竖直向上，摄像头在下"
        }
        else if device.orientation == UIDeviceOrientation.landscapeLeft
        {
            print("LandscapeLeft")
            deviceOrientation = "摄像头在左"
        }
        else if device.orientation == UIDeviceOrientation.landscapeRight
        {
            print("LandscapeRight")
            deviceOrientation = "摄像头在右"
        }
        else if device.orientation == UIDeviceOrientation.faceUp
        {
            print("FaceUp")
            deviceOrientation = "放平面朝上"
        }
        else if device.orientation == UIDeviceOrientation.faceDown
        {
            print("FaceDown")
            deviceOrientation = "放平面朝下"
        }

        if (self.cameraMotionManager.accelerometerData != nil)
        {
            self.updateAccelerometerDataAndDeviceOr(accelerometerDataString: self.cameraMotionManager.accelerometerData!, deviceOrientationString: deviceOrientation)
        }

    }

    // MARK: 摇一摇事件
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?)
    {
        print("motionBegan: 摇一摇")     // 摇一摇
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?)
    {
        print("motionEnded: 摇一摇结束")     // 摇一摇结束
    }
    override func motionCancelled(_ motion: UIEvent.EventSubtype, with event: UIEvent?)
    {
        print("motionCancelled: 摇一摇被意外终止") // 摇一摇被意外终止
    }

    /// 加速度计使用Pull方式获取 就是获取数据，如果要显示，就要向Accelerometer来索要数据。即：被动的方式
    func useAccelerometerPull()
    {
        let manager = CMMotionManager.init()   // 初始化全局管理对象
        self.cameraMotionManager = manager

        if manager.isAccelerometerAvailable    // 判断加速度计可不可用，判断加速度计是否开启
        {
            manager.accelerometerUpdateInterval = 0.01 // 告诉manager，更新频率是100Hz
            manager.startAccelerometerUpdates()        // 开始更新，后台线程开始运行。这是Pull方式。
            let newestAccel = self.cameraMotionManager.accelerometerData // 获取并处理加速度计数据

            print("X = \(String(describing: newestAccel?.acceleration.x))")
            print("Y = \(String(describing: newestAccel?.acceleration.y))")
            print("Z = \(String(describing: newestAccel?.acceleration.z))")
        }
        else
        {
            print("加速度传感器不可用")
        }
    }

    /// 更新加速器数据
    ///
    /// - Parameters:
    ///   - accelerometerDataString: 加速数据
    ///   - deviceOrientationString: 设备方向
    func updateAccelerometerDataAndDeviceOr(accelerometerDataString: CMAccelerometerData, deviceOrientationString: String) -> Void
    {
        print("X = \(String(describing: accelerometerDataString.acceleration.x))")
        print("Y = \(String(describing: accelerometerDataString.acceleration.y))")
        print("Z = \(String(describing: accelerometerDataString.acceleration.z))")

        DispatchQueue.global().async{
            DispatchQueue.main.async{
                let string: String = "pull加速器数据" + "\n" + "X: " + String(describing: accelerometerDataString.acceleration.x) + "\n"  + "Y: " + String(describing: accelerometerDataString.acceleration.y) + "\n"  + "Z: " + String(describing: accelerometerDataString.acceleration.z) + "\n \n" + "设备的位置方向:" + "\n" + deviceOrientationString
                self.motionContent?.text = string;
            }
        }
    }

    /// push 这种方式，是实时获取到Accelerometer的数据，并且用相应的队列来显示。即主动
    func useAccelerometerPush()
    {
        let manager = CMMotionManager.init() // 初始化全局管理对象
        self.cameraMotionManager = manager

        if manager.isAccelerometerAvailable  // 判断加速度计可不可用，判断加速度计是否开启
        {
            manager.accelerometerUpdateInterval = 0.1; // 告诉manager，更新频率是100Hz 设置采样的频率，单位是秒
            let queue = OperationQueue.init()
            manager.startAccelerometerUpdates(to: queue, withHandler: { (accelerometerData, error) in // Push方式获取和处理数据
                print("X = \(String(describing: accelerometerData?.acceleration.x))")
                print("Y = \(String(describing: accelerometerData?.acceleration.y))")

                print("Z = \(String(describing: accelerometerData?.acceleration.z))")
            })
        }
        else
        {
            print("加速度传感器不可用")
        }
    }

    /// 陀螺仪
    func useGyroPush()
    {
        // 初始化全局管理对象
        let manager = CMMotionManager.init()
        self.cameraMotionManager = manager;

        if manager.isGyroAvailable // 判断陀螺仪可不可以，判断陀螺仪是不是开启
        {
            if (manager.isGyroActive)
            {
                let queue = OperationQueue.init()

                manager.gyroUpdateInterval = 0.01 // 告诉manager，更新频率是100Hz

                manager.startGyroUpdates(to: queue, withHandler: { (gyroData, error) in    // Push方式获取和处理数据
                    print("Gyro Rotation x  = \(String(describing: gyroData?.rotationRate.x))")
                    print("Gyro Rotation y  = \(String(describing: gyroData?.rotationRate.y))")
                    print("Gyro Rotation z  = \(String(describing: gyroData?.rotationRate.z))")
                })
            }
            else
            {
                print("isGyroActive is not active")
            }
        }
        else
        {
            print("加速度传感器不可用")
        }
    }

    deinit
    {
        print("\(#function): \(object_getClassName(self))")

        self.cameraMotionManager.stopAccelerometerUpdates()
        NotificationCenter.default.removeObserver(self, name:UIDevice.orientationDidChangeNotification, object: nil) // 移除监听设备方向的通知
    }
}
