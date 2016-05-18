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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up fonts and center it for the number of reps label
        self.numOfCorrectRepsLabel.text = ""
        self.numOfCorrectRepsLabel.textAlignment = NSTextAlignment.Center
        self.numOfCorrectRepsLabel.font = UIFont(name: self.numOfCorrectRepsLabel.font.fontName, size: 30)
        
        // set up fonts and center it for the number of reps text label
        self.correctRepsLabel.textAlignment = NSTextAlignment.Center
        self.correctRepsLabel.font = UIFont(name: self.correctRepsLabel.font.fontName, size: 30)

        // Do any additional setup after loading the view.
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
