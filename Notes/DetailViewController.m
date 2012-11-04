//
//  DetailViewController.m
//  Notes
//
//  Created by Alex Hsieh on 11/2/12.
//  Copyright (c) 2012 Alex Hsieh. All rights reserved.
//

#import "DetailViewController.h"
#import "Constants.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

CGRect textViewEditFrame;

- (void)dealloc
{
    [_detailItem release];
    [_dateLabel release];
    [super dealloc];
}

#pragma mark - Managing the detail item and SourceViewContext

- (void)setDetailItem:(id)newDetailItem setSourceViewContext:context
{
    if (_detailItem != newDetailItem && _sourceContext != context) {
        [_detailItem release];
        _detailItem = [newDetailItem retain];
        
        [_sourceContext release];
        _sourceContext = [context retain];
        
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
    [self configureView];
        
    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(setTextViewAsFirstResponder) userInfo:nil repeats:NO];
}

-(void)setTextViewAsFirstResponder
{
    [_oNoteTextView becomeFirstResponder];
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

-(void)saveNote
{
    [_oNoteTextView resignFirstResponder];
    
    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNote)] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
}

//-(void) addNote
//{
//    // set MasterView alpha to 0
//    // remove self from view
//    // then call insertItem
//    
//    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
//    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context
//}

#pragma mark UITextViewDelegate protocol

- (void)textViewDidChange:(UITextView *)textView
{
    [self setNavigationItemTitle];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveNote)] autorelease];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    //set the frame size height to 165
    _oNoteTextView.frame = CGRectMake(_oNoteTextView.frame.origin.x, _oNoteTextView.frame.origin.y, _oNoteTextView.frame.size.width, TextViewEditHeight);
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
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
    
    _oNoteTextView.frame = CGRectMake(_oNoteTextView.frame.origin.x, _oNoteTextView.frame.origin.y, _oNoteTextView.frame.size.width, TextViewDefaultHeight);
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
