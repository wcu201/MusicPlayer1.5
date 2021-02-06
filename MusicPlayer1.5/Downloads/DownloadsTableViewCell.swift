//
//  DownloadsTableViewCell.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 11/26/20.
//  Copyright © 2020 William  Uchegbu. All rights reserved.
//

import UIKit

class DownloadsTableViewCell: UITableViewCell {
    let progressBar = UIProgressView(progressViewStyle: .bar)
    let songPath = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func addViews(){
        songPath.textAlignment = .center
        
        self.contentView.addSubview(songPath)
        self.contentView.addSubview(progressBar)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.progressBar, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.progressBar, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.progressBar, attribute: .bottom, relatedBy: .equal, toItem: self.contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self.progressBar, attribute: .height, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 0.1, constant: 0.0)
        ])
        
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: self.songPath, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1.0, constant: 1.0),
            NSLayoutConstraint(item: self.songPath, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1.0, constant: 1.0),
            NSLayoutConstraint(item: self.songPath, attribute: .top, relatedBy: .equal, toItem: self.contentView, attribute: .top, multiplier: 1.0, constant: 1.0),
            NSLayoutConstraint(item: self.songPath, attribute: .bottom, relatedBy: .equal, toItem: self.progressBar, attribute: .top, multiplier: 1.0, constant: 1.0)
        ])
    }

}
