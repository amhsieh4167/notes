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
BOOL noTitle;

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
        [dateFormatter setDateFormat:@"MMM d hh:mm a"];
        NSString* dateText;
        dateText = [dateFormatter stringFromDate:date];
        
        self.dateLabel.text = dateText;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
    
    if([_detailItem valueForKey:@"title"]) {
        UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNote)] autorelease];
        self.navigationItem.rightBarButtonItem = addButton;
    }
    else {
        UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(saveNote)] autorelease];
        
        [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
        [self performSelector:@selector(setTextViewAsFirstResponder) withObject:nil afterDelay:0.5f];
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
    NSArray *component;
    
    component = [_oNoteTextView.text componentsSeparatedByString:@"\n"];
    int i = 0;
    
    while (i < [component count] && [component[i] isEqualToString: @""]) {
        ++i;
    }
    
    if ([_oNoteTextView.text length] < i) {
        i = [_oNoteTextView.text length];
    }
    title = component[i];
    
    if ([title length] > 20) {
        title = [title substringToIndex:20];
    }
    
    NSLog(@"i is %i", i);
    
    if([title isEqualToString:@""]) {
        noTitle = true;
        NSLog(@"no title equals to space");
    }
    else {
        noTitle = false;
    }
    
    self.navigationItem.title = title;
    [_detailItem setValue:title forKey:@"title"];
    [self saveContext];
}

-(void)saveNote
{
    [_oNoteTextView resignFirstResponder];
    
    UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNote)] autorelease];
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

-(void)addNote
{
}
    // add a new DetailedView
    // remove self from view
    //DetailViewController *newNote = [[DetailViewController alloc] initWithNibName:@"detailedViewController" bundle:nil];
    
    //[self.view addSubview:newNote.view];
    
    //[self.navigationController performSelector:@selector(insertNewObject:)];
    //[self.navigationController popViewControllerAnimated:NO];
    
//    
//    self per
//    
//    - (void)insertNewObject:(id)sender
//    newNote =
//
//    gameViewController.view.alpha = 0.0f;
//    [self.view addSubview:gameViewController.view];
//    
//    [UIView animateWithDuration:2.0
//                     animations:^{
//                         gameViewController.view.alpha = 1.0f;
//                     }
//                     completion:^(BOOL finished) {
//                         [gameViewController startGame];
//                     }];
//}
//-(void) setRightNavButton
//{
//    if([_detailItem valueForKey:@"title"]) {
//        UIBarButtonItem *addButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNote)] autorelease];
//        self.navigationItem.rightBarButtonItem = addButton;
//    }
//    else {
//        [self performSelector:@selector(setTextViewAsFirstResponder) withObject:nil afterDelay:0.5f];
//    }
//}

#pragma mark UITextViewDelegate protocol

- (void)textViewDidChange:(UITextView *)textView
{
    [self setTitle];
    if(noTitle) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveNote)] autorelease];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    if([_detailItem valueForKey:@"title"]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        noTitle = true;
    }
    
    //set the frame size height to 165
    _oNoteTextView.frame = CGRectMake(_oNoteTextView.frame.origin.x, _oNoteTextView.frame.origin.y, _oNoteTextView.frame.size.width, TextViewEditHeight);
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    //reset oNoteTextView to full size
    _oNoteTextView.frame = CGRectMake(_oNoteTextView.frame.origin.x, _oNoteTextView.frame.origin.y, _oNoteTextView.frame.size.width, TextViewDefaultHeight);
    
    if(noTitle) {
        [_sourceContext deleteObject:_detailItem];
    }
    else {
        [_detailItem setValue:_oNoteTextView.text forKey:@"text"];
        [self saveContext];
    }
}

@end
