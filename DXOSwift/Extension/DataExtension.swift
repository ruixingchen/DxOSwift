//
//  DataExtension.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation

extension Data {
    /// get the file in bundle
    init?(bundle:Bundle = Bundle.main, forResource resource:String?, ofType type:String? = nil) {
        guard let path:String = bundle.path(forResource: resource, ofType: type) else {
            return nil
        }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data.init(contentsOf: url) else {
            return nil
        }
        self = data
    }

}
