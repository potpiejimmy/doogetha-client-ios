//
//  DGRegisterConfirmController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 28.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DGRegisterConfirmController.h"
#import "DGUtils.h"
#import "TLUtils.h"

@implementation DGRegisterConfirmController

@synthesize pinLabel = _pinLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

    NSString* loginToken = [DGUtils app].loginToken;
    NSArray* tok = [loginToken componentsSeparatedByString:@":"];
    self.pinLabel.text = [NSString stringWithFormat:@"PIN: %@",[tok objectAtIndex:1]];
}

- (void)viewDidUnload
{
    [self setPinLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void)webRequestFail:(NSString*)reqid
{
    [DGUtils alertWaitEnd];
    [DGUtils alert:[DGUtils app].webRequester.lastError];
}

- (void)webRequestDone:(NSString*)reqid
{
    [DGUtils alertWaitEnd];
    
	//id notificationSender = [notification object];
    NSLog(@"Received notfication: %@", reqid);
    DGApp* app = [DGUtils app];
    
    NSString* credentials = [app.webRequester resultString];
    credentials = [credentials substringWithRange:NSMakeRange(1, [credentials length]-2)];
    NSLog(@"Credentials: %@", credentials);
        
    NSArray* tok = [credentials componentsSeparatedByString:@":"];
    NSString* id = [tok objectAtIndex:0];
	NSString* password = [tok objectAtIndex:1];
        
	tok = [[app loginToken] componentsSeparatedByString:@":"];
        
	password = [TLUtils xorHexString:password with:[tok objectAtIndex:0]];
	app.loginToken = nil;
        
    credentials = [NSString stringWithFormat:@"%@:%@",id,password];
    NSLog(@"Real Credentials: %@", credentials);
        
    [app register:credentials];
    [self performSegueWithIdentifier:@"startSegue" sender:self];
}



- (IBAction)login:(id)sender {
    DGApp* app = [DGUtils app];
    NSArray* tok = [app.loginToken componentsSeparatedByString:@":"];
    
    [DGUtils alertWaitStart:@"Bitte warten..."];
    
    app.webRequester.delegate = self;
    [app.webRequester get:[NSString stringWithFormat:@"%@register/%@",DOOGETHA_URL,[tok objectAtIndex:0]] reqid:@"login"];
}

@end
