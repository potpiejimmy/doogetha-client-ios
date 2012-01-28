//
//  RegisterViewController.h
//  Letsdoo
//
//  Created by Kerstin Nicklaus on 13.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGMainController.h"
#import "TLWebRequest.h"

@interface DGRegisterController : UIViewController

- (IBAction)register:(id)sender;
- (IBAction)backgroundTouched:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *mailTextField;

@end
