//
//  LevelViewController.h
//  Little Learners
//
//  Created by YangShun on 8/4/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import "ViewController.h"
#import "GameAudioManager.h"
#import "Constants.h"

@interface LevelViewController : ViewController

@property NSArray *wordsArray;
@property int currentWordIndex;
@property AVAudioPlayer *cheerPlayer;
@property AVAudioPlayer *booPlayer;
@property NSMutableArray *imagesArray;
@property NSString *currentWord;

- (void)nextWord;
- (void)previousWord;

@end
