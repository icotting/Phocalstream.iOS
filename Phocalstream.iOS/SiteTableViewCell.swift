//
//  SiteTableViewCell.swift
//  Phocalstream.iOS
//
//  Created by Ian Cottingham on 9/29/14.
//  Copyright (c) 2014 Jeffrey S. Raikes School. All rights reserved.
//

import UIKit

class SiteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var siteName: UILabel!
    @IBOutlet weak var siteDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
