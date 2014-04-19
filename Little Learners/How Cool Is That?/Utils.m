//
//  Utils.m
//  Little Learners
//
//  Created by YangShun on 3/4/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (id)sharedManager {
    static Utils *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (NSArray *)shuffle:(NSArray *)original {
    
    NSUInteger count = [original count];
    NSMutableArray *mutable = [original mutableCopy];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = arc4random_uniform(nElements) + i;
        [mutable exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    return [NSArray arrayWithArray:mutable];
}

- (NSString *)scrambleLettersArray:(NSString *)inputString {
    
    NSUInteger length = [inputString length];
    
    if (!length) return nil;
    
    unichar *buffer = calloc(length, sizeof (unichar));
    
    [inputString getCharacters:buffer range:NSMakeRange(0, length)];
    
    for (int i = length - 1; i >= 0; i--){
        int j = arc4random() % (i + 1);
        unichar c = buffer[i];
        buffer[i] = buffer[j];
        buffer[j] = c;
    }
    
    NSString *scrambledWord = [NSString stringWithCharacters:buffer length:length];
    free(buffer);
    
    // caution, autoreleased. Allocate explicitly above or retain below to
    // keep the string.
    if (![scrambledWord isEqualToString:inputString]) {
        return scrambledWord;
    } else {
        return [self scrambleLettersArray:inputString];
    }
}

@end
