//
//  Utils.h
//  Little Learners
//
//  Created by YangShun on 3/4/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (id)sharedManager;
- (NSArray *)shuffle:(NSArray *)original;

@end
