//
//  DGRefreshTableHeaderView.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGRefreshTableHeaderView : UIView {
    
	UILabel *lastUpdatedLabel;
	UILabel *statusLabel;
	UIImageView *arrowImage;
	UIActivityIndicatorView *activityView;
    
	BOOL isFlipped;
    
	NSDate *lastUpdatedDate;
}
@property BOOL isFlipped;

@property (nonatomic, retain) NSDate *lastUpdatedDate;

- (void)flipImageAnimated:(BOOL)animated;
- (void)toggleActivityView:(BOOL)isON;
- (void)setStatus:(int)status;

@end