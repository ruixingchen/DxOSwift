//
//  UserDefaultsManager.swift
//  DXOSwift
//
//  Created by ruixingchen on 30/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation

class UserDefaultsManager {

    struct Define {
        static let lastCameraDatabaseLoaded:String = "lastCameraDatabaseLoaded"
        static let lastLensDatabaseLoaded:String = "lastLensDatabaseLoaded"
    }

    private static var _lastCameraDatabaseLoaded:TimeInterval!
    private static var _lastLensDatabaseLoaded:TimeInterval!

    static var lastCameraDatabaseLoaded:TimeInterval {
        get{
            if _lastCameraDatabaseLoaded == nil {
                _lastCameraDatabaseLoaded = UserDefaults.standard.double(forKey: Define.lastCameraDatabaseLoaded)
            }
            return _lastCameraDatabaseLoaded
        }
        set{
            _lastCameraDatabaseLoaded = newValue
            UserDefaults.standard.set(newValue, forKey: Define.lastCameraDatabaseLoaded)
            UserDefaults.standard.synchronize()
        }
    }

    static var lastLensDatabaseLoaded:TimeInterval {
        get{
            if _lastLensDatabaseLoaded == nil {
                _lastLensDatabaseLoaded = UserDefaults.standard.double(forKey: Define.lastLensDatabaseLoaded)
            }
            return _lastLensDatabaseLoaded
        }
        set{
            _lastLensDatabaseLoaded = newValue
            UserDefaults.standard.set(newValue, forKey: Define.lastLensDatabaseLoaded)
            UserDefaults.standard.synchronize()
        }
    }


}
