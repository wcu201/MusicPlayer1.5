//
//  HomeCollectionViewCell.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 3/30/19.
//  Copyright © 2019 William  Uchegbu. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var label: UILabel!
    
    override func layoutSubviews() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
//        self.translatesAutoresizingMaskIntoConstraints = false
//        self.addConstraints([
//            NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self.contentView, attribute: .height, multiplier: 0.9, constant: 0),
//            NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0),
//        ])
    }
}
