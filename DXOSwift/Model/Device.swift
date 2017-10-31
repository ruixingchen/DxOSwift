//
//  Device.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation
import SwiftyJSON

class Device {

    enum Status: String {
        case tested = "TESTED"
    }

    var specification:[Specification]?

    class func test(){
        let cameraJson = JSON(data: Data(forResource: "cameraDatabase.json")!)
        let lensJson = JSON(data: Data(forResource: "lensDatabase.json")!)

        var array:[String] = []

        for node in cameraJson["data"].arrayValue {
            let content = node["brand"].string?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if content == nil {
                print("nil")
            }
            if !array.contains(content!) {
                array.append(content!)
            }
        }
        print(array)

        array = []
        for node in lensJson["data"].arrayValue {
            let content = node["lens_type"].string?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if content == nil {
                print("nil")
            }
            if !array.contains(content!) {
                array.append(content!)
            }
        }
        print(array)
    }

}

extension Device {
    enum DeviceType {
        case camera, lens, mobile
    }

    struct Specification {
        var key:String {
            didSet {
                updateLocalizedKey()
            }
        }
        var value:String {
            didSet {
                updateLocalizedValue()
            }
        }

        var description:String {
            return "key: \(key)\nvalue:\(value)"
        }

        init(key:String, value:String) {
            self.key = key
            self.value = value
            updateLocalizedKey()
            updateLocalizedValue()
        }

        var c_localizedKey:String = ""
        var c_localizedValue:String = ""

        mutating func updateLocalizedKey() {
            if key.isEmpty {
                c_localizedKey = ""
                return
            }
            switch key {
            case "Announced":
                c_localizedKey = LocalizedString.camera_detail_landscape_des
            default:
                c_localizedKey = key
            }
        }

        mutating func updateLocalizedValue(){
            if value.isEmpty {
                c_localizedValue = ""
            }
            switch value {
            default:
                c_localizedValue = value
            }
        }

    }
}
