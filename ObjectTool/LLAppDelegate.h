//
//  LLAppDelegate.h
//  ObjectTool
//
//  Created by Damien DeVille on 2/10/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LLObjectToolWindowController;

@interface LLAppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong, nonatomic) LLObjectToolWindowController *objectToolWindowController;

@end
