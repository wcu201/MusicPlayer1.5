//
//  ShuffleTableViewCell.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/25/18.
//  Copyright © 2018 William  Uchegbu. All rights reserved.
//

import UIKit

class ShuffleTableViewCell: UITableViewCell {
    @IBOutlet weak var shuffleBTN: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        shuffleBTN.layer.cornerRadius = 20
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func shufflePlay(_ sender: Any) {
        userData.shuffledLibrary = userData.downloadLibrary
        userData.shuffledLibrary.shuffle()
    }
}
