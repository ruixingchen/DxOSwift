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
        static let key_mobilePreviewLanguage:String = "settings_mobilePreviewLanguage"
        static let key_databaseHDImage:String = "setting_databaseHDImage"
    }

    fileprivate static var _mobilePreviewLanguage:Int!
    fileprivate static var _databaseHDImage:Bool!

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

    static var databaseHDImage:Bool {
        get {
            if _databaseHDImage == nil {
                _databaseHDImage = UserDefaults.standard.object(forKey: Define.key_databaseHDImage) as? Bool
                if _databaseHDImage == nil {
                    //default
                    _databaseHDImage = true
                }
            }
            return _databaseHDImage
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Define.key_databaseHDImage)
            UserDefaults.standard.synchronize()
            _databaseHDImage = newValue
        }
    }

}

// MARK: - DEBUG
extension SettingsManager {

    static var debug_ignore_cache:Bool {
        get {
            return (UserDefaults.standard.object(forKey: "debug_ignore_cache") as? Bool) ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "debug_ignore_cache")
            UserDefaults.standard.synchronize()
        }
    }

    static var debug_log_request:Bool {
        get {
            return (UserDefaults.standard.object(forKey: "debug_log_request") as? Bool) ?? false
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "debug_log_request")
            UserDefaults.standard.synchronize()
        }
    }

}
