//
//  NewSongTableViewCell.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 6/21/20.
//  Copyright © 2020 William  Uchegbu. All rights reserved.
//

import UIKit

class NewSongTableViewCell: UITableViewCell {
    let titleText = UILabel()
    let artistText = UILabel()
    let artwork = UIImageView()
    let toolsBTN = UIButton()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupUI()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI(){
        self.backgroundColor = .clear
        //UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1)
        
        self.artwork.translatesAutoresizingMaskIntoConstraints = false
        self.titleText.translatesAutoresizingMaskIntoConstraints = false
        self.artistText.translatesAutoresizingMaskIntoConstraints = false
        self.toolsBTN.translatesAutoresizingMaskIntoConstraints = false
        
        artwork.image = #imageLiteral(resourceName: "album-cover-placeholder-light")
        if #available(iOS 13.0, *) {
            toolsBTN.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        toolsBTN.tintColor = mainRed
        titleText.textColor = .white
        artistText.textColor = mainRed
        titleText.font = UIFont(name: "Avenir Book", size: 17.0)
        artistText.font = UIFont(name: "Avenir Book", size: 12.0)
//        "ellipsis"
//        "ellipsis.circle"
//        "ellipsis.circle.fill"
        
        self.contentView.addSubview(artwork)
        self.contentView.addSubview(titleText)
        self.contentView.addSubview(artistText)
        self.contentView.addSubview(toolsBTN)
    }
    
    func setupConstraints(){
        self.contentView.addConstraints([
            NSLayoutConstraint(item: self.artwork, attribute: .height, relatedBy: .equal, toItem: self.contentView, attribute: .height, multiplier: 0.8, constant: 0),
            NSLayoutConstraint(item: self.artwork, attribute: .width, relatedBy: .equal, toItem: self.artwork, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.artwork, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.artwork, attribute: .leading, relatedBy: .equal, toItem: self.contentView, attribute: .leading, multiplier: 1, constant: 8),
        ])
        
        self.contentView.addConstraints([
            NSLayoutConstraint(item: self.titleText, attribute: .leading, relatedBy: .equal, toItem: self.artwork, attribute: .trailing, multiplier: 1, constant: 8),
            NSLayoutConstraint(item: self.titleText, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.titleText, attribute: .top, relatedBy: .equal, toItem: self.artwork, attribute: .top, multiplier: 1, constant: 0),
            //NSLayoutConstraint(item: self.titleText, attribute: .leading, relatedBy: .equal, toItem: self.artwork, attribute: .trailing, multiplier: 1, constant: 0),
        ])
        
        self.contentView.addConstraints([
            NSLayoutConstraint(item: self.artistText, attribute: .leading, relatedBy: .equal, toItem: self.titleText, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.artistText, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.artistText, attribute: .top, relatedBy: .equal, toItem: self.titleText, attribute: .bottom, multiplier: 1, constant: 0),
            //NSLayoutConstraint(item: self.titleText, attribute: .leading, relatedBy: .equal, toItem: self.artwork, attribute: .trailing, multiplier: 1, constant: 0),
        ])
        
        self.contentView.addConstraints([
            NSLayoutConstraint(item: self.toolsBTN, attribute: .height, relatedBy: .equal, toItem: self.contentView, attribute: .height, multiplier: 0.8, constant: 0),
            NSLayoutConstraint(item: self.toolsBTN, attribute: .width, relatedBy: .equal, toItem: self.toolsBTN, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.toolsBTN, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.toolsBTN, attribute: .trailing, relatedBy: .equal, toItem: self.contentView, attribute: .trailing, multiplier: 1, constant: -8)
        ])
    }

}
