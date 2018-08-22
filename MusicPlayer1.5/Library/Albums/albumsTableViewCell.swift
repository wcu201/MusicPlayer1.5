//
//  albumsTableViewCell.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/24/18.
//  Copyright © 2018 William  Uchegbu. All rights reserved.
//

import UIKit

class albumsTableViewCell: UITableViewCell {
    @IBOutlet weak var album1Art: UIImageView!
    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var artist1: UILabel!
    
    
    @IBOutlet weak var album2Art: UIImageView!
    @IBOutlet weak var title2: UILabel!
    @IBOutlet weak var artist2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
