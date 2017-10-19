//
//  RXError.swift
//  CoolApkSwift
//
//  Created by ruixingchen on 15/09/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation

class RXError: Error {
    
    var error: Error? //the origin error object
    var userInfo: UserInfo? //the user info for storing some objects
    var domain: String = "" //the domain, the default is empty
    var code: Int = 0 //the error code, default is 0
    var errorDescription: String? //the error description, default is nil

    var description:String {
        var text:String = ""
        text.append("origin error: \(error?.localizedDescription ?? "nil")\n")
        text.append("domain:\(domain)\n")
        text.append("code:\(code)\n")
        text.append("error description:\(errorDescription ?? "nil")\n")
        text.append("user info:\(userInfo?.description ?? "nil")")
        return text
    }

    convenience init(error:Error?, errorDescription: String? = nil) {
        self.init()
        self.error = error
    }

    convenience init(description:String?) {
        self.init()
        self.errorDescription = description
    }
}
