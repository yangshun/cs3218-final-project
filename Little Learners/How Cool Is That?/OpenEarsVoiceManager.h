//
//  OpenEarsVoiceManager.h
//  Little Learners
//
//  Created by Xiangxin Sun on 11/4/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import <Slt/Slt.h>
#import <OpenEars/OpenEarsEventsObserver.h>


@class PocketsphinxController;
@class FliteController;

@interface OpenEarsVoiceManager : NSObject <OpenEarsEventsObserverDelegate> {
   
    Slt *slt;
	OpenEarsEventsObserver *openEarsEventsObserver;
	PocketsphinxController *pocketsphinxController;
	FliteController *fliteController;
    
    NSArray *wordList;
    
    NSString *currentWordToMatch;
    
    NSString *pathToDynamicallyGeneratedLanguageModel;
	NSString *pathToDynamicallyGeneratedDictionary;
}

@property (nonatomic, strong) NSArray *wordList;
@property (nonatomic, strong) NSString *currentWordToMatch;
@property (nonatomic, strong) Slt *slt;
@property (nonatomic, strong) OpenEarsEventsObserver *openEarsEventsObserver;
@property (nonatomic, strong) PocketsphinxController *pocketsphinxController;
@property (nonatomic, strong) FliteController *fliteController;
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedLanguageModel;
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedDictionary;

@property (nonatomic, assign) int restartAttemptsDueToPermissionRequests;
@property (nonatomic, assign) BOOL startupFailedDueToLackOfPermissions;

+ (id)sharedOpenEarsVoiceManager;

- (void) startListening;
- (void) stopListening;
- (void) pauseListening;
- (void) resumeListening;
- (void) resumeListeningToMatch:(NSString *)word;
- (void) changeWordList:(NSArray *)words;
- (void) readCurrentWord;
- (void) readWord:(NSString *)word;

@end
