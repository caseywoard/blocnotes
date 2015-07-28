//
//  CreateNoteViewController.h
//  blocnotes
//
//  Created by Casey Ward on 5/18/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Note;

@interface NoteViewController : UIViewController

@property (nonatomic, strong) Note *note;
- (void) shareNote:(id)sender;
- (void) createNote;

@end
