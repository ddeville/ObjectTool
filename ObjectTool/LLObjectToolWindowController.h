//
//  LLObjectToolWindowController.h
//  ObjectTool
//
//  Created by Damien DeVille on 2/10/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LLObjectToolWindowController : NSWindowController

@property (copy, nonatomic) NSURL *binaryLocation;
@property (copy, nonatomic) NSString *arguments;

@property (getter = isLoading, assign, nonatomic) BOOL loading;
@property (copy, nonatomic) NSString *log;

- (IBAction)chooseBinary:(id)sender;
- (IBAction)launch:(id)sender;

@end
