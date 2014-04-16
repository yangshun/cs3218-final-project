//
//  GameAudioManager.h
//  YakitoriGameV2
//
//  Created by Tsai Zhen Ling on 4/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface GameAudioManager : NSObject <AVAudioPlayerDelegate>

@property (nonatomic, readwrite) float gameVolume;

+ (GameAudioManager *)sharedInstance;
- (AVAudioPlayer *)loadSoundWithPath:(NSString *)path type:(NSString *)type;

- (void)playPlaySound;
- (void)playExitSound;
- (void)playCategorySound;
- (void)playCheerSound;
- (void)playBooSound;
- (void)playNavSound;
- (void)playHintSound;

@end
