//
//  AppDelegate.swift
//  swifttest
//
//  Created by Michel Georgy on 22/04/16.
//  Copyright © 2016 4eyes GmbH. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow?
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // RavenClient.clientWithDSN("https://0b39620615164851b0abad13067dee23:e700bc97d4f143bba02f85358704dc93@logs.4eyes.ch/40")
        // RavenClient.sharedClient?.setupExceptionHandler()
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    
}
