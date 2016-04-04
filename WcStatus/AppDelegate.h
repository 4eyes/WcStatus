//
//  AppDelegate.h
//  WcStatus
//
//  Created by Michel Georgy on 15/10/14.
//  Copyright (c) 2014 Michel Georgy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSURLConnectionDelegate>

@property (strong) IBOutlet NSMenu *statusMenu;
@property (strong) NSStatusItem *statusBar;
@property (strong) IBOutlet NSMenuItem *occupiedTime;
@property BOOL running;
@property (atomic, strong) NSMutableData *responseData;
- (void) startTimer;
- (IBAction)getDataFromJson:(id)sender;
@end

