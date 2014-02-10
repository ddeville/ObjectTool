//
//  LLAppDelegate.m
//  ObjectTool
//
//  Created by Damien DeVille on 2/10/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import "LLAppDelegate.h"

#import "LLObjectToolWindowController.h"

@interface LLAppDelegate ()

@property (readwrite, strong, nonatomic) LLObjectToolWindowController *objectToolWindowController;

@end

@implementation LLAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	LLObjectToolWindowController *objectToolWindowController = [[LLObjectToolWindowController alloc] init];
	[self setObjectToolWindowController:objectToolWindowController];
	
	[objectToolWindowController showWindow:self];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
	[[self objectToolWindowController] showWindow:sender];
	
	return YES;
}

@end
