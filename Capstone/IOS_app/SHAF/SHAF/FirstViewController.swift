//
//  FirstViewController.swift
//  SHAF
//
//  Created by Ahmed Abdulkareem on 4/12/16.
//  Copyright © 2016 Ahmed Abdulkareem. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var bluetoothTable: UITableView!
    @IBOutlet weak var connectButton: UIButton!
    var selected_device = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.bluetoothTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "BLCell")
        
        // to update table view notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirstViewController.loadList(_:)),name:"discoveredPeriph", object: nil)
        
        // notify when connected
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirstViewController.periphConnected(_:)),name:"periphConnected", object: nil)
        
        self.connectButton.enabled = false
        
        BLEDiscovery // start bluetooth

    }
    
    // load bluetooth table
    func loadList(notification: NSNotification) {
        //load data here
        dispatch_sync(dispatch_get_main_queue()) {
             self.bluetoothTable.reloadData()
            }
    }
    
    // executes when peripheral is connected
    func periphConnected(notification: NSNotification) {
        dispatch_sync(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("selectGoalIdentifier", sender: nil)
        }
    }
    
    @IBAction func connectButton(sender: AnyObject) {
        BLEDiscovery.connect(self.selected_device)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BLEDiscovery.devicesDiscovered.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : UITableViewCell = self.bluetoothTable.dequeueReusableCellWithIdentifier("BLCell")! as UITableViewCell

        cell.textLabel?.text = BLEDiscovery.devicesDiscovered[indexPath.row]
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.connectButton.enabled = true
        self.selected_device = indexPath.row
    }


}

