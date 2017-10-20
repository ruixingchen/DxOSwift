//
//  DataBaseManager.swift
//  DXOSwift
//
//  Created by ruixingchen on 20/10/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation
import FMDB

class DataBaseManager {

    /// just shared is OK
    static let shared:DataBaseManager = DataBaseManager()

    var mainDB: FMDatabase!
    var dbPath: String!

    private init() {
        var path: String?
        #if DEBUG || debug
            //for easy to get file
            path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        #else
            //for safe
            path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        #endif
        log.debug("main DB direct: \(path ?? "nil")")
        if path != nil {
            path! += "/database.db"
        } else {
            log.error("can not get sand box path")
        }
        dbPath = path
        mainDB = FMDatabase(path: path)
        if mainDB?.open() != true {
            log.error("failed to open DB")
        }
    }

}
