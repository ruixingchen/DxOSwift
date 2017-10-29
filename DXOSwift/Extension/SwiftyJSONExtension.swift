//
//  SwiftyJSONExtension.swift
//  DXOSwift
//
//  Created by ruixingchen on 29/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {

    /// convert string to int automaticly
    var autoInt:Int? {
        switch self.type {
        case .string:
            return self.string?.toInt()
        case .number:
            return self.number?.intValue
        case .bool:
            return self.boolValue ? 1 : 0
        default:
            return nil
        }
    }

    /// convert string to float automaticly
    var autoFloat:Float? {
        switch self.type {
        case .string:
            return self.string?.toFloat()
        case .number:
            return self.number?.floatValue
        case .bool:
            return self.boolValue ? 1 : 0
        default:
            return nil
        }
    }

    /// convert string to double automaticly
    var autoDouble:Double? {
        switch self.type {
        case .string:
            return self.string?.toDouble()
        case .number:
            return self.number?.doubleValue
        case .bool:
            return self.boolValue ? 1 : 0
        default:
            return nil
        }
    }

}
