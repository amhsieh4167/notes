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

- (void)setDetailItem:(id)newDetailItem setContext:context
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
                
        self.oNoteTextView.text = [[self.detailItem valueForKey:@"text"] description];
        
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
    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
    
    if(! [_detailItem valueForKey:@"text"])
    {
        //performSelector:<#(SEL)#> withObject:<#(id)#> afterDelay:<#(NSTimeInterval)#>
        [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(setTextViewAsFirstResponder) userInfo:nil repeats:NO];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
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

- (void)setTitle
{
    NSString *title = [[[NSString alloc] init] autorelease];
    
    NSRange enterKeyLocation;
    enterKeyLocation = [_oNoteTextView.text rangeOfString:@"\n"];

    if(enterKeyLocation.location == 1) {
        // an enter key has been found
        CGFloat titleLength;
        
        if(enterKeyLocation.location > 15) {
            titleLength = 15;
        }
        else {
            titleLength = enterKeyLocation.location;
        }
        
        NSRange enterKeyRange;
        enterKeyRange.location = 0;
        enterKeyRange.length = titleLength;
        title = [_oNoteTextView.text substringWithRange:enterKeyRange];
    }
    else {
        title = _oNoteTextView.text;
    }
    
    self.navigationItem.title = _oNoteTextView.text;
//    
//    
//    
//    if(![[_detailItem valueForKey:@"title"] description])
//    {
//        self.navigationItem.title = _oNoteTextView.text;
//    }
}
//
//        NSString* noteTitle = [[NSString alloc] initWithString:_oNoteTextView.text];
//        
//        //look for "/n", and then set the navigation title lenght to be no more than 10"
//        //this is necessary because the maxTitleRange.location is assigned a random character when initiated, and would cause the subStringWithRange to go out of bound
//        //length is equal to location because rangeOfString returns the location of the enter string.
//        NSRange maxTitleRange;
//        maxTitleRange = [noteTitle rangeOfString:@"\n"];
//        
//        if(maxTitleRange.length == 1) {
//            if(maxTitleRange.location > 15) {
//                maxTitleRange.length = 15;
//            }
//            else {
//                maxTitleRange.length = maxTitleRange.location;
//            }
//        }
//        maxTitleRange.location = 0;
//        
//        noteTitle = [noteTitle substringWithRange:maxTitleRange];
//        
//        self.navigationItem.title = noteTitle;
//        [_detailItem setValue:noteTitle forKey:@"title"];
//        [self saveContext];
//    }

-(void)saveNote
{
    [_oNoteTextView resignFirstResponder];
    
    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:nil] autorelease];
    self.navigationItem.rightBarButtonItem = addButton;
}

-(IBAction)deleteNote:(id)sender;
{
    [_sourceContext deleteObject:_detailItem];
    [self saveContext];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)saveContext
{
    NSError *error = nil;
    if(![_sourceContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
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
    [self setTitle];
    if([_oNoteTextView.text length] == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
//    UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveNote)] autorelease];
//    self.navigationItem.rightBarButtonItem = doneButton;
    
    //set the frame size height to 165
    _oNoteTextView.frame = CGRectMake(_oNoteTextView.frame.origin.x, _oNoteTextView.frame.origin.y, _oNoteTextView.frame.size.width, TextViewEditHeight);
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    //reset oNoteTextView to full size
    _oNoteTextView.frame = CGRectMake(_oNoteTextView.frame.origin.x, _oNoteTextView.frame.origin.y, _oNoteTextView.frame.size.width, TextViewDefaultHeight);
    
    if([_oNoteTextView.text length] == 0) {
        [_sourceContext deleteObject:_detailItem];
    }
    else {
        [_detailItem setValue:_oNoteTextView.text forKey:@"text"];
    }
    [self saveContext];
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
