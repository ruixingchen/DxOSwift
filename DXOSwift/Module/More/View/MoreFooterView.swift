//
//  MoreFooterView.swift
//  DXOSwift
//
//  Created by ruixingchen on 23/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import SnapKit

class MoreFooterView: UIView {

    let imageView:UIImageView = UIImageView(image: UIImage(named: "header-logo"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }

    func setupSubviews() {
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(250)
            make.height.equalTo(30)
        }
    }

}
