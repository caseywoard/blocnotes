//
//  CreateNoteViewController.m
//  blocnotes
//
//  Created by Casey Ward on 5/18/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import "NoteViewController.h"
#import "CoreDataStack.h"
#import "Note.h"

@interface NoteViewController () <UITextViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property(nonatomic, copy) NSArray *rightBarButtonItems;

@property (nonatomic, strong) UITapGestureRecognizer *longPressGesture;

- (IBAction)saveNote:(id)sender;
- (void) shareNote:(id)sender;


@end

@implementation NoteViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.note != nil){
        self.textView.text = self.note.text;
        self.titleTextField.text = self.note.title;
        self.textView.editable = NO;
        self.textView.dataDetectorTypes = UIDataDetectorTypeAll;
    }
    
    //datadetectors property
    //isEditable flag on UI text field, figure out how to trigger this,  based on tap gesture 
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                target:self
                                                                                action:@selector(saveNote:)];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                 target:self
                                                                                 action:@selector(shareNote:)];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:saveButton, shareButton, nil];
    
    //datadetector setup
    
    self.textView.delegate = self;
    //self.textView.dataDetectorTypes = UIDataDetectorTypeAll;
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear fired.");
    
    
    self.longPressGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToEdit:)];
    //[self.tapGesture setNumberOfTapsRequired:1];
    self.longPressGesture.cancelsTouchesInView = NO;
    if (self.textView){
        [self.textView addGestureRecognizer:self.longPressGesture];
    }
}


-(void) tapToEdit:(UITapGestureRecognizer *) recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        if (!self.textView.isEditable) {
            self.textView.editable = YES;
            self.textView.dataDetectorTypes = UIDataDetectorTypeNone;
            NSLog(@"I'm in editing mode");
        
        } else {
            self.textView.editable = NO;
            self.textView.dataDetectorTypes = UIDataDetectorTypeAll;
            NSLog(@"I'm NOT in editing mode");
        }
    }
}


//-(void) textViewDidBeginEditing:(UITextView *)textView {
//    self.textView.dataDetectorTypes = UIDataDetectorTypeNone;
//    NSLog(@"I'm in editing mode");
//}
//
//-(void) textViewDidEndEditing:(UITextView *)textView {
//    self.textView.dataDetectorTypes = UIDataDetectorTypeAll;
//    NSLog(@"I'm NOT in editing mode");
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)shareNote:(id)sender {
    
    NSMutableArray *itemsToShare = [NSMutableArray array];
        
    if (self.note) {
        [itemsToShare addObject:self.titleTextField.text];
        [itemsToShare addObject:self.textView.text];
    }
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];

}

-(IBAction)saveNote:(id)sender {
    if (self.note != nil) {
        [self updateNote];
    } else {
        [self createNote];
    }
}
    //create a note object that calls (look at tutorial)

-(void) createNote {
    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];
        
    NSManagedObjectContext *context = [coreDataStack managedObjectContext];
    
    Note *newNote = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Note"
                      inManagedObjectContext:context];
    newNote.text = _textView.text;
    newNote.title = _titleTextField.text;
    newNote.timeStamp = [NSDate date];
    
    NSError *error;
    [context save:&error];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void) updateNote {
    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];
    
    NSManagedObjectContext *context = [coreDataStack managedObjectContext];
    
    self.note.text = _textView.text;
    self.note.title = _titleTextField.text;
    self.note.timeStamp = [NSDate date];
    
    NSError *error;
    [context save:&error];
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)cancelWasPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
