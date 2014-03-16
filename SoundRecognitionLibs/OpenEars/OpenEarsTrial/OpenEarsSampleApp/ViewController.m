#import "ViewController.h"
#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/OpenEarsLogging.h>
#import <OpenEars/AcousticModel.h>
#import <AVFoundation/AVAudioSession.h>

@implementation ViewController

@synthesize pocketsphinxController;
@synthesize statusTextView;
@synthesize heardTextView;
@synthesize scoreTextView;
@synthesize pocketsphinxDbLabel;
@synthesize openEarsEventsObserver;
@synthesize pathToGrammarToStartAppWith;
@synthesize pathToDictionaryToStartAppWith;
@synthesize pathToDynamicallyGeneratedGrammar;
@synthesize pathToDynamicallyGeneratedDictionary;
@synthesize uiUpdateTimer;
@synthesize restartAttemptsDueToPermissionRequests;
@synthesize startupFailedDueToLackOfPermissions;

#define kLevelUpdatesPerSecond 18

//#define kGetNbest // Uncomment this if you want to try out nbest
#pragma mark - 
#pragma mark Memory Management

- (void)dealloc {
	[self stopDisplayingLevels];
	openEarsEventsObserver.delegate = nil;
}

#pragma mark -
#pragma mark Lazy Allocation

// Lazily allocated PocketsphinxController.
- (PocketsphinxController *)pocketsphinxController { 
	if (pocketsphinxController == nil) {
		pocketsphinxController = [[PocketsphinxController alloc] init];
        pocketsphinxController.outputAudio = TRUE;
        pocketsphinxController.calibrationTime = 3;
        pocketsphinxController.secondsOfSilenceToDetect = 0.0001;
#ifdef kGetNbest        
        pocketsphinxController.returnNbest = TRUE;
        pocketsphinxController.nBestNumber = 5;
#endif        
	}
	return pocketsphinxController;
}

- (OpenEarsEventsObserver *)openEarsEventsObserver {
	if (openEarsEventsObserver == nil) {
		openEarsEventsObserver = [[OpenEarsEventsObserver alloc] init];
	}
	return openEarsEventsObserver;
}

- (void) startListening {
    
    [self.pocketsphinxController startListeningWithLanguageModelAtPath:self.pathToGrammarToStartAppWith dictionaryAtPath:self.pathToDictionaryToStartAppWith acousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:FALSE];
    
    [self.pocketsphinxController changeLanguageModelToFile:self.pathToDynamicallyGeneratedGrammar withDictionary:self.pathToDynamicallyGeneratedDictionary];
    
}

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.restartAttemptsDueToPermissionRequests = 0;
    self.startupFailedDueToLackOfPermissions = FALSE;
    
	[self.openEarsEventsObserver setDelegate:self];
	self.pathToGrammarToStartAppWith = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"OpenEars1.languagemodel"];
	self.pathToDictionaryToStartAppWith = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"OpenEars1.dic"];
	
	
	NSArray *languageArray = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects:
                                                             @"UP",
                                                             @"DOWN",
                                                             @"SHOOT",
                                                             @"FIRE",
                                                             @"PEW",
                                                             nil]];
    
	LanguageModelGenerator *languageModelGenerator = [[LanguageModelGenerator alloc] init];
	NSError *error = [languageModelGenerator generateLanguageModelFromArray:languageArray withFilesNamed:@"OpenEarsDynamicGrammar" forAcousticModelAtPath:[AcousticModel pathToModel:@"AcousticModelEnglish"]];
    
	NSDictionary *dynamicLanguageGenerationResultsDictionary = nil;
	if([error code] != noErr) {
		NSLog(@"Dynamic language generator reported error %@", [error description]);	
	} else {
		dynamicLanguageGenerationResultsDictionary = [error userInfo];
        
		NSString *lmFile = [dynamicLanguageGenerationResultsDictionary objectForKey:@"LMFile"];
		NSString *dictionaryFile = [dynamicLanguageGenerationResultsDictionary objectForKey:@"DictionaryFile"];
		NSString *lmPath = [dynamicLanguageGenerationResultsDictionary objectForKey:@"LMPath"];
		NSString *dictionaryPath = [dynamicLanguageGenerationResultsDictionary objectForKey:@"DictionaryPath"];
		
		NSLog(@"Dynamic language generator completed successfully, you can find your new files %@\n and \n%@\n at the paths \n%@ \nand \n%@", lmFile,dictionaryFile,lmPath,dictionaryPath);
		
		self.pathToDynamicallyGeneratedGrammar = lmPath;
		self.pathToDynamicallyGeneratedDictionary = dictionaryPath;
	}
	
	if(dynamicLanguageGenerationResultsDictionary) {
        [self startListening];
	}
	
	[self startDisplayingLevels];
}

