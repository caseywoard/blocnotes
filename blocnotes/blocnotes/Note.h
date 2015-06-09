//
//  Note.h
//  blocnotes
//
//  Created by Casey Ward on 5/18/15.
//  Copyright (c) 2015 Casey Ward. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Note : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * timeStamp;

@end
