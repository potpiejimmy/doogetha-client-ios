//
//  DGViewController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 15.12.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGPullRefreshTableViewController.h"
#import "TLWebRequest.h"

@interface DGMainController : DGPullRefreshTableViewController<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate> {
}

-(void)reload;

@property (weak, nonatomic) IBOutlet UITableView *eventsTable;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonNewActivity;

@property (strong, nonatomic) NSArray *events;
@property BOOL checkVersionAfterReload;
@property BOOL refreshNeeded;

- (IBAction)newButtonClicked:(id)sender;

- (void) setUIEnabled: (BOOL) enabled;
- (void) reload:(id)sender;
- (void) checkVersion;

+(BOOL) hasOpenSurveys:(id) event;
+(void) setConfirmImage: (UIImageView*)imageView forState:(int)state;

@end
