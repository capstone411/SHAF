//
//  CalibrationViewController.swift
//  SHAF
//
//  Created by Ahmed Abdulkareem on 5/18/16.
//  Copyright © 2016 Ahmed Abdulkareem. All rights reserved.
//

import UIKit

class CalibrationViewController: UIViewController {
    
    var calibInProcess = false
    var calibDone = false

    @IBOutlet weak var startCalibButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // watch for calibration to finish
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CalibrationViewController.calibComplete(_:)),name:"calibComplete", object: nil)
        
        // watch for calibration to fail
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CalibrationViewController.calibFailed(_:)),name:"calibFailed", object: nil)
        
        self.startCalibButton.titleLabel?.text = "Start Calibration"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func CalibButtonPressed(sender: AnyObject) {
        
        // if they're about to start calibrating
        if self.startCalibButton.titleLabel?.text?.lowercaseString == "start calibration" {
            self.startCalibButton.setTitle("Calibrating..", forState: .Normal)
            self.startCalibButton.enabled = false
            BLEDiscovery.calibrate(true)
            BLEDiscovery.assertStop(true)
        }
    }
    
    // executes when calibration is complete
    func calibComplete(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            BLEDiscovery.calibrate(false) // clear calibration flag
            self.performSegueWithIdentifier("ReadyIdentifier", sender: nil)
        }
        
    }
    
    // executes when calibration fails
    func calibFailed(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            self.startCalibButton.setTitle("Start Calibration", forState: .Normal)
            BLEDiscovery.calibrate(false) // clear calibration flag
            self.startCalibButton.enabled = true // enable start calibartion button
            self.showCalibFailedAlert() // show an error message
        }
    }
    
    // shows a calibration fail message
    func showCalibFailedAlert() {
        // create the alert
        let alert = UIAlertController(title: "Calibration Failed", message: "Please try again", preferredStyle: UIAlertControllerStyle.Alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
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
