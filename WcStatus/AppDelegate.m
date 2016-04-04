//
//  AppDelegate.m
//  WcStatus
//
//  Created by Michel Georgy on 15/10/14.
//  Copyright (c) 2014 Michel Georgy. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate

@synthesize statusBar = _statusBar;
@synthesize occupiedTime;
@synthesize running;
@synthesize responseData;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self getDataFromJson:self];
    [self setResponseData:[NSMutableData data]];
    [[NSRunLoop mainRunLoop]
        addTimer:[NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(getDataFromJson:) userInfo:nil repeats:YES]
        forMode:NSRunLoopCommonModes];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
}

- (void) awakeFromNib {
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    //self.statusBar.title = @"WC";
    NSImage *menuIcon = [NSImage imageNamed:@"menu-na"];
   
    [[self statusBar] setImage:menuIcon];
    [[self statusBar] setEnabled:YES];
    self.statusBar.menu = self.statusMenu;
}

- (IBAction)getDataFromJson:(id)sender {
    // Set the queue to the background queue. We will run this on the background thread to keep
    // the UI Responsive.
//    dispatch_queue_t queue =    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    // Run request on background queue (thread).
//    dispatch_async(queue, ^{
    if(!running){
        running = YES;
        NSURLRequest *request = [NSURLRequest requestWithURL:
                                 [NSURL URLWithString:@"http://192.168.1.252"] cachePolicy:nil timeoutInterval:5.0f];
        [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
        /*NSURL *url = [NSURL URLWithString:@"http://192.168.1.252"];
        NSData *jsonData = [NSData dataWithContentsOfURL:url];*/
    
    }
    
//   });
        
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    NSLog(@"Received %d bytes of data",[data length]);
    NSLog(@"Received %d bytes of data",[self.responseData length]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog([NSString stringWithFormat:@"Connection failed: %@", [error description]]);
    
    NSString * status = @"menu-na";
    int minutes = 0;
    int seconds = 0;
    [self updateStatus:status withMinutes:minutes andSeconds:seconds];
    running = NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[self.responseData length]);
    
    NSString * status = @"menu-na";
    int minutes = 0;
    int seconds = 0;
    if(self.responseData != nil)
    {
        NSError *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingMutableContainers error:&error];
        if (error == nil){
            if([[result valueForKey:@"occupied"] integerValue]){
                status = @"menu-occupied";
            } else {
                status = @"menu-free";
            }
            int totalSeconds = [[result valueForKey:@"time"] integerValue];
            minutes = totalSeconds / 60;
            seconds = totalSeconds - (minutes * 60);
            
            NSLog(@"%@", result);
        }
    }

    [self updateStatus:status withMinutes:minutes andSeconds:seconds];
    running = NO;
}

- (void) updateStatus:(NSString *)status withMinutes:(int)minutes andSeconds:(int)seconds{
    NSImage *menuIcon = [NSImage imageNamed:status];
    [[self statusBar] setImage:menuIcon];
    [self.occupiedTime setTitle:[NSString stringWithFormat:@"%dm %ds", minutes, seconds]];
}

@end
