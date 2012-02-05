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
    
    NSString* mail = [TLUtils trim:self.mailTextField.text];
    if ([mail rangeOfString:@"@"].location == NSNotFound || [mail length]<5)
    {
        [DGUtils alert:@"Bitte gib eine gültige E-Mail-Adresse ein."];
        return;
    }
    
    NSLog(@"Registering...");
    
    [DGUtils alertWaitStart:@"Anfrage wird gesendet. Bitte warten..."];
    
    [[DGUtils app] setUserDefaultValue:mail forKey:@"email"];
    [DGUtils app].webRequester.delegate = self;
    [[DGUtils app].webRequester post:[NSString stringWithFormat:@"%@register",DOOGETHA_URL] msg:mail reqid:@"register"];
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
    
    NSString* loginToken = [app.webRequester resultString];
    loginToken = [loginToken substringWithRange:NSMakeRange(1, [loginToken length]-2)];
    NSLog(@"Login Token: %@", loginToken);
    
    app.loginToken = loginToken;
  
    [self performSegueWithIdentifier:@"registerSegue" sender:self];
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
