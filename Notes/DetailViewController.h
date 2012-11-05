//
//  DetailViewController.h
//  Notes
//
//  Created by Alex Hsieh on 11/2/12.
//  Copyright (c) 2012 Alex Hsieh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterViewController.h"

@interface DetailViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) id sourceContext;

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) IBOutlet UITextView *oNoteTextView;

@property(nonatomic, retain) MasterViewController* delegate;

-(IBAction)deleteNote:(id)sender;

- (void)setDetailItem:(id)newDetailItem setContext:context;

@end
