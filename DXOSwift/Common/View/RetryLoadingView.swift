//
//  RetryLoadingView.swift
//  DXOSwift
//
//  Created by ruixingchen on 24/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit
import SnapKit

protocol RetryLoadingViewDelegate:class {
    func retryLoadingViewDidTapRetryButton(retryLoadingView: RetryLoadingView)
}

class RetryLoadingView: UIView {

    var titleLabel:UILabel = UILabel()
    var retryButton:UIButton = UIButton(type: UIButtonType.roundedRect)

    weak var delegate:RetryLoadingViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }

    private func setupSubviews(){

        titleLabel.text = "request_failed_n_please_try_again_later".localized()
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.gray
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().offset(-36)
            make.bottom.equalTo(self.snp.centerY).offset(-8)
        }
        retryButton.tintColor = UIColor.gray
        retryButton.layer.cornerRadius = 4
        retryButton.layer.borderWidth = 1
        retryButton.layer.borderColor = UIColor.gray.cgColor
        let title:String = "title_retry".localized()
        retryButton.setTitle(title, for: UIControlState.normal)
        retryButton.addTarget(self, action: #selector(didTapRetryButton), for: UIControlEvents.touchUpInside)
        self.addSubview(retryButton)
        retryButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.snp.centerY).offset(8)
//            let titleSize:CGSize = title.size(font: UIFont.systemFont(ofSize: UIFont.buttonFontSize))
            make.width.equalTo(100)
            make.height.equalTo(25)
        }
    }

    @objc func didTapRetryButton(){
        self.delegate?.retryLoadingViewDidTapRetryButton(retryLoadingView: self)
    }

}
