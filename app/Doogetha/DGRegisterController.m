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

@implementation DGRegisterController
@synthesize mailTextField=_mailTextField;
@synthesize webRequester=_webRequester;
@synthesize resultLabel = _resultLabel;
@synthesize loginButton = _loginButton;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSLog(@"init DGRegisterController");
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.webRequester = [[TLWebRequest alloc] initWithObserver:self];
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

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    [theTextField resignFirstResponder];
    
    return YES;
}

- (IBAction)register:(id)sender {
    
    [self.mailTextField resignFirstResponder];
    NSLog(@"Registering...assdf");
    
    if (!self.webRequester)
        self.webRequester = [[TLWebRequest alloc] initWithObserver:self];
    
    [self.webRequester post:[NSString stringWithFormat:@"%@register",DOOGETHA_URL] msg:self.mailTextField.text name:@"register"];
}

- (void)webRequestDone:(NSNotification*)notification {
	//id notificationSender = [notification object];
    NSLog(@"Received notfication: %@", [notification name]);
    DGApp* app = [[UIApplication sharedApplication] delegate];
    
    if ([[notification name] isEqualToString:@"register"]) {
    
        NSString* loginToken = [self.webRequester resultString];
        loginToken = [loginToken substringWithRange:NSMakeRange(1, [loginToken length]-2)];
        NSLog(@"Login Token: %@", loginToken);
    
        app.loginToken = loginToken;

        NSArray* tok = [loginToken componentsSeparatedByString:@":"];
    
        self.resultLabel.text = [NSString stringWithFormat:@"Login token is %@",[tok objectAtIndex:1]];
        self.loginButton.enabled = YES;

    } else if ([[notification name] isEqualToString:@"login"]) {
    
        NSString* credentials = [self.webRequester resultString];
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
        [app startSession];
        [self performSegueWithIdentifier:@"startSegue" sender:self];
        [app.mainController reload];
    }

}

- (IBAction)login:(id)sender {
    DGApp* app = [[UIApplication sharedApplication] delegate];
    NSArray* tok = [app.loginToken componentsSeparatedByString:@":"];
    
    if (!self.webRequester)
        self.webRequester = [[TLWebRequest alloc] initWithObserver:self];
    
    [self.webRequester get:[NSString stringWithFormat:@"%@register/%@",DOOGETHA_URL,[tok objectAtIndex:0]] name:@"login"];
}
@end
