//
//  Console.swift
//  Moobeez
//
//  Created by Mobilauch Labs on 20.03.2024.
//  Copyright © 2024 Gogo's Lab. All rights reserved.
//

import Foundation
import os.log

public enum ConsoleType: String {
    case info = "❕"
    case debug = "☢️"
    case warning = "⚠️"
    case error = "❌"
    case connection = "🌐"
    case response = "🏮"
}

open class Console: NSObject {

    static public var subsystem = "com.mobilaunchlabs.mll"
    static public var defaultCategory = "Core"
    
    static public var debugUsername:String?
    
    
    static public var types:[ConsoleType] = [.info,
                                      .debug,
                                      .warning,
                                      .error,
                                      .connection,
                                      .response
                                    ]
    
    static var typesAliases:[ConsoleType : OSLogType] = [.info : .info,
                                                       .debug : .default,
                                                       .error : .error,
                                                       .warning: .fault,
                                                       .connection : .default,
                                                       .response : .default]
    
    
    class func log (_ string: String, type:ConsoleType = .debug, category: String? = nil)
    {
        guard types.contains(type) else {
            return
        }
        
        let osLog = OSLog(subsystem: subsystem, category: category ?? defaultCategory)
        
        os_log("\n%@ %@", log: osLog, type: typesAliases[type]!, type.rawValue, string)
    }
    
    open class func info (_ string: String, _ category: String? = nil)
    {
        log(string, type: .info, category: category)
    }
    
    open class func debug (_ string: String, _ category: String? = nil)
    {
        log(string, type: .debug, category: category)
    }
    
    open class func warning (_ string: String, _ category: String? = nil)
    {
        log(string, type: .warning, category: category)
    }
    
    open class func error (_ string: String, _ category: String? = nil)
    {
        log(string, type: .error, category: category)
    }
    
    open class func debugConnection (_ string: String, _ category: String = "Network")
    {
        log(string, type: .connection, category: category)
    }
    
    open class func debugResponse (_ string: String, _ category: String = "Network")
    {
        log(string, type: .response, category: category)
    }
    
}
