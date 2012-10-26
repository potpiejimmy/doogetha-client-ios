//
//  DGRefreshTableHeaderView.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 07.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DGRefreshTableHeaderView.h"
#import <QuartzCore/QuartzCore.h>

#define kReleaseToReloadStatus	0
#define kPullToReloadStatus		1
#define kLoadingStatus			2

#define TEXT_COLOR [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]
#define BORDER_COLOR [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]

@implementation DGRefreshTableHeaderView

@synthesize isFlipped, lastUpdatedDate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame])
	{
//		self.backgroundColor = [UIColor colorWithRed:   14.0/16.0
//                                                 green: 16.0/16.0
//                                                 blue:  14.0/16.0 alpha:1.0];
        self.backgroundColor = [UIColor whiteColor];
        
		lastUpdatedLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(0.0f, frame.size.height - 30.0f,
                                       320.0f, 20.0f)];
		lastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
		lastUpdatedLabel.textColor = TEXT_COLOR;
//		lastUpdatedLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
		lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		lastUpdatedLabel.backgroundColor = self.backgroundColor;
		lastUpdatedLabel.opaque = YES;
		lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
		[self addSubview:lastUpdatedLabel];
        
		statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,
                                                                frame.size.height - 39.0f, 320.0f, 20.0f)];
		statusLabel.font = [UIFont systemFontOfSize:13.0f];
		statusLabel.textColor = TEXT_COLOR;
//		statusLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
		statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		statusLabel.backgroundColor = self.backgroundColor;
		statusLabel.opaque = YES;
		statusLabel.textAlignment = UITextAlignmentCenter;
		[self setStatus:kPullToReloadStatus];
		[self addSubview:statusLabel];
        
		arrowImage = [[UIImageView alloc] initWithFrame:
                      CGRectMake(25.0f, frame.size.height
                                 - 42.0f, 13.0f, 32.0f)];
		arrowImage.contentMode = UIViewContentModeScaleAspectFit;
		arrowImage.image = [UIImage imageNamed:@"pullrefresh_arrow.png"];
		[arrowImage layer].transform =
        CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
		[self addSubview:arrowImage];
        
		activityView = [[UIActivityIndicatorView alloc]
                        initWithActivityIndicatorStyle:
                        UIActivityIndicatorViewStyleGray];
		activityView.frame = CGRectMake(25.0f, frame.size.height
                                        - 38.0f, 20.0f, 20.0f);
		activityView.hidesWhenStopped = YES;
		[self addSubview:activityView];
        
		isFlipped = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawPath(context,  kCGPathFillStroke);
	[BORDER_COLOR setStroke];
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, 0.0f, self.bounds.size.height - 1);
	CGContextAddLineToPoint(context, self.bounds.size.width,
                            self.bounds.size.height - 1);
	CGContextStrokePath(context);
}

- (void)flipImageAnimated:(BOOL)animated
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:animated ? .18 : 0.0];
	[arrowImage layer].transform = isFlipped ?
    CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f) :
    CATransform3DMakeRotation(M_PI * 2, 0.0f, 0.0f, 1.0f);
	[UIView commitAnimations];
    
	isFlipped = !isFlipped;
}

- (void)setLastUpdatedDate:(NSDate *)newDate
{
	if (newDate)
	{
		lastUpdatedDate = newDate;
        
		NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterShortStyle];
		[formatter setTimeStyle:NSDateFormatterShortStyle];
		lastUpdatedLabel.text = [NSString stringWithFormat:
                                 @"Last Updated: %@", [formatter stringFromDate:lastUpdatedDate]];
	}
	else
	{
		lastUpdatedDate = nil;
		lastUpdatedLabel.text = @"Last Updated: Never";
	}
}

- (void)setStatus:(int)status
{
	switch (status) {
		case kReleaseToReloadStatus:
			statusLabel.text = @"Jetzt loslassen";
			break;
		case kPullToReloadStatus:
			statusLabel.text = @"Zum Aktualisieren ziehen";
			break;
		case kLoadingStatus:
			statusLabel.text = @"Liste wird aktualisiert...";
			break;
		default:
			break;
	}
}

- (void)toggleActivityView:(BOOL)isON
{
	if (!isON)
	{
		[activityView stopAnimating];
		arrowImage.hidden = NO;
	}
	else
	{
		[activityView startAnimating];
		arrowImage.hidden = YES;
		[self setStatus:kLoadingStatus];
	}
}

@end