//
//  ArrayExtension.swift
//  CoolApkSwift
//
//  Created by ruixingchen on 09/09/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation

extension Array {

    func safeGet(at index: Int) -> Array.Element? {
        if index < 0 || index >= self.count {
            return nil
        }
        return self[index]
    }
}

extension NSArray {

    func safeGet(at index: Int) -> NSArray.Element? {
        if index < 0 || index >= self.count {
            return nil
        }
        return self[index]
    }
}
