//
//  DetailViewController.h
//  Notes
//
//  Created by Alex Hsieh on 11/2/12.
//  Copyright (c) 2012 Alex Hsieh. All rights reserved.
//

#import <UIKit/UIKit.h>

//if delegate were to be used...
//#import "MasterViewController.h"
//
//@protocol DetailViewDelegate <NSObject>
//
//@optional
//- (void)delegateMethod;
//
//@end

@interface DetailViewController : UIViewController <UITextViewDelegate>
{
    //id<DetailViewDelegate> delegate;
}

//if delegate were to be used...
//@property (strong, nonatomic) id<DetailViewDelegate> delegate;

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) id sourceContext;

@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) IBOutlet UITextView *oNoteTextView;

-(IBAction)deleteNote:(id)sender;

-(void)setDetailItem:(id)newDetailItem setContext:context;

@end
