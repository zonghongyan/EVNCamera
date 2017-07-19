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

    /**
     * 手机方向判断
     */
    var cameraMotionManager:CMMotionManager = CMMotionManager();

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white;

//        self.useAccelerometerPush()
        UIDevice.current.beginGeneratingDeviceOrientationNotifications() // 感知设备方向-开启监听设备方向

        NotificationCenter.default.addObserver(self, selector: #selector(CoreMotionViewController.receivedRotation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil) // 添加通知，监听设备方向改变
        UIDevice.current.endGeneratingDeviceOrientationNotifications() // 关闭监听设备方向
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    /// 判断设备方向代理方法
    func receivedRotation()
    {
        let device = UIDevice.current

        if device.orientation == UIDeviceOrientation.unknown
        {
            print("Unknown")
        }
        else if device.orientation == UIDeviceOrientation.portrait
        {
            print("Portrait")
        }
        else if device.orientation == UIDeviceOrientation.portraitUpsideDown
        {
            print("PortraitUpsideDown")
        }
        else if device.orientation == UIDeviceOrientation.landscapeLeft
        {
            print("LandscapeLeft")
        }
        else if device.orientation == UIDeviceOrientation.landscapeRight
        {
            print("LandscapeRight")
        }
        else if device.orientation == UIDeviceOrientation.faceUp
        {
            print("FaceUp")
        }
        else if device.orientation == UIDeviceOrientation.faceDown
        {
            print("FaceDown")
        }
    }

    // MARK: 摇一摇事件
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?)
    {
        print("motionBegan: 摇一摇")     // 摇一摇
    }
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?)
    {
        print("motionEnded: 摇一摇结束")     // 摇一摇结束
    }
    override func motionCancelled(_ motion: UIEventSubtype, with event: UIEvent?)
    {
        print("motionCancelled: 摇一摇被意外终止") // 摇一摇被意外终止
    }


    /// 加速度计使用Pull方式获取 这种方式，是实时获取到Accelerometer的数据，并且用相应的队列来显示。即主动
    func useAccelerometerPull()
    {
        // 初始化全局管理对象
        let manager = CMMotionManager.init()

        self.cameraMotionManager = manager

        if manager.isAccelerometerAvailable    // 判断加速度计可不可用，判断加速度计是否开启
        {
            if (manager.isAccelerometerActive) // 方法用来查看加速度器的状态：是否Active（启动）
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
                print("isAccelerometerActive is not active")
            }
        }
        else
        {
            print("加速度传感器不可用")
        }
    }

    func useAccelerometerPush()
    {
        let manager = CMMotionManager.init() // 初始化全局管理对象
        self.cameraMotionManager = manager

        if manager.isAccelerometerAvailable  // 判断加速度计可不可用，判断加速度计是否开启
        {
            manager.accelerometerUpdateInterval = 0.01; // 告诉manager，更新频率是100Hz
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

    /// 陀螺仪 就是获取数据，如果要显示，就要向Accelerometer来索要数据。即：被动的方式
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
    }
}
