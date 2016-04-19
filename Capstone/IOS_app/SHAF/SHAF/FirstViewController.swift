//
//  FirstViewController.swift
//  SHAF
//
//  Created by Ahmed Abdulkareem on 4/12/16.
//  Copyright © 2016 Ahmed Abdulkareem. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var buttonActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bluetoothTable: UITableView!
    @IBOutlet weak var connectButton: UIButton!
    var selected_device = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.bluetoothTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "BLCell")
        
        // to update table view notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirstViewController.loadList(_:)),name:"discoveredPeriph", object: nil)
        
        // notify when connected
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirstViewController.periphConnected(_:)),name:"periphConnected", object: nil)
        
        self.connectButton.enabled = false
        
        self.buttonActivityIndicator.hidden = true
        
        BLEDiscovery // start bluetooth

    }
    
    // load bluetooth table
    func loadList(notification: NSNotification) {
        
        dispatch_sync(dispatch_get_main_queue()) {
             //load data of table
             self.bluetoothTable.reloadData()
            }
    }
    
    // executes when peripheral is connected
    func periphConnected(notification: NSNotification) {
        dispatch_sync(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("selectGoalIdentifier", sender: nil)
            
            // stop activity indicator
            let cells = self.bluetoothTable.visibleCells as! [BluetoothTableCellTableViewCell]
            let cell = cells[self.selected_device]
            cell.indicator.stopAnimating()
            self.buttonActivityIndicator.hidden = true
            self.buttonActivityIndicator.stopAnimating()
        }
    }
    
    @IBAction func connectButton(sender: AnyObject) {
        // connect to peripheral
        BLEDiscovery.connect(self.selected_device)
        
        // start activitiy indicator
        let cells = self.bluetoothTable.visibleCells as! [BluetoothTableCellTableViewCell]
        let currCell = cells[self.selected_device]
        currCell.indicator.startAnimating()
        self.buttonActivityIndicator.hidden = false
        self.buttonActivityIndicator.startAnimating() // for connect button
        
        // disable connect button
        self.connectButton.enabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BLEDiscovery.devicesDiscovered.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell : UITableViewCell = self.bluetoothTable.dequeueReusableCellWithIdentifier("BLCell")! as UITableViewCell
        let cell : BluetoothTableCellTableViewCell = self.bluetoothTable.dequeueReusableCellWithIdentifier("BLCell")! as! BluetoothTableCellTableViewCell
        
        let cellName = BLEDiscovery.devicesDiscovered[indexPath.row]

        cell.textLabel?.text = cellName
        
        // check if this is the bluetooth device and add
        // check mark next to it 
        if cellName == "Ahmed’s MacBook Pro" {
            cell.checkMarkImage.hidden = false
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.connectButton.enabled = true // enable connect button if not already
        self.selected_device = indexPath.row // this is the index of selected device
    }


}

