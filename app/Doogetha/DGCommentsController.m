//
//  DGCommentsController.m
//  Doogetha
//
//  Created by Kerstin Nicklaus on 07.10.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DGCommentsController.h"

#import "TLWebRequest.h"
#import "DGUtils.h"
#import <QuartzCore/QuartzCore.h>

@implementation DGCommentsController
@synthesize comments = _comments;
@synthesize commentTF = _commentTF;
@synthesize commentsTable = _commentsTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.commentTF.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.commentTF.layer setBorderWidth:2.0]; 
    [self.commentTF.layer setCornerRadius:5];
    self.commentTF.clipsToBounds = YES;
}

- (void)viewDidUnload
{
    [self setCommentTF:nil];
    [self setCommentsTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"commentCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSUInteger row = [indexPath row];
    NSDictionary* comment = [self.comments objectAtIndex:row];
    
    cell.textLabel.text = [comment objectForKey:@"comment"];
    cell.detailTextLabel.text = [DGUtils formatCommentSubline:comment];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* text = [[self.comments objectAtIndex:indexPath.row] objectForKey:@"comment"];
    CGSize s = [text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(280, 500)];
    return s.height + 32;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)reload
{
    TLWebRequest* webRequester = [[DGUtils app] webRequester];
    webRequester.delegate = self;

    int eventId = [[[DGUtils app].currentEvent objectForKey:@"id"] intValue];
    [webRequester get:[NSString stringWithFormat:@"%@comments/%d",DOOGETHA_URL,eventId] reqid:@"load"];
}

- (void)webRequestFail:(NSString*)reqid
{
    if ([reqid isEqualToString:@"save"]) {
        [DGUtils alertWaitEnd];
    }
    [DGUtils alert:[DGUtils app].webRequester.lastError];
}

- (void) webRequestDone:(NSString*)reqid
{
    if ([reqid isEqualToString:@"save"]) {
        [DGUtils alertWaitEnd];
        self.commentTF.text = @"";
        [self reload];
    } else if ([reqid isEqualToString:@"load"]) {
        NSData* result = [[DGUtils app].webRequester resultData];
        
        NSError* error;
        NSDictionary* res = [NSJSONSerialization 
                             JSONObjectWithData:result
                             options:NSJSONReadingMutableContainers 
                             error:&error];
        
        self.comments = [res objectForKey:@"eventComments"];
        NSLog(@"Got %d comments",[self.comments count]);
        
        
        [[DGUtils app].currentEvent setObject:res forKey:@"comments"];
        
        [self.commentsTable reloadData];
    }
}

- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)submit:(id)sender
{
    TLWebRequest* webRequester = [[DGUtils app] webRequester];
    webRequester.delegate = self;
    
    NSDictionary* newComment = [NSDictionary dictionaryWithObject:self.commentTF.text forKey:@"comment"];
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:newComment options:0 error:&error];
    NSString* result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSLog(@"Trying to post comment: %@", result);
    [DGUtils alertWaitStart:@"Speichern. Bitte warten..."];
    
    int eventId = [[[DGUtils app].currentEvent objectForKey:@"id"] intValue];

    // insert:
    [webRequester post:[NSString stringWithFormat:@"%@comments/%d",DOOGETHA_URL,eventId] msg:result reqid:@"save"];
}
@end
