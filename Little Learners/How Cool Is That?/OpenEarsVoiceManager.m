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
@synthesize wordList;
@synthesize currentWordToMatch;
@synthesize pathToDynamicallyGeneratedLanguageModel;
@synthesize pathToDynamicallyGeneratedDictionary;
@synthesize restartAttemptsDueToPermissionRequests;
@synthesize startupFailedDueToLackOfPermissions;

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
        [self.openEarsEventsObserver setDelegate:self];
        
        self.restartAttemptsDueToPermissionRequests = 0;
        self.startupFailedDueToLackOfPermissions = FALSE;
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
        
        NSString *lmFile = [dynamicLanguageGenerationResultsDictionary objectForKey:@"LMFile"];
        NSString *dictionaryFile = [dynamicLanguageGenerationResultsDictionary objectForKey:@"DictionaryFile"];
        NSString *lmPath = [dynamicLanguageGenerationResultsDictionary objectForKey:@"LMPath"];
        NSString *dictionaryPath = [dynamicLanguageGenerationResultsDictionary objectForKey:@"DictionaryPath"];
        
        NSLog(@"Dynamic language generator completed successfully, you can find your new files %@\n and \n%@\n at the paths \n%@ \nand \n%@", lmFile,dictionaryFile,lmPath,dictionaryPath);
        
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
        
	}
	return fliteController;
}

- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (openEarsEventsObserver == nil) {
		openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
	return openEarsEventsObserver;
}

#pragma mark -
#pragma mark Public Methods

- (void) changeWordList:(NSArray *)words {
    NSLog(@"Set words lib to be %@", words);
    BOOL exist = self.wordList == nil;
    
    self.wordList = words;
    [self initLanguageModel];
    
    if (exist) {
        NSLog(@"Language model changed");
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
    [self.fliteController say:self.currentWordToMatch withVoice:self.slt];
}

- (void) readWord:(NSString *)word {
    [self.fliteController say:word withVoice:self.slt];
}

#pragma mark -
#pragma mark Delegate Methods

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
	NSLog(@"Heard %@, score %@", hypothesis, recognitionScore);
}

- (void) audioSessionInterruptionDidBegin {
	NSLog(@"AudioSession interruption began.");
	[self stopListening];
}

- (void) audioSessionInterruptionDidEnd {
	NSLog(@"AudioSession interruption ended.");
    [self startListening];
}

- (void) audioInputDidBecomeUnavailable {
	NSLog(@"The audio input has become unavailable");
	[self stopListening];
}

- (void) audioInputDidBecomeAvailable {
	NSLog(@"The audio input is available");
    [self startListening];
}

- (void) audioRouteDidChangeToRoute:(NSString *)newRoute {
	NSLog(@"Audio route change. The new audio route is %@", newRoute);
	[self stopListening];
    [self startListening];
}

- (void) pocketsphinxDidStartCalibration {
	NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
	NSLog(@"Pocketsphinx calibration is complete.");
	
	self.fliteController.duration_stretch = 1.0;
	self.fliteController.target_mean = 1.0;
	self.fliteController.target_stddev = 1.0;
}


- (void) pocketsphinxRecognitionLoopDidStart {
	NSLog(@"Pocketsphinx is starting up.");
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
	NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
	NSLog(@"Pocketsphinx has detected a second of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
	NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) fliteDidStartSpeaking {
	NSLog(@"Flite has started speaking");
}

- (void) fliteDidFinishSpeaking {
	NSLog(@"Flite has finished speaking");
}

- (void) pocketSphinxContinuousSetupDidFail {
	NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on [OpenEarsLogging startOpenEarsLogging] in OpenEarsConfig.h to learn more.");
}

- (void) testRecognitionCompleted {
	NSLog(@"A test file which was submitted for direct recognition via the audio driver is done.");
    [self stopListening];
    
}

- (void) pocketsphinxFailedNoMicPermissions {
    NSLog(@"The user has never set mic permissions or denied permission to this app's mic, so listening will not start.");
}

- (void) micPermissionCheckCompleted:(BOOL)result {
    if(result == TRUE) {
        self.restartAttemptsDueToPermissionRequests++;
        if(self.restartAttemptsDueToPermissionRequests == 1 && self.startupFailedDueToLackOfPermissions == TRUE) {
            [self startListening];
            self.startupFailedDueToLackOfPermissions = FALSE;
        }
    }
}


@end
