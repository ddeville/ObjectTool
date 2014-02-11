//
//  LLObjectToolOperation.m
//  ObjectTool
//
//  Created by Damien DeVille on 2/10/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import "LLObjectToolOperation.h"

#import "LLObjectTool-Constants.h"

@interface LLObjectToolOperation (/* Parameters */)

@property (copy, nonatomic) NSString *launchPath;
@property (copy, nonatomic) NSArray *arguments;

@end

@interface LLObjectToolOperation (/* Operation */)

@property (assign, atomic) BOOL isExecuting, isFinished;

@property (readwrite, copy, atomic) NSString * (^completionProvider)(NSError **errorRef);

@end

@interface LLObjectToolOperation (/* Private */)

@property (strong, nonatomic) NSOperationQueue *controlQueue;
@property (strong, nonatomic) dispatch_queue_t workQueue;

@property (strong, nonatomic) NSTask *task;
@property (strong, nonatomic) dispatch_io_t standardOutputConnection;

@property (strong, nonatomic) NSMutableData *standardOutputResponse;

@end

@implementation LLObjectToolOperation

- (id)initWithToolLaunchPath:(NSString *)launchPath arguments:(NSArray *)arguments
{
	self = [self init];
	if (self == nil) {
		return nil;
	}
	
	NSParameterAssert(launchPath != nil);
	_launchPath = [launchPath copy];
	
	NSParameterAssert(arguments != nil);
	_arguments = [arguments copy];
	
	_controlQueue = [[NSOperationQueue alloc] init];
	[_controlQueue setMaxConcurrentOperationCount:1];
	
	_workQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	
	_completionProvider = [^ NSString * (NSError **errorRef) {
		if (errorRef != NULL) {
			*errorRef = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
		}
		return nil;
	} copy];
	
	return self;
}

#pragma mark - NSOperation

- (BOOL)isConcurrent
{
	return YES;
}

static NSString * const _LLObjectToolOperationIsExecutingKey = @"isExecuting";
static NSString * const _LLObjectToolOperationIsFinishedKey = @"isFinished";

- (void)start
{
	[[self controlQueue] addOperationWithBlock:^ {
		if ([self isCancelled]) {
			[self _finish];
			return;
		}
		
		[self willChangeValueForKey:_LLObjectToolOperationIsExecutingKey];
		[self setIsExecuting:YES];
		[self didChangeValueForKey:_LLObjectToolOperationIsExecutingKey];
		
		[self _startTask];
	}];
}

- (void)cancel
{
	[[self controlQueue] addOperationWithBlock:^ {
		[[self task] terminate];
	}];
	
	[super cancel];
}

- (void)_finish
{
	[self willChangeValueForKey:_LLObjectToolOperationIsExecutingKey];
	[self setIsExecuting:NO];
	[self didChangeValueForKey:_LLObjectToolOperationIsExecutingKey];
	
	[self willChangeValueForKey:_LLObjectToolOperationIsFinishedKey];
	[self setIsFinished:YES];
	[self didChangeValueForKey:_LLObjectToolOperationIsFinishedKey];
}

#pragma mark - Task

- (void)_startTask
{
	[self __setupTask];
	[self __setupConnection];
	
	[self __startTask];
}

- (void)__setupTask
{
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:[self launchPath]];
	[task setArguments:[self arguments]];
	
	[task setStandardOutput:[NSPipe pipe]];
	
	[self setTask:task];
}

- (void)__setupConnection
{
	int standardOutputFileDescriptor = [[[[self task] standardOutput] fileHandleForReading] fileDescriptor];
	
	dispatch_io_t standardOutputConnection = dispatch_io_create(DISPATCH_IO_STREAM, standardOutputFileDescriptor, [self workQueue], ^ (int error) {
		if (error != 0) {
			[self _didReceiveTaskError:[NSError errorWithDomain:NSPOSIXErrorDomain code:error userInfo:nil]];
			return;
		}
	});
	[self setStandardOutputConnection:standardOutputConnection];
	
	dispatch_io_read(standardOutputConnection, 0, SIZE_MAX, [self workQueue], ^ (bool done, dispatch_data_t receivedData, int error) {
		if (receivedData != nil && dispatch_data_get_size(receivedData) != 0) {
			if ([self standardOutputResponse] == nil) {
				[self setStandardOutputResponse:[NSMutableData data]];
			}
			
			void const *bytes = NULL; size_t bytesLength = 0;
			dispatch_data_t contiguousData __attribute__((unused, objc_precise_lifetime)) = dispatch_data_create_map(receivedData, &bytes, &bytesLength);
			
			[[self standardOutputResponse] appendBytes:bytes length:bytesLength];
		}
		
		if (error != 0) {
			dispatch_io_close(standardOutputConnection, DISPATCH_IO_STOP);
			
			[self _didReceiveTaskError:[NSError errorWithDomain:NSPOSIXErrorDomain code:error userInfo:nil]];
			return;
		}
		
		if (done) {
			dispatch_io_close(standardOutputConnection, DISPATCH_IO_STOP);
			
			[self _didReceiveTaskResponse:[self standardOutputResponse]];
		}
	});
}

- (void)__startTask
{
	[[self task] launch];
}

#pragma mark - Completion

- (void)_didReceiveTaskError:(NSError *)error
{
	[self setCompletionProvider:^ NSString * (NSError **errorRef) {
		if (errorRef != NULL) {
			*errorRef = error;
		}
		return nil;
	}];
	
	[self _finish];
}

- (void)_didReceiveTaskResponse:(NSData *)response
{
	NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
	
	[self setCompletionProvider:^ NSString * (NSError **errorRef) {
		return responseString;
	}];
	
	[self _finish];
}

@end
