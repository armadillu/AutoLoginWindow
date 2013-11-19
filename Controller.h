/* Controller */

#import <Cocoa/Cocoa.h>

#define DEBUG_SAY false

@interface Controller : NSObject
{
    IBOutlet id menu;
	IBOutlet id aboutWin;
	IBOutlet NSSlider* minutesSlider;
	
	NSStatusItem	*_statusItem;
	NSTimer * timer;
	NSURLRequest * request;

	bool loggedIn;

}


- (void)timeout;
- (IBAction)do:(id)sender;
- (IBAction)slider:(id)sender;
@end
