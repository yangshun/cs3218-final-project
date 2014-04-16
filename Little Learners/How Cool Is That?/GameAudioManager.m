//
//  GameAudioManager.m
//  YakitoriGameV2
//
//  Created by Tsai Zhen Ling on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameAudioManager.h"

static GameAudioManager *sharedGameAudioManager;

@implementation GameAudioManager {
    AVAudioPlayer *playSound;
    AVAudioPlayer *exitSound;
    AVAudioPlayer *cheerSound;
    AVAudioPlayer *booSound;
    AVAudioPlayer *categorySound;
    AVAudioPlayer *navSound;
    AVAudioPlayer *hintSound;
    AVAudioPlayer *backgroundMusic;
}

@synthesize gameVolume;

+ (GameAudioManager *)sharedInstance {
  // EFFECTS: returns singleton so that all gameobjects can have same volume
  if (!sharedGameAudioManager) {
      sharedGameAudioManager = [[GameAudioManager alloc] init];
      sharedGameAudioManager.gameVolume = 1.0f;
      [sharedGameAudioManager loadAudioClips];
  }
  return sharedGameAudioManager;
}

- (void)loadAudioClips {
    playSound = [self loadSoundWithPath:@"audio/button-play" type:@"caf"];
    exitSound = [self loadSoundWithPath:@"audio/button-exit" type:@"caf"];
    cheerSound = [self loadSoundWithPath:@"audio/cheer" type:@"caf"];
    booSound = [self loadSoundWithPath:@"audio/boo" type:@"caf"];
    categorySound = [self loadSoundWithPath:@"audio/button-category" type:@"caf"];
    navSound = [self loadSoundWithPath:@"audio/button-nav" type:@"caf"];
    hintSound = [self loadSoundWithPath:@"audio/button-hint" type:@"caf"];
    backgroundMusic = [self loadSoundWithPath:@"audio/acoustic-sunrise" type:@"caf"];
    backgroundMusic.numberOfLoops = INFINITY;
}

- (AVAudioPlayer *)loadSoundWithPath:(NSString *)path type:(NSString *)type {
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

- (void)playPlaySound {
    [playSound play];
}

- (void)playExitSound {
    [exitSound play];
}

- (void)playCategorySound {
    [categorySound play];
}

- (void)playCheerSound {
    [cheerSound play];
}

- (void)playBooSound {
    [booSound play];
}

- (void)playNavSound {
    [navSound play];
}

- (void)playHintSound {
    [hintSound play];
}

- (void)playBackgroundMusic {
    backgroundMusic.volume = 1;
//    [backgroundMusic play];
}

- (void)stopBackgroundMusic {
//    backgroundMusic.volume = 0.2;
}

@end
