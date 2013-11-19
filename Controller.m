#import "Controller.h"
#import <ApplicationServices/ApplicationServices.h>

@implementation Controller

-(void)awakeFromNib{
		
	_statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [_statusItem setHighlightMode:YES];
    [_statusItem setEnabled:YES];
    [_statusItem setMenu:menu];
	[_statusItem setTarget:self];
	//[_statusItem setAction:@selector(click)];
	[_statusItem setImage: [NSImage imageNamed:@"menu"]];

	loggedIn = true;
	timer = nil;

	[[[NSWorkspace sharedWorkspace] notificationCenter]		addObserver:self
															selector:@selector(switchHandler:)
																name:NSWorkspaceSessionDidBecomeActiveNotification
															  object:nil];
	[[[NSWorkspace sharedWorkspace] notificationCenter]		addObserver:self
															selector:@selector(switchHandler:)
																name:NSWorkspaceSessionDidResignActiveNotification
															  object:nil];

	NSUserDefaults * df = [NSUserDefaults standardUserDefaults];

	if([df stringForKey:@"timeOut"]){
		[minutesSlider setFloatValue:[df floatForKey:@"timeOut"]];
	}else{
		[minutesSlider setFloatValue:5.0];
	}

	[self handleTimer];
	[NSEvent addGlobalMonitorForEventsMatchingMask:NSRightMouseDownMask | NSScrollWheelMask | NSLeftMouseDownMask | NSMouseMovedMask | NSKeyDownMask
										   handler:^(NSEvent* e) {
											   //NSLog(@"event!");
											   [self handleTimer];
										   }];

}


- (IBAction)slider:(id)sender{
	NSUserDefaults * df = [NSUserDefaults standardUserDefaults];
	[df setFloat:[sender floatValue] forKey:@"timeOut"];
	[df synchronize];
	[self handleTimer];
}


- (void) switchHandler:(NSNotification*) notification {

	if ([[notification name] isEqualToString: NSWorkspaceSessionDidResignActiveNotification]){
		loggedIn = false;
		if(DEBUG_SAY) [NSTask launchedTaskWithLaunchPath:@"/usr/bin/say" arguments:@[@"goodbye"] ];
	}else{
		loggedIn = true;
		if(DEBUG_SAY)[NSTask launchedTaskWithLaunchPath:@"/usr/bin/say" arguments:@[@"hello"] ];
	}
	[self handleTimer];
}


-(void)handleTimer{
	if(timer != nil){
		if([timer isValid]){
			[timer invalidate];
		}
		timer = nil;
	}
	if(loggedIn){ //only schedule timer if logged in
		float fireIn = [minutesSlider floatValue] * 60.0;
		//NSLog(@"start timer for %f sec", fireIn);
		timer = [NSTimer scheduledTimerWithTimeInterval: fireIn target:self selector:@selector(timeout) userInfo:nil repeats:NO];
		[[NSRunLoop currentRunLoop] addTimer: timer forMode:NSEventTrackingRunLoopMode];
	}
}


- (void)timeout{

	timer = nil;
	if(DEBUG_SAY) [NSTask launchedTaskWithLaunchPath:@"/usr/bin/say" arguments:@[@"timeOut"] ];

	//this takes us to login screen, without logging out
	[NSTask launchedTaskWithLaunchPath:@"/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession"
							 arguments:@[@"-suspend", @">", @"/dev/null"] ];
}


- (IBAction)do:(id)sender{
	switch ([sender tag]) {
		case 0: //about
			[aboutWin center];
			[aboutWin makeKeyAndOrderFront:self];
			[aboutWin setLevel:NSNormalWindowLevel + 1];
			break;
				
		case 1: //quit
			[NSApp terminate:self];
			break;

		default:
			break;
	}
}

@end