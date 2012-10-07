//
//  DGCommentsPreviewerView.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 07.10.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DGCommentsPreviewerView.h"

#import "DGUtils.h"

#define TEXT_COLOR [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]
#define TEXT_COLOR_GRAY [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0]

@implementation DGCommentsPreviewerView

-(void)setupView {
	headlineLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(10.0f, self.frame.size.height - 75.0f,
                                       300.0f, 20.0f)];
	headlineLabel.font = [UIFont systemFontOfSize:14.0f];
	headlineLabel.textColor = TEXT_COLOR;
    headlineLabel.textAlignment = UITextAlignmentCenter;
    headlineLabel.text = @"↑ Hello world ↑";
    headlineLabel.opaque = NO;
    headlineLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:headlineLabel];

	label = [[UILabel alloc] initWithFrame:
    CGRectMake(10.0f, self.frame.size.height - 53.0f,
               300.0f, 30.0f)];
	label.font = [UIFont systemFontOfSize:12.0f];
	label.textColor = TEXT_COLOR;
    label.textAlignment = UITextAlignmentLeft;
    label.numberOfLines = 2;
    label.text = @"Dies ist ein wunderschöner Kommentar der über mehrere Zeilen reicht, wenn er es muss. Muss er aber nicht.";
    label.opaque = NO;
    label.backgroundColor = [UIColor clearColor];
	[self addSubview:label];

	sublabel = [[UILabel alloc] initWithFrame:
             CGRectMake(10.0f, self.frame.size.height - 19.0f,
                        300.0f, 15.0f)];
	sublabel.font = [UIFont systemFontOfSize:12.0f];
	sublabel.textColor = TEXT_COLOR_GRAY;
    sublabel.textAlignment = UITextAlignmentLeft;
    sublabel.numberOfLines = 1;
    sublabel.text = @"Thorsten Liese (14.08.2012 16:32)";
    sublabel.opaque = NO;
    sublabel.backgroundColor = [UIColor clearColor];
	[self addSubview:sublabel];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self == [super initWithCoder:aDecoder]){
        [self setupView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void) updateWithComments:(NSDictionary*)comments
{
    int count = [[comments objectForKey:@"count"] intValue];
    if (count == 1)
        headlineLabel.text = NSLocalizedString(@"comment_one", nil);
    else
        headlineLabel.text = [NSString stringWithFormat:NSLocalizedString(@"comments_n", nil), count];

    NSArray* commentsList = [comments objectForKey:@"eventComments"];
    if (commentsList && [commentsList count]>0) {
        NSDictionary* displayComment = [commentsList objectAtIndex:0];
        label.text = [displayComment objectForKey:@"comment"];
        sublabel.text = [DGUtils formatCommentSubline:displayComment];
    } else {
        label.text = @"Jetzt kommentieren...";
        sublabel.text = @"";
    }
}

- (void)drawRect:(CGRect)rect{
}

@end
