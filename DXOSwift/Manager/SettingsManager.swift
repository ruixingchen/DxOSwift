//
//  SettingsManager.swift
//  DXOSwift
//
//  Created by ruixingchen on 26/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import UIKit

class SettingsManager {

    fileprivate struct Define {
        static let key_mobilePreviewLanguage:String = "mobilePreviewLanguage"
    }

    fileprivate static var _mobilePreviewLanguage:Int!

    /// simplified and traditional are both Chinese
    fileprivate static var _shouldUseChinese:Bool!

    /// 1: follow system, 2:english, 3:chinese
    static var mobilePreviewLanguage:Int {
        get {
            if _mobilePreviewLanguage == nil {
                _mobilePreviewLanguage = UserDefaults.standard.integer(forKey: Define.key_mobilePreviewLanguage)
                if _mobilePreviewLanguage == 0 {
                    _mobilePreviewLanguage = 1
                }
            }
            return _mobilePreviewLanguage
        }
        set{
            if newValue < 1 || newValue > 3 {
                return
            }
            UserDefaults.standard.set(newValue, forKey: Define.key_mobilePreviewLanguage)
            UserDefaults.standard.synchronize()
            _mobilePreviewLanguage = newValue
        }
    }

    static var shouldUseChinese:Bool {
        get {
            if _shouldUseChinese == nil {
                let language = (NSLocale.preferredLanguages.first ?? "").lowercased()
                log.debug("device language: \(language)")
                if language.hasPrefix("zh") {
                    _shouldUseChinese = true
                }else{
                    _shouldUseChinese = false
                }
            }
            return _shouldUseChinese
        }
    }

}
