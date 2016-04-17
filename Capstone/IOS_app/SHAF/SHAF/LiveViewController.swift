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
    private var fatigued = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        
        // watch for rep count to change
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LiveViewController.repChanged(_:)),name:"repCountChanged", object: nil)
        
        // watch for fatigue to change
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LiveViewController.repChanged(_:)),name:"fatigue", object: nil)
        
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
        self.RepCount.text = notification.userInfo?["repCount"] as? String
    }
    
    func fatigue () {
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
