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
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    override func awakeFromNib() {
        let icon = NSImage(named: "menu-na")
        icon?.isTemplate = true // best for dark mode
        statusItem.button!.image = icon
        statusItem.menu = statusMenu
        
        // start timer with interval configured in settings
        // mainrunloop?
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(StatusMenuController.updateStatus), userInfo: nil, repeats: true)
    }
    
    @objc func updateStatus(){
        // get status from server
        let statusApi = StatusApi()
        statusApi.fetchStatus(
            success: { status in
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
                DispatchQueue.global(qos: .background).async {
                    // Background Thread
                    DispatchQueue.main.async {
                        self.statusItem.button!.image = NSImage(named: iconName)
                        self.occupiedTime.title = timeString
                    }
                }
            }
            , failure: { error in
                let iconName = "menu-na"
                let timeString = "-"
                
                DispatchQueue.global(qos: .background).async {
                    // Background Thread
                    DispatchQueue.main.async {
                    self.statusItem.button!.image = NSImage(named: iconName)
                    self.occupiedTime.title = timeString
                    }
                }
            }
        )
    }
    
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}
