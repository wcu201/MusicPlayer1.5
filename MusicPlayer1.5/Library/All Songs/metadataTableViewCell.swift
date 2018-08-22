//
//  metadataTableViewCell.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 7/22/18.
//  Copyright © 2018 William  Uchegbu. All rights reserved.
//

import UIKit

class metadataTableViewCell: UITableViewCell {
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func edit(_ sender: Any) {
        textfield.isUserInteractionEnabled = true
        textfield.becomeFirstResponder()
    }
}
