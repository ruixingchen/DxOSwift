//
//  CameraSpecification.swift
//  DXOSwift
//
//  Created by ruixingchen on 30/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation

extension Camera {
    struct Specification {
        var key:String
        var value:String

        var description:String {
            return "key: \(key)\nvalue:\(value)"
        }

    }
}
