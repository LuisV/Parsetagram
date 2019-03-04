//
//  PostCell.swift
//  Parstagram
//
//  Created by Luis Valencia on 3/4/19.
//  Copyright © 2019 Luis Valencia. All rights reserved.
//

import UIKit
import AlamofireImage
class PostCell: UITableViewCell {

    @IBOutlet weak var photoView: UIImageView!
    
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var caption: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
