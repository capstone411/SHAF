//
//  LiveViewController.swift
//  SHAF
//
//  Created by Ahmed Abdulkareem on 4/15/16.
//  Copyright © 2016 Ahmed Abdulkareem. All rights reserved.
//

import UIKit

class LiveViewController: UIViewController {

    @IBOutlet weak var NumReps: UILabel!
    @IBOutlet weak var RepCount: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func repChanged(repNum: Int) {
        // update value of rep count label
        self.RepCount.text = String(repNum)
    }
    
    func fatigue () {
        
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
