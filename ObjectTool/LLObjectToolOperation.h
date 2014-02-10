//
//  LLObjectToolOperation.h
//  ObjectTool
//
//  Created by Damien DeVille on 2/10/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
	\brief
	A simple concurrent operation running an `NSTask` given a launch path and some arguments.
	Note that in order to keep things simple, the standard error is ignored (it will be logged to the console).
	A more robust approach would read the standard error and report it as part of the completion provider.
 */
@interface LLObjectToolOperation : NSOperation

- (id)initWithToolLaunchPath:(NSString *)launchPath arguments:(NSArray *)arguments;

/*!
	\brief
	Upon completion this property will be populated with the result and an eventual error can be retrieved by reference.
 */
@property (readonly, copy, atomic) NSString * (^completionProvider)(NSError **errorRef);

@end
