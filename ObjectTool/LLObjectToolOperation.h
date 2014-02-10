//
//  LLObjectToolOperation.h
//  ObjectTool
//
//  Created by Damien DeVille on 2/10/14.
//  Copyright (c) 2014 Damien DeVille. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLObjectToolOperation : NSOperation

- (id)initWithToolLaunchPath:(NSString *)launchPath arguments:(NSArray *)arguments;

/*!
	\brief
	Upon completion this property will be populated with the result and an eventual error can be retrieved by reference.
 */
@property (readonly, copy, atomic) NSString * (^completionProvider)(NSError **errorRef);

@end
