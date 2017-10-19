//
//  Log.swift
//  CoolApkSwift
//
//  Created by ruixingchen on 09/09/2017.
//  Copyright © 2017 ruixingchen. All rights reserved.
//

import Foundation
import XCGLogger

let log: Log = {
    #if DEBUG
        return Log(level: Log.Level.verbose)
    #else
        return Log(level: Log.Level.error)
    #endif
}()

//TODO: - implement log function with an embeded class

/// make logs with XCGLogger, make a class to avoid using third party directly
class Log {

    enum Level {
        case verbose
        case debug
        case info
        case warning
        case error
        case severe
    }

    let logger: XCGLogger

    init(level: Level) {
        self.logger = XCGLogger()
        var xcgLevel: XCGLogger.Level = XCGLogger.Level.verbose
        switch level {
        case .verbose:
            xcgLevel = .verbose
        case .debug:
            xcgLevel = .debug
        case .info:
            xcgLevel = .info
        case .warning:
            xcgLevel = .warning
        case .error:
            xcgLevel = .error
        case .severe:
            xcgLevel = .severe
        }
        //TODO: log to file in the future
        logger.setup(level: xcgLevel, showLogIdentifier: false, showFunctionName: true, showThreadName: true, showLevel: false, showFileNames: true, showLineNumbers: true, showDate: true, writeToFile: nil, fileLevel: nil)
    }

    private func handleLogInput(closure:@autoclosure () -> Any?, level:XCGLogger.Level)->String{
        guard let closureResult:Any = closure() else {
            return ""
        }
        let closureResultString:String = String(describing: closureResult)
        var heart:String!
        switch level {
        case .verbose:
            heart = "💚"
        case .debug:
            heart = "💚"
        case .info:
            heart = "💙"
        case .warning:
            heart = "💛💛"
        case .error:
            heart = "❤️❤️❤️"
        case .severe:
            heart = "💔💔💔💔"
        default:
            heart = "💚"
        }
        return "\n".appending(heart).appending("\n").appending(closureResultString).appending("\n========")
    }

    /// a verbose info, the color is purple...what? green?
    func verbose(_ closure:@autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
        logger.logln(.verbose, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo) {
            return handleLogInput(closure: closure, level: .verbose)
        }
    }

    /// a debug info, the color is green
    func debug(_ closure:@autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
        logger.logln(.debug, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo) {
            return handleLogInput(closure: closure, level: .debug)
        }
    }

    /// an info info, the color is blue
    func info(_ closure:@autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
        logger.logln(.info, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo) {
            return handleLogInput(closure: closure, level: .info)
        }
    }

    /// something is wrong, the color is orange
    func warning(_ closure:@autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
        logger.logln(.warning, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo) {
            return handleLogInput(closure: closure, level: .warning)
        }
    }

    /// this is not going to be happening, this can't be happening, the color is red
    func error(_ closure:@autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
        logger.logln(.error, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo) {
            return handleLogInput(closure: closure, level: .error)
        }
    }

    /// I will be killed, the color is red and broken
    func severe(_ closure:@autoclosure () -> Any?, functionName: StaticString = #function, fileName: StaticString = #file, lineNumber: Int = #line, userInfo: [String: Any] = [:]) {
        logger.logln(.severe, functionName: functionName, fileName: fileName, lineNumber: lineNumber, userInfo: userInfo) {
            return handleLogInput(closure: closure, level: .severe)
        }
    }

}
