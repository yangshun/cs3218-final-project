//
//  OpenEarsVoiceManager.m
//  Little Learners
//
//  Created by Xiangxin Sun on 11/4/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import "OpenEarsVoiceManager.h"

#import <OpenEars/PocketsphinxController.h> 
#import <OpenEars/FliteController.h>
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/OpenEarsLogging.h>
#import <OpenEars/AcousticModel.h>

@implementation OpenEarsVoiceManager

@synthesize slt;
@synthesize openEarsEventsObserver;
@synthesize pocketsphinxController;
@synthesize fliteController;
@synthesize wordList = _wordList;
@synthesize currentWordToMatch;
@synthesize pathToDynamicallyGeneratedLanguageModel;
@synthesize pathToDynamicallyGeneratedDictionary;

#pragma mark -
#pragma mark Initialization


+ (id)sharedOpenEarsVoiceManager {
    static OpenEarsVoiceManager *sharedOpenEarsVoiceManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"openEarsVoiceManager created for the first time");
        sharedOpenEarsVoiceManager = [[self alloc] init];
    });
    return sharedOpenEarsVoiceManager;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)initLanguageModel {
    LanguageModelGenerator *languageModelGenerator = [[LanguageModelGenerator alloc] init];
    NSError *result = [languageModelGenerator generateLanguageModelFromArray:self.wordList withFilesNamed:@"LittleLearnersLanguageModel" forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    NSDictionary *dynamicLanguageGenerationResultsDictionary = nil;
    if([result code] != noErr) {
        NSLog(@"Dynamic language generator reported error %@", [result description]);
    } else {
        dynamicLanguageGenerationResultsDictionary = [result userInfo];
        
        NSString *lmPath = [dynamicLanguageGenerationResultsDictionary objectForKey:@"LMPath"];
        NSString *dictionaryPath = [dynamicLanguageGenerationResultsDictionary objectForKey:@"DictionaryPath"];
        NSLog(@"Dynamic language generator completed successfully at paths \n%@ \nand \n%@", lmPath,dictionaryPath);
        
        self.pathToDynamicallyGeneratedLanguageModel = lmPath;
        self.pathToDynamicallyGeneratedDictionary = dictionaryPath;
    }

}

#pragma mark -
#pragma mark Lazy Allocation

- (PocketsphinxController *)pocketsphinxController {
	if (pocketsphinxController == nil) {
		pocketsphinxController = [[PocketsphinxController alloc] init];
        pocketsphinxController.outputAudio = TRUE;
        pocketsphinxController.calibrationTime = 3;
        pocketsphinxController.secondsOfSilenceToDetect = 0.0001;
	}
	return pocketsphinxController;
}

- (Slt *)slt {
	if (slt == nil) {
		slt = [[Slt alloc] init];
	}
	return slt;
}

- (FliteController *)fliteController {
	if (fliteController == nil) {
		fliteController = [[FliteController alloc] init];
        fliteController.duration_stretch = 1.0;
        fliteController.target_mean = 1.0;
        fliteController.target_stddev = 1.0;
        
	}
	return fliteController;
}

- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (openEarsEventsObserver == nil) {
		openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
    NSLog(@"openEarsEventsObserver %@", openEarsEventsObserver);
	return openEarsEventsObserver;
}

#pragma mark -
#pragma mark Public Methods

- (void) setWordList:(NSArray *)words {
    BOOL exist = (_wordList == nil);
    
    // NSLog(@"Old word list %@", _wordList);
    
    _wordList = words;
    [self initLanguageModel];
    
    if (exist) {
        [self.pocketsphinxController changeLanguageModelToFile:self.pathToDynamicallyGeneratedLanguageModel withDictionary:self.pathToDynamicallyGeneratedDictionary];
    }
}

- (void) startListening {
    
    [self.pocketsphinxController startListeningWithLanguageModelAtPath:self.pathToDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToDynamicallyGeneratedDictionary acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE];
}

- (void) stopListening {
    [self.pocketsphinxController stopListening];
}

- (void) pauseListening {
    [self.pocketsphinxController suspendRecognition];
}

- (void) resumeListening {
    [self.pocketsphinxController resumeRecognition];
}

- (void) resumeListeningToMatch:(NSString *)word {
    [self.pocketsphinxController resumeRecognition];
    if ([self.wordList containsObject:word]) {
        self.currentWordToMatch = word;
    } else {
        NSLog(@"No word %@ in current word list", word);
    }
}

- (void) readCurrentWord {
    AVSpeechUtterance *utterance = [AVSpeechUtterance
                                    speechUtteranceWithString:self.currentWordToMatch];
    AVSpeechSynthesizer *synth = [[AVSpeechSynthesizer alloc] init];
    
    [utterance setRate:AVSpeechUtteranceMinimumSpeechRate];
    [synth speakUtterance:utterance];
//    [self.fliteController say:self.currentWordToMatch withVoice:self.slt];
}

- (void) readWord:(NSString *)word {
    [self.fliteController say:word withVoice:self.slt];
}


@end
