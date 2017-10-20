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

    class func test(){
        let cameraJson = JSON(data: Data(forResource: "cameraDataBase.json")!)
        let lensJson = JSON(data: Data(forResource: "lensDataBase.json")!)

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


}
