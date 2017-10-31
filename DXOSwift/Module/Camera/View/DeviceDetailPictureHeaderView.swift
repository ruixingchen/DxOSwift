//
//  DeviceDetailPictureHeaderView.swift
//  DXOSwift
//
//  Created by ruixingchen on 30/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import SnapKit

class DeviceDetailPictureHeaderView: UIView {

    let imageView:UIImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }

    func setupSubviews() {
        self.backgroundColor = UIColor.white
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(90)
            make.width.equalTo(120)
        }
    }

}
