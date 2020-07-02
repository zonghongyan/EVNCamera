//
//  ViewController.swift
//  EVNCamera
//
//  Created by developer on 2017/6/9.
//  Copyright © 2017年 仁伯安. All rights reserved.
//

import UIKit

class ViewController: UIViewController, EVNCameraControllerDelegate
{

    @IBOutlet weak var openCameraBtn: UIButton!

    @IBOutlet weak var previewImageView: UIImageView!

    @IBOutlet weak var coreMotion: UIButton!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.navigationController?.navigationBar.isHidden = true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openCameraAction(_ sender: Any)
    {
        let cameraController:EVNCameraController = EVNCameraController.init()
        cameraController.delegate = self;
        self.present(cameraController, animated: true, completion: nil)
    }


    @IBAction func coreMotionAction(_ sender: UIButton)
    {
        let mainStoryB = UIStoryboard.init(name: "Main", bundle: nil)
        let coreMotionViewController:CoreMotionViewController = mainStoryB.instantiateViewController(withIdentifier: "coreMotionViewController") as! CoreMotionViewController
        self.navigationController?.pushViewController(coreMotionViewController, animated: true)
    }

    func cameraController(_ cameraController: EVNCameraController!, didFinishShootWithCameraImage cameraImage: UIImage!) {
        
        self.previewImageView.image = cameraImage
        cameraController.dismiss(animated: true) {
            
        };
    }
    
    func cameraController(_ cameraController: EVNCameraController!, didFinishVideo videoURL: URL!) {
        
        print("\(videoURL.path)")
    }

    deinit
    {
        print("\(#function) \(object_getClassName(self))")
    }
}

