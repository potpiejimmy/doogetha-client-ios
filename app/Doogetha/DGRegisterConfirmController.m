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
#import "TLKeychain.h"

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

- (void)displayLoginFailed
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil 
                                                    message:@"Das Login war nicht erfolgreich. Bitte überprüfe, ob du die E-Mail-Bestätigung korrekt ausgeführt hast."
                                                   delegate:self 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:@"Neustart",nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) /* clicked retry registration */
    {
        [DGUtils app].loginToken = nil;
        [self performSegueWithIdentifier:@"cancelSegue" sender:self];
    }
}

- (void)sessionCreateOk
{
	[DGUtils alertWaitEnd];
		
    // startup
    [app setRegistered];
	
    // start real session:
    [app startSession:app];
	
    [self performSegueWithIdentifier:@"startSegue" sender:self];
}

- (void)sessionCreateFail
{
    [DGUtils alertWaitEnd];
    [self displayLoginFailed];
}

- (IBAction)login:(id)sender {
    // Perform a session login to see whether registration was successful
    [DGUtils alertWaitStart:@"Registrierung wird überprüft. Bitte warten..."];

    [[DGUtils app] startSession:self];
}

@end
