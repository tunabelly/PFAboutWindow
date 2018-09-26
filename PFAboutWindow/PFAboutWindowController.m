//
//  PFAboutWindowController.m
//
//  Copyright (c) 2015 Perceval FARAMAZ (@perfaram). All rights reserved.
//

#import "PFAboutWindowController.h"

@interface PFAboutWindowController()

/** The window nib to load. */
+ (NSString *)nibName;

/** The info view. */
@property (assign) IBOutlet NSView *infoView;

/** The main text view. */
@property (assign) IBOutlet NSTextView *textField;

/** The button that opens the app's website. */
@property (assign) IBOutlet NSButton *visitWebsiteButton;

/** The button that opens the EULA. */
@property (assign) IBOutlet NSButton *EULAButton;

/** The button that opens the credits. */
@property (assign) IBOutlet NSButton *creditsButton;

/** The view that's currently active. */
@property (assign) NSView *activeView;

/** The string to hold the credits if we're showing them in same window. */
@property (copy) NSAttributedString *creditsString;

@end

@implementation PFAboutWindowController

#pragma mark - Class Methods

+ (NSString *)nibName {
    return @"PFAboutWindow";
}

#pragma mark - Overrides

- (id)init {
    
    self.windowShouldHaveShadow = YES;
	self.creditsFileExtension = @"rtf";
	self.eulaFileExtension = @"rtf";
	
    return [super initWithWindowNibName:[[self class] nibName]];
}

- (void)windowDidLoad {
    [super windowDidLoad];
	self.windowState = 0;
	self.infoView.layer.cornerRadius = 10.0;
	self.window.backgroundColor = [NSColor windowBackgroundColor];
    [self.window setHasShadow:self.windowShouldHaveShadow];
    // Change highlight of the `visitWebsiteButton` when it's clicked. Otherwise, the button will have a highlight around it which isn't visually pleasing.
       [self.visitWebsiteButton.cell setHighlightsBy:NSContentsCellMask];
   
    // Load variables
    NSDictionary *bundleDict = [[NSBundle mainBundle] infoDictionary];
    
    // Set app name
    if(!self.appName) {
        self.appName = [bundleDict objectForKey:@"CFBundleName"];
    }
    
    // Set app version
    if(!self.appVersion) {
        NSString *version = [bundleDict objectForKey:@"CFBundleVersion"];
        NSString *shortVersion = [bundleDict objectForKey:@"CFBundleShortVersionString"];
        self.appVersion = [NSString stringWithFormat:NSLocalizedString(@"Version %@ (Build %@)", @"Version %@ (Build %@), displayed in the about window"), shortVersion, version];
    }
	
    // Set copyright
    if(!self.appCopyright) {
        
        if (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_9){
            //On OS X Mavericks or below
            
            //Therefore we need to set properties that are available on OS X Mavericks or below
            self.appCopyright = [[NSAttributedString alloc] initWithString:[bundleDict objectForKey:@"NSHumanReadableCopyright"] attributes:@{
                                                                                                                                              NSForegroundColorAttributeName : [NSColor lightGrayColor],//Looks very close to 'tertiaryLabelColor' on OS X Yosemite
                                                                                                                                              NSFontAttributeName:[NSFont fontWithName:@"HelveticaNeue" size:11]/*/NSParagraphStyleAttributeName  : paragraphStyle*/}];
            
        } else{
            
            //On OS 10.10 or later. We don't need to do anything special
            
            self.appCopyright = [[NSAttributedString alloc] initWithString:[bundleDict objectForKey:@"NSHumanReadableCopyright"] attributes:@{
                                                                                                                                              NSForegroundColorAttributeName : [NSColor tertiaryLabelColor],
                                                                                                                                              NSFontAttributeName			: [NSFont fontWithName:@"HelveticaNeue" size:11]/*,
                                                                                                                                                                                                                             NSParagraphStyleAttributeName  : paragraphStyle*/}];
        }

    }
	
    // get the default text color for the current UI appearance
    NSDictionary *textColorAttribs = @{NSForegroundColorAttributeName : [NSColor textColor]};
    
	// Code that can potentially throw an exception
	
	// Set credits
	if(!self.appCredits) {
		@try {
            // make sure the Credits are displayed with the correct text color for the UI mode (light vs dark)
			NSAttributedString *tempCredits = [[NSAttributedString alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"Credits" ofType:self.creditsFileExtension] documentAttributes:nil];
            self.appCredits = [[NSMutableAttributedString alloc] initWithAttributedString:tempCredits];
            [self.appCredits addAttributes:textColorAttribs range:NSMakeRange(0, self.appCredits.length)];
		}
		@catch (NSException *exception) {
			// hide the credits button
			[self.creditsButton setHidden:YES];
			
			 NSLog(@"PFAboutWindowController did handle exception: %@",exception);
		}
	}
	
	// Set EULA
	if(!self.appEULA) {
		@try {
            // make sure the EULA is displayed with the correct text color for the UI mode (light vs dark)
            NSAttributedString *tempEULA = [[NSAttributedString alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"EULA" ofType:self.eulaFileExtension] documentAttributes:nil];
            self.appEULA = [[NSMutableAttributedString alloc] initWithAttributedString:tempEULA];
            [self.appEULA addAttributes:textColorAttribs range:NSMakeRange(0, self.appEULA.length)];
        }
		@catch (NSException *exception) {
			// hide the eula button
			[self.EULAButton setHidden:YES];
			
			NSLog(@"PFAboutWindowController did handle exception: %@",exception);
		}
	}

	[self.textField.textStorage setAttributedString:self.appCopyright];
	self.creditsButton.title = NSLocalizedString(@"Acknowledgments", @"Caption of the 'Credits' button in the about window");
	self.EULAButton.title = NSLocalizedString(@"License Agreement", @"Caption of the 'License Agreement' button in the about window");
}

