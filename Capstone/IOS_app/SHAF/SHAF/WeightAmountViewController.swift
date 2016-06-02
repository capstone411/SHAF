//
//  WeightAmountViewController.swift
//  SHAF
//
//  Created by Ahmed Abdulkareem on 6/1/16.
//  Copyright © 2016 Ahmed Abdulkareem. All rights reserved.
//

import UIKit

class WeightAmountViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var howMuchWeightLabel: UILabel!
    @IBOutlet weak var weightNumField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var lbsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // set up font
        //self.howMuchWeightLabel.textAlignment = NSTextAlignment.Center
        //self.howMuchWeightLabel.font = UIFont(name: self.howMuchWeightLabel.font.fontName, size: 50)
        
        // disable next button
        self.nextButton.enabled = false
        
        // set delegate of text field
        self.weightNumField.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        // Find out what the text field will be after adding the current edit
        let text = (weightNumField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        let weightAmount = Int(text)
        if (weightAmount != nil && weightAmount < 120) {
            // Text field converted to an Int
            BLEDiscovery.weightAmount = weightAmount!
            self.nextButton.enabled = true
        } else {
            // Text field is not an Int
            self.nextButton.enabled = false
        }
        
        // Return true so the text field will be changed
        return true
    }
    
    @IBAction func nextButtonClicked(sender: AnyObject) {
        performSegueWithIdentifier("videoIdentifier", sender: nil)
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
