//
//  LiveViewController.swift
//  SHAF
//
//  Created by Ahmed Abdulkareem on 4/15/16.
//  Copyright © 2016 Ahmed Abdulkareem. All rights reserved.
//

import UIKit

class LiveViewController: UIViewController {

    @IBOutlet weak var RepCount: UILabel!
    @IBOutlet weak var fatigueCheckBox: UIImageView!
    @IBOutlet weak var fatigueLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    private var fatigued = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        // watch for rep count to change
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LiveViewController.repChanged(_:)),name:"repCountChanged", object: nil)
        
        // watch for fatigue to change
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LiveViewController.fatigue(_:)),name:"fatigue", object: nil)
        
        // watch for rep time outs
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LiveViewController.timeOut(_:)),name:"repTimeOut", object: nil)
        
        // set checkbox image and hide it
        self.fatigued = false
        self.fatigueCheckBox.image = UIImage(named: "fatigueCheckBox")
        self.fatigueCheckBox.hidden = true
        
        // set fatigue checkbox
        self.fatigueLabel.hidden = true
        
        self.fatigueCheckBox.layer.borderWidth = 2
        self.fatigueCheckBox.layer.masksToBounds = true
        
        // set up rep count label
        self.RepCount.text = "0"
        self.RepCount.textAlignment = NSTextAlignment.Center
        self.RepCount.font = UIFont(name: self.RepCount.font.fontName, size: 50)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func repChanged(notification: NSNotification) {
        // update value of rep count label
        dispatch_async(dispatch_get_main_queue()) {
            print("inside repChanged function")
            if ((notification.userInfo?["repCount"]) != nil) {
            print(notification.userInfo?["repCount"] as! String)
            self.RepCount.text = notification.userInfo?["repCount"] as? String
            }
        }
    }
    
    func fatigue (notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            // check if fatigue
            if self.fatigued {
                self.fatigueCheckBox.hidden = true
                self.fatigueLabel.hidden = true
                self.fatigued = false
            }
            else {
                self.fatigueCheckBox.hidden = false
                self.fatigueLabel.hidden = false
                self.fatigued = true
            }
        }
    }
    
    @IBAction func doneButtonClicked(sender: AnyObject) {
        dispatch_async(dispatch_get_main_queue()) {
            // clear start characteristic
            BLEDiscovery.startStopData(false)
            
            // assert the stop characteristic
            BLEDiscovery.assertStop(false)
        
            // go to next view controller to display
            // number of reps, time it took to perform
            // the reps and when they reached fatigue
            self.performSegueWithIdentifier("ResultsIdentifier", sender: nil)
        }
    }
    
    func timeOut(notification: NSNotificationCenter) {
        dispatch_async(dispatch_get_main_queue()) {
            self.showTimeOutMessage() // show time out message
        }
    }
    
    func showTimeOutMessage() {
        // create the alert
        let alert = UIAlertController(title: "Time Out", message: "Please Continue or Press Done", preferredStyle: UIAlertControllerStyle.Alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        // show the alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destinaion = segue.destinationViewController as! ResultsViewController
        
        destinaion.repCount = self.RepCount.text
        
        if (fatigued) {
            destinaion.hideFatigueImage = false
        }
        else {
            destinaion.hideFatigueImage = true
        }
    }
    

}
