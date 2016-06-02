//
//  ResultsViewController.swift
//  SHAF
//
//  Created by Ahmed Abdulkareem on 5/18/16.
//  Copyright © 2016 Ahmed Abdulkareem. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {
    
    @IBOutlet weak var correctRepsLabel: UILabel!
    @IBOutlet weak var numOfCorrectRepsLabel: UILabel!
    @IBOutlet weak var fatigueLabel: UILabel!
    @IBOutlet weak var fatigueImage: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var oneRepMaxLabel: UILabel!
    var repCount: String?
    var hideFatigueImage = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up fonts and center it for the number of reps label
        self.numOfCorrectRepsLabel.textAlignment = NSTextAlignment.Center
        self.numOfCorrectRepsLabel.font = UIFont(name: self.numOfCorrectRepsLabel.font.fontName, size: 30)
        self.numOfCorrectRepsLabel.text = repCount
        
        // set up fonts and center it for the number of reps text label
        self.correctRepsLabel.textAlignment = NSTextAlignment.Center
        self.correctRepsLabel.font = UIFont(name: self.correctRepsLabel.font.fontName, size: 20)
        
        // hide check box of fatigue and get image for it
        self.fatigueImage.image = UIImage(named: "fatigueCheckBox")
        if (hideFatigueImage) {
            self.fatigueImage.hidden = true
            self.fatigueLabel.text = "Your Muscle did NOT Reach Fatigue"
            self.fatigueLabel.font = UIFont(name: self.fatigueLabel.font.fontName, size: 14)
        }
        else {
            self.fatigueImage.hidden = false
            self.fatigueLabel.text = "Your Muscle Reached Fatigue"
            self.fatigueLabel.font = UIFont(name: self.fatigueLabel.font.fontName, size: 14)
        }
        // calculate one rep max
        let maxRep = Int(self.calculateOneRepMax())
        print("Calculated:", maxRep)
        self.oneRepMaxLabel.text = "You can do " + String(maxRep) + " LBS for one rep"
    }
    
    // calculates one rep max
    func calculateOneRepMax() -> Double{
        print("MAX:", BLEDiscovery.weightAmount)
        let maxRep = Double(BLEDiscovery.weightAmount)*(1.00 + Double(Int(self.repCount!)!)/30)
        return maxRep
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
