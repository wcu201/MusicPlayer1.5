//
//  MarqueeLabel.swift
//  MusicPlayer1.5
//
//  Created by William  Uchegbu on 8/16/20.
//  Copyright © 2020 William  Uchegbu. All rights reserved.
//

import UIKit
import WebKit

class MarqueeLabel: WKWebView {
    public var direction: marqueeDirection

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        self .direction = .left
        super.init(frame: frame, configuration: configuration)
        let marquee = "<marquee style='font-size:10vw'>This is sample marquee</marquee>"
        self.loadHTMLString(marquee, baseURL: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

public enum marqueeDirection {
    case left
    case right
}
