//
//  DGCommentsPreviewerView.h
//  Doogetha
//
//  Created by Kerstin Nicklaus on 07.10.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGCommentsPreviewerView : UIControl {
    UILabel *headlineLabel;
    UILabel *label;
    UILabel *sublabel;
}

- (void) updateWithComments:(NSDictionary*)comments;

@end
