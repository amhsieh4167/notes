//
//  DetailViewController.m
//  Notes
//
//  Created by Alex Hsieh on 11/2/12.
//  Copyright (c) 2012 Alex Hsieh. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

- (void)dealloc
{
    [_detailItem release];
    [_detailDescriptionLabel release];
    [_dateLabel release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem sourceViewContext: context
{
    if (_detailItem != newDetailItem) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];
        
        _sourceContext = context;

        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        
        // load the stored note if editing was done, otherwise load an empty note
        if([[self.detailItem valueForKey:@"textDidEdit"] isEqual:[NSNumber numberWithBool:true]]) {
            self.oNoteTextView.text = [[self.detailItem valueForKey:@"text"] description];
        }
        else {
            self.oNoteTextView.text = @"";
        }
        
        NSDate* date = [self.detailItem valueForKey:@"date"];
        
        //set up the dateFormatter
        NSDateFormatter* dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        NSString* dateText;
        dateText = [dateFormatter stringFromDate:date];
        
        self.dateLabel.text = dateText;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavigationItemTitle
{
    NSString* navTitle = [[NSString alloc] initWithString:_oNoteTextView.text];

    //look for "/n", and then set the navigation title lenght to be no more than 10"
    //this is necessary because the maxTitleRange.location is assigned a random character when initiated, and would cause the subStringWithRange to go out of bound
    //length is equal to location because rangeOfString returns the location of the enter string.
    NSRange maxTitleRange;
    maxTitleRange = [navTitle rangeOfString:@"\n"];
    
    if(maxTitleRange.length == 1) {
        if(maxTitleRange.location > 15) {
            maxTitleRange.length = 15;
        }
        else {
            maxTitleRange.length = maxTitleRange.location;
        }
    }
    maxTitleRange.location = 0;
    
    navTitle = [navTitle substringWithRange:maxTitleRange];
    
    self.navigationItem.title = navTitle;
}

#pragma mark UITextViewDelegate protocol

- (void)textViewDidChange:(UITextView *)textView
{
    [self setNavigationItemTitle];
    [_detailItem setValue:_oNoteTextView.text forKey:@"text"];
    [_detailItem setValue:[NSNumber numberWithBool:true] forKey:@"textDidEdit"];
    
    // Save the context.
    NSError *error = nil;
    if (![_sourceContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

//    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
//    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
//    
//    // If appropriate, configure the new managed object.
//    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
//    [newManagedObject setValue:@"a new note" forKey:@"text"];
//    [newManagedObject setValue:[NSDate date] forKey:@"date"];
//
//    
//    mMMClass = (MMClass*)[NSEntityDescription insertNewObjectForEntityForName:@"MMClass"inManagedObjectContext:mManagedObjectContext];

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([[segue identifier] isEqualToString:@"showDetail"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//        [[segue destinationViewController] setDetailItem:object];
//    }
//}

@end
