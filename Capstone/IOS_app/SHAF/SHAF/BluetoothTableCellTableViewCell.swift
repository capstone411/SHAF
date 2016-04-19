//
//  BluetoothTableCellTableViewCell.swift
//  SHAF
//
//  Created by Ahmed Abdulkareem on 4/17/16.
//  Copyright © 2016 Ahmed Abdulkareem. All rights reserved.
//

import UIKit

class BluetoothTableCellTableViewCell: UITableViewCell {
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    @IBOutlet weak var checkMarkImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        // activity indicator
        self.accessoryView = indicator
        
        // image view
        checkMarkImage.image = UIImage(named: "fatigueCheckBox")
        
        // hide image so it only shows when we need it
        self.checkMarkImage.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
