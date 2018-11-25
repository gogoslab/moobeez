//
//  Console.swift
//  Moobeez
//
//  Created by Radu Banea on 24/11/2018.
//  Copyright © 2018 Gogo's Lab. All rights reserved.
//

import Foundation
import SwiftyBeaver

public let Console = SwiftyBeaver.self

func initConsole() {
    
    // add log destinations. at least one is needed!
    let console = ConsoleDestination()  // log to Xcode Console
    //        let file = FileDestination()  // log to default swiftybeaver.log file
    let cloud = SBPlatformDestination(appID: "Gw3Yld", appSecret: "xcr9ln5yo8aVjjqbci2ej1jskulvgol2", encryptionKey: "Srunyjqj3t8eboChelvpxfytoyrbazs7") // to cloud
    
    // use custom format and set console output to short time, log level & message
    console.format = "$DHH:mm:ss $C$L $M"
    // or use this for JSON output: console.format = "$J"
    
    // add the destinations to SwiftyBeaver
    Console.addDestination(console)
    //        Console.addDestination(file)
    Console.addDestination(cloud)

}
