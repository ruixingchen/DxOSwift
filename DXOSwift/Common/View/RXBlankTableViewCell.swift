//
//  RXBlankTableViewCell.swift
//  SampleProject
//
//  Created by ruixingchen on 18/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class RXBlankTableViewCell: RXTableViewCell {

    #if DEBUG || debug
        let infoLabel:UILabel = UILabel()
    #endif

    init(reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setupSubviews() {
        super.setupSubviews()
        #if DEBUG || debug
            infoLabel.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(infoLabel)
            NSLayoutConstraint(item: infoLabel, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: infoLabel, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 16).isActive = true
            NSLayoutConstraint(item: infoLabel, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.contentView, attribute: NSLayoutAttribute.right, multiplier: 1, constant: -16).isActive = true
        #endif
    }
}
