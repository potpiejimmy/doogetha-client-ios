//
//  DGPullRefreshTableViewController.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGRefreshTableHeaderView.h"

@interface DGPullRefreshTableViewController : UITableViewController
{
	DGRefreshTableHeaderView *refreshHeaderView;
    
	BOOL checkForRefresh;
	BOOL reloading;
}

- (void) dataSourceDidFinishLoadingNewData;
- (void) showReloadAnimationAnimated:(BOOL)animated;

@end