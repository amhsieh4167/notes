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
        
        self.navigationItem.title = [[self.detailItem valueForKey:@"title"] description];
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
        [self performSelector:@selector(setTextViewAsFirstResponder) withObject:nil afterDelay:0.5f];
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
}

- (void)setTitle
{    
    NSString *title = [[[NSString alloc] init] autorelease];
    
    NSRange enterKeyLocation;
    enterKeyLocation = [_oNoteTextView.text rangeOfString:@"\n"];

    if(enterKeyLocation.length == 1 && enterKeyLocation.location != 0) {
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
    self.navigationItem.title = title;
    [_detailItem setValue:title forKey:@"title"];
    [self saveContext];
}

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
    if([_oNoteTextView.text length] == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [self setTitle];
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

@end
