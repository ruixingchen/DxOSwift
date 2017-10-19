//
//  RXTableViewCell.swift
//  SampleProject
//
//  Created by ruixingchen on 18/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class RXTableViewCell: UITableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }

    func setupSubviews(){

    }
}
