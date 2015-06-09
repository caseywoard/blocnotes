//
//  CreateNoteViewController.m
//  blocnotes
//
//  Created by Casey Ward on 5/18/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import "CreateNoteViewController.h"
#import "AppDelegate.h"
#import "Note.h"

@interface CreateNoteViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)savedTyped:(id)sender;

@end

@implementation CreateNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.note != nil){
        self.textView.text = self.note.title;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)savedTyped:(id)sender {
    if (self.note != nil) {
        [self updateNote];
    } else {
        [self createNote];
    }
}
    //create a note object that calls (look at tutorial)

-(void) createNote {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    Note *newNote = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Note"
                      inManagedObjectContext:context];
    newNote.text = _textView.text;
    newNote.title = _titleTextField.text;
    newNote.timeStamp = [NSDate date];
    
    NSError *error;
    [context save:&error];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void) updateNote {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    self.note.text = _textView.text;
    self.note.title = _titleTextField.text;
    self.note.timeStamp = [NSDate date];
    
    NSError *error;
    [context save:&error];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
