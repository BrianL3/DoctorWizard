//
//  MediaItemCell.swift
//  DoctorWizard
//
//  Created by GTPWTW on 1/28/15.
//  Copyright (c) 2015 codefellows. All rights reserved.
//

import UIKit

class MediaItemCell: UITableViewCell {

    
    @IBOutlet weak var song: UILabel!
    @IBOutlet weak var artist: UILabel!
    
    @IBOutlet weak var songImage: UIImageView!
    
    @IBOutlet weak var songDuration: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
