//
//  VideoViewController.swift
//  SHAF
//
//  Created by Ahmed Abdulkareem on 4/20/16.
//  Copyright © 2016 Ahmed Abdulkareem. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoViewController: UIViewController {
    
    var player: AVPlayer?
    let playerController = AVPlayerViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadVideo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadVideo() {
        performSegueWithIdentifier("CalibrationIdentifier", sender: nil)
        //self.playerController.player = self.player
        //self.addChildViewController(self.playerController)
        //self.view.addSubview(self.playerController.view)
        //self.playerController.view.frame = self.view.frame
        //self.player?.play()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