#pragma mark -
#pragma mark OpenEarsEventsObserver delegate methods

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
	NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
	self.heardTextView.text = [NSString stringWithFormat:@"Heard: \"%@\"", hypothesis];
    self.scoreTextView.text = [NSString stringWithFormat:@"Score: \"%@\"", recognitionScore];
}

#ifdef kGetNbest   
- (void) pocketsphinxDidReceiveNBestHypothesisArray:(NSArray *)hypothesisArray { // Pocketsphinx has an n-best hypothesis dictionary.
    NSLog(@"hypothesisArray is %@",hypothesisArray);   
}
#endif

- (void) audioSessionInterruptionDidBegin {
	self.statusTextView.text = @"Status: AudioSession interruption began."; // interuption e.g. phone call
	[self.pocketsphinxController stopListening];
}

- (void) audioSessionInterruptionDidEnd {
	self.statusTextView.text = @"Status: AudioSession interruption ended.";
    [self startListening];
}

- (void) audioInputDidBecomeAvailable {
	self.statusTextView.text = @"Status: The audio input is available";
    [self startListening];
}

- (void) audioInputDidBecomeUnavailable {
	self.statusTextView.text = @"Status: The audio input has become unavailable";
	[self.pocketsphinxController stopListening];
}

// An optional delegate method of OpenEarsEventsObserver which informs that there was a change to the audio route (e.g. headphones were plugged in or unplugged).
- (void) audioRouteDidChangeToRoute:(NSString *)newRoute {
	NSLog(@"Audio route change. The new audio route is %@", newRoute); // Log it.
	self.statusTextView.text = [NSString stringWithFormat:@"Status: Audio route change. The new audio route is %@",newRoute]; // Show it in the status box.
    
	[self.pocketsphinxController stopListening]; // React to it by telling the Pocketsphinx loop to shut down and then start listening again on the new route
    [self startListening];
}


- (void) pocketsphinxDidStartCalibration {
    // avoid playing sound here
	self.statusTextView.text = @"Status: Pocketsphinx calibration has started.";
}

- (void) pocketsphinxDidCompleteCalibration {
	self.statusTextView.text = @"Status: Pocketsphinx calibration is complete.";
}

- (void) pocketsphinxRecognitionLoopDidStart {
	self.statusTextView.text = @"Status: Pocketsphinx is starting up.";
}

- (void) pocketsphinxDidStartListening {
	self.statusTextView.text = @"Status: Pocketsphinx is now listening.";
}

- (void) pocketsphinxDidDetectSpeech {
	self.statusTextView.text = @"Status: Pocketsphinx has detected speech.";
}

- (void) pocketsphinxDidDetectFinishedSpeech {
	self.statusTextView.text = @"Status: Pocketsphinx has detected finished speech.";
}

- (void) pocketsphinxDidStopListening {
	self.statusTextView.text = @"Status: Pocketsphinx has stopped listening.";
}

- (void) pocketSphinxContinuousSetupDidFail {
	self.statusTextView.text = @"Status: Not possible to start recognition loop.";
}

- (void) testRecognitionCompleted {
	NSLog(@"A test file which was submitted for direct recognition via the audio driver is done.");
    [self.pocketsphinxController stopListening];
}

- (void) pocketsphinxFailedNoMicPermissions {
    NSLog(@"The user has never set mic permissions or denied permission to this app's mic, so listening will not start.");
    self.startupFailedDueToLackOfPermissions = TRUE;
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

#pragma mark -
#pragma mark Example for reading out Pocketsphinx levels without locking the UI by using an NSTimer

- (void) startDisplayingLevels {
	[self stopDisplayingLevels];
	self.uiUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/kLevelUpdatesPerSecond target:self selector:@selector(updateLevelsUI) userInfo:nil repeats:YES];
}

- (void) stopDisplayingLevels {
	if(self.uiUpdateTimer && [self.uiUpdateTimer isValid]) {
		[self.uiUpdateTimer invalidate];
		self.uiUpdateTimer = nil;
	}
}

- (void) updateLevelsUI {
	self.pocketsphinxDbLabel.text = [NSString stringWithFormat:@"Pocketsphinx Input level:%f",[self.pocketsphinxController pocketsphinxInputLevel]];
}


@end
