//
//  LLObjectToolWindowController.m
//  ObjectTool
//
//  Created by Damien DeVille on 2/10/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import "LLObjectToolWindowController.h"

#import "LLObjectToolOperation.h"

@interface LLObjectToolWindowController ()

@property (strong, nonatomic) NSOperationQueue *operationQueue;

@end

@implementation LLObjectToolWindowController

- (id)init
{
	return [self initWithWindowNibName:@"LLObjectToolWindow" owner:self];
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	
	NSOperationQueue *operationQueue = [[NSOperationQueue alloc] init];
	[self setOperationQueue:operationQueue];
}

- (NSFont *)longFont
{
	return [NSFont fontWithName:@"Menlo" size:11.0];
}

#pragma mark - Actions

- (IBAction)chooseBinary:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setTreatsFilePackagesAsDirectories:YES];
	[openPanel setAllowedFileTypes:@[@"public.executable"]];
	
	[openPanel beginSheetModalForWindow:[self window] completionHandler:^ (NSInteger result) {
		if (result == NSFileHandlingPanelOKButton) {
			[self setBinaryLocation:[openPanel URL]];
		}
	}];
}

- (IBAction)launch:(id)sender
{
	NSString *launchPath = @"/usr/bin/otool";
	
	NSMutableArray *arguments = [NSMutableArray array];
	[arguments addObjectsFromArray:[[self arguments] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
	[arguments addObject:[[self binaryLocation] path]];
	
	[self setLoading:YES];
	[self setLog:nil];
	
	LLObjectToolOperation *workOperation = [[LLObjectToolOperation alloc] initWithToolLaunchPath:launchPath arguments:arguments];
	[[self operationQueue] addOperation:workOperation];
	
	NSOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^ {
		[self setLoading:NO];
		
		NSError *error = nil;
		NSString *result = [workOperation completionProvider](&error);
		
		if (result == nil) {
			[self setLog:[error localizedDescription]];
			return;
		}
		
		[self setLog:result];
	}];
	[completionOperation addDependency:workOperation];
	[[NSOperationQueue mainQueue] addOperation:completionOperation];
}

@end
