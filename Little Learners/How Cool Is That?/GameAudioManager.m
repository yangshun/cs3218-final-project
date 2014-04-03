//
//  GameAudioManager.m
//  YakitoriGameV2
//
//  Created by Tsai Zhen Ling on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameAudioManager.h"

static GameAudioManager *sharedGameAudioManager;

@implementation GameAudioManager
@synthesize gameVolume;

+ (GameAudioManager *)sharedInstance {
  // EFFECTS: returns singleton so that all gameobjects can have same volume
  if (!sharedGameAudioManager) {
    sharedGameAudioManager = [[GameAudioManager alloc] init];
    sharedGameAudioManager.gameVolume = 0.5;
  }
  return sharedGameAudioManager;
}

- (AVAudioPlayer *)playSoundWithPath:(NSString *)path type:(NSString *)type {
  // REQUIRES: onjects getting the return to hold a strong reference to audioplayer 
  //           else, will be released before sound plays
  // EFFECTS: returns an instance of audioplayer with the game volume
  NSString *filePath = [[NSBundle mainBundle] pathForResource:path
                                                       ofType:type];
  NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
  AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url 
                                                                      error:nil];
  audioPlayer.volume = gameVolume;
  return audioPlayer;
}

@end
