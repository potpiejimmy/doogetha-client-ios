//
//  RegisterViewController.m
//  Letsdoo
//
//  Created by Kerstin Nicklaus on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DGRegisterController.h"
#import "DGApp.h"
#import "TLUtils.h"
#import "DGUtils.h"

@implementation DGRegisterController
@synthesize mailTextField=_mailTextField;
@synthesize resultLabel = _resultLabel;
@synthesize loginButton = _loginButton;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"init DGRegisterController");
    self = [super initWithCoder:aDecoder];
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
    NSLog(@"viewDidLoad...");
    
//    self.loginButton.enabled = NO;
}

- (void)viewDidUnload
{
    [self setMailTextField:nil];
    [self setResultLabel:nil];
    [self setLoginButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField
{
    [theTextField resignFirstResponder];
    
    return YES;
}
- (IBAction)backgroundTouched:(id)sender
{
    [self.mailTextField resignFirstResponder];
}

- (IBAction)register:(id)sender {
    
    [self.mailTextField resignFirstResponder];
    NSLog(@"Registering...");
    
    [DGUtils app].webRequester.delegate = self;
    [[DGUtils app].webRequester post:[NSString stringWithFormat:@"%@register",DOOGETHA_URL] msg:self.mailTextField.text reqid:@"register"];
}

- (void)webRequestFail:(NSString*)reqid
{
    [DGUtils alert:[DGUtils app].webRequester.lastError];
}

- (void)webRequestDone:(NSString*)reqid {
	//id notificationSender = [notification object];
    NSLog(@"Received notfication: %@", reqid);
    DGApp* app = [DGUtils app];
    
    if ([reqid isEqualToString:@"register"]) {
    
        NSString* loginToken = [app.webRequester resultString];
        loginToken = [loginToken substringWithRange:NSMakeRange(1, [loginToken length]-2)];
        NSLog(@"Login Token: %@", loginToken);
    
        app.loginToken = loginToken;

        NSArray* tok = [loginToken componentsSeparatedByString:@":"];
    
        self.resultLabel.text = [NSString stringWithFormat:@"PIN: %@",[tok objectAtIndex:1]];
        self.loginButton.enabled = YES;

    } else if ([reqid isEqualToString:@"login"]) {
    
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

}

- (IBAction)login:(id)sender {
    DGApp* app = [DGUtils app];
    NSArray* tok = [app.loginToken componentsSeparatedByString:@":"];
    
    app.webRequester.delegate = self;
    [app.webRequester get:[NSString stringWithFormat:@"%@register/%@",DOOGETHA_URL,[tok objectAtIndex:0]] reqid:@"login"];
}

//-----------

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [DGUtils slideView:self.view pixels:160 up:YES];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [DGUtils slideView:self.view pixels:160 up:NO];
}


@end
