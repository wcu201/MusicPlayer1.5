//
//  songTableViewCell.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/22/18.
//  Copyright © 2018 William  Uchegbu. All rights reserved.
//

import UIKit

class songTableViewCell: UITableViewCell {
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var artistText: UILabel!
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var editBTN: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
