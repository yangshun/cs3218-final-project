//
//  GameViewController.h
//  Little Learners
//
//  Created by Xiangxin Sun on 19/4/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import "ViewController.h"
#import "OpenEarsVoiceManager.h"

@interface GameViewController : ViewController <OpenEarsEventsObserverDelegate>

@property NSArray *wordArray;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *leftStarCollection;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *rightStartCollection;

@end