- (BOOL)windowShouldClose:(id)sender {
	[self showCopyright:sender];
	return TRUE;
}

-(void) showCredits:(id)sender {
	if (self.windowState!=1) {
		CGFloat amountToIncreaseHeight = 100;
		NSRect oldFrame = [self.window frame];
		oldFrame.size.height += amountToIncreaseHeight;
		oldFrame.origin.y -= amountToIncreaseHeight;
		[self.window setFrame:oldFrame display:YES animate:NSAnimationLinear];
		self.windowState = 1;
	}
	[self.textField.textStorage setAttributedString:self.appCredits];
}

-(void) showEULA:(id)sender {
	if (self.windowState!=1) {
		CGFloat amountToIncreaseHeight = 100;
		NSRect oldFrame = [self.window frame];
		oldFrame.size.height += amountToIncreaseHeight;
		oldFrame.origin.y -= amountToIncreaseHeight;
		[self.window setFrame:oldFrame display:YES animate:NSAnimationLinear];
		self.windowState = 1;
	}
	[self.textField.textStorage setAttributedString:self.appEULA];
}

-(void) showCopyright:(id)sender {
	if (self.windowState!=0) {
		CGFloat amountToIncreaseHeight = -100;
		NSRect oldFrame = [self.window frame];
		oldFrame.size.height += amountToIncreaseHeight;
		oldFrame.origin.y -= amountToIncreaseHeight;
		[self.window setFrame:oldFrame display:YES animate:NSAnimationLinear];
		self.windowState = 0;
	}
	[self.textField.textStorage setAttributedString:self.appCopyright];
}

- (IBAction)visitWebsite:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:self.appURL];
}

- (void)showWindow:(id)sender
{
	// make sure the window will be visible and centered
	[NSApp activateIgnoringOtherApps:YES];
	[self.window center];
	
    [super showWindow:sender];
}

#pragma mark - Private Methods

@end
