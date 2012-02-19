//
//  DGNonAnimatedPushSegue.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 19.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DGNonAnimatedPushSegue.h"

@implementation DGNonAnimatedPushSegue
-(void) perform{
    [[[self sourceViewController] navigationController] pushViewController:[self destinationViewController] animated:NO];
}
@end
