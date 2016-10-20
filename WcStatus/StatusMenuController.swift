//
//  StatusMenuController.swift
//  WcStatus
//
//  Created by Michel Georgy on 04/04/16.
//  Copyright © 2016 Michel Georgy. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var occupiedTime: NSMenuItem!
    
    let disconnectedCachedTime = 10
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    override func awakeFromNib() {
        let icon = NSImage(named: "menu-na")
        icon?.template = true // best for dark mode
        statusItem.image = icon
        statusItem.menu = statusMenu
        
        // start timer with interval configured in settings
        // mainrunloop?
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(StatusMenuController.updateStatus), userInfo: nil, repeats: true)
    }
    
    func updateStatus(){
        // get status from server
        let statusApi = StatusApi()
        statusApi.fetchStatus(
            { status in
                NSLog("\(status)")
            
                var iconName = "menu-na"
                var timeString = "-"
                if(status.occupied == 1){
                    iconName = "menu-occupied"
                
                    let minutes = status.time / 60;
                    let seconds = status.time - (minutes * 60);
                    timeString = String(format: "%dm %ds", minutes, seconds)
                } else {
                    iconName = "menu-free"
                    timeString = ""
                }
            
                // update image
                // Update time, set title to occupiedtime
                dispatch_async(dispatch_get_main_queue()) {
                    self.statusItem.image = NSImage(named: iconName)
                    self.occupiedTime.title = timeString
                }
            }
            , { error in
                let iconName = "menu-na"
                let timeString = "-"
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.statusItem.image = NSImage(named: iconName)
                    self.occupiedTime.title = timeString
                }
            }
        )
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
}