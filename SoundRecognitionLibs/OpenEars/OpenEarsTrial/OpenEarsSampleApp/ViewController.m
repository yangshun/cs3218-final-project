#import "ViewController.h"
#import <OpenEars/PocketsphinxController.h>
#import <OpenEars/LanguageModelGenerator.h>
#import <OpenEars/OpenEarsLogging.h>
#import <OpenEars/AcousticModel.h>
#import <AVFoundation/AVAudioSession.h>

@implementation ViewController

@synthesize pocketsphinxController;
@synthesize openEarsEventsObserver;
@synthesize thresholds;

@synthesize sourceSwitch;
@synthesize statusTextView;
@synthesize heardTextView;
@synthesize scoreTextView;
@synthesize commandTextView;
@synthesize lightningSlider;
@synthesize waterSlider;
@synthesize leafSlider;
@synthesize fireSlider;
@synthesize novaSlider;
@synthesize pauseSlider;
@synthesize lightningLabel;
@synthesize waterLabel;
@synthesize leafLabel;
@synthesize fireLabel;
@synthesize novaLabel;
@synthesize pauseLabel;

@synthesize pathToGrammarToStartAppWith;
@synthesize pathToDictionaryToStartAppWith;
@synthesize pathToDynamicallyGeneratedGrammar;
@synthesize pathToDynamicallyGeneratedDictionary;

@synthesize restartAttemptsDueToPermissionRequests;
@synthesize startupFailedDueToLackOfPermissions;

@synthesize uiUpdateTimer;

#define kLevelUpdatesPerSecond 18

//#define kGetNbest
#pragma mark - 
#pragma mark Memory Management

- (void)dealloc {
    NSLog(@"dealloc!");
	openEarsEventsObserver.delegate = nil;
}

#pragma mark -
#pragma mark Lazy Allocation

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
    if (self.sourceSwitch.on) {
        NSLog(@"Using dynamic language model");
        [self.pocketsphinxController changeLanguageModelToFile:self.pathToDynamicallyGeneratedGrammar withDictionary:self.pathToDynamicallyGeneratedDictionary];
    }
}

- (void)lightningSliderChanged:(UISlider *)slider {
    [self.thresholds replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:(int)slider.value]];
    self.lightningLabel.text = [NSString stringWithFormat:@"%d", (int)slider.value];
}

- (void)waterSliderChanged:(UISlider *)slider {
    [self.thresholds replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:(int)slider.value]];
    self.waterLabel.text = [NSString stringWithFormat:@"%d", (int)slider.value];
}

- (void)leafSliderChanged:(UISlider *)slider {
    [self.thresholds replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:(int)slider.value]];
    self.leafLabel.text = [NSString stringWithFormat:@"%d", (int)slider.value];
}

- (void)fireSliderChanged:(UISlider *)slider {
    [self.thresholds replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:(int)slider.value]];
    self.fireLabel.text = [NSString stringWithFormat:@"%d", (int)slider.value];
}

- (void)novaSliderChanged:(UISlider *)slider {
    [self.thresholds replaceObjectAtIndex:4 withObject:[NSNumber numberWithInt:(int)slider.value]];
    self.novaLabel.text = [NSString stringWithFormat:@"%d", (int)slider.value];
}

- (void)pauseSliderChanged:(UISlider *)slider {
    [self.thresholds replaceObjectAtIndex:5 withObject:[NSNumber numberWithInt:(int)slider.value]];
    self.pauseLabel.text = [NSString stringWithFormat:@"%d", (int)slider.value];
}

#pragma mark -
#pragma mark View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    socketIO = [[SocketIO alloc] initWithDelegate:self];
    NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"192.168.43.56", NSHTTPCookieDomain,
                                @"/", NSHTTPCookiePath,
                                @"auth", NSHTTPCookieName,
                                @"56cdea636acdf132", NSHTTPCookieValue,
                                nil];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:properties];
    NSArray *cookies = [NSArray arrayWithObjects:cookie, nil];
    socketIO.cookies = cookies;
    [socketIO connectToHost:@"192.168.43.56" onPort:3218];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSArray *temp = [prefs arrayForKey:@"threshold"];
    if (temp) {
        NSLog(@"Got saved thresholds");
        self.thresholds = [NSMutableArray arrayWithArray:temp];
    } else {
        // lightning, water, leaf, fire, nova, pause
        self.thresholds = [NSMutableArray arrayWithObjects:[NSNumber numberWithInteger:-900],
                           [NSNumber numberWithInteger:-10000],
                           [NSNumber numberWithInteger:-7000],
                           [NSNumber numberWithInteger:-3000],
                           [NSNumber numberWithInteger:-1000],
                           [NSNumber numberWithInteger:-1000], nil];
    }
    
    self.lightningSlider.value = [[self.thresholds objectAtIndex:0] integerValue];
    self.waterSlider.value = [[self.thresholds objectAtIndex:1] integerValue];
    self.leafSlider.value = [[self.thresholds objectAtIndex:2] integerValue];
    self.fireSlider.value = [[self.thresholds objectAtIndex:3] integerValue];
    self.novaSlider.value = [[self.thresholds objectAtIndex:4] integerValue];
    self.pauseSlider.value = [[self.thresholds objectAtIndex:5] integerValue];
    
    self.lightningLabel.text = [NSString stringWithFormat:@"%d", (int)self.lightningSlider.value];
    self.waterLabel.text = [NSString stringWithFormat:@"%d", (int)self.waterSlider.value];
    self.leafLabel.text = [NSString stringWithFormat:@"%d", (int)self.leafSlider.value];
    self.fireLabel.text = [NSString stringWithFormat:@"%d", (int)self.fireSlider.value];
    self.novaLabel.text = [NSString stringWithFormat:@"%d", (int)self.novaSlider.value];
    self.pauseLabel.text = [NSString stringWithFormat:@"%d", (int)self.pauseSlider.value];
    
    [self.lightningSlider addTarget:self action:@selector(lightningSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.waterSlider addTarget:self action:@selector(waterSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.leafSlider addTarget:self action:@selector(leafSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.fireSlider addTarget:self action:@selector(fireSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.novaSlider addTarget:self action:@selector(novaSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [self.pauseSlider addTarget:self action:@selector(pauseSliderChanged:) forControlEvents:UIControlEventValueChanged];
    

    self.restartAttemptsDueToPermissionRequests = 0;
    self.startupFailedDueToLackOfPermissions = FALSE;
    
	[self.openEarsEventsObserver setDelegate:self];
	self.pathToGrammarToStartAppWith = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"appgrammar.arpa"];
	self.pathToDictionaryToStartAppWith = [NSString stringWithFormat:@"%@/%@",[[NSBundle mainBundle] resourcePath], @"appvocab.dic"];
	
	NSArray *languageArray = [[NSArray alloc] initWithArray:[NSArray arrayWithObjects:
                                                             @"A",
                                                             @"B",
                                                             @"C",
                                                             @"D",
                                                             @"E",
                                                             @"F",
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
}


#pragma mark -
#pragma mark OpenEarsEventsObserver delegate methods

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSString *heard = [NSString stringWithFormat:@"Heard: \"%@\"", hypothesis];
	NSString *scoreText = [NSString stringWithFormat:@"Score: \"%@\"", recognitionScore];
    self.heardTextView.text = heard;
    self.scoreTextView.text = scoreText;
    
    NSString *command = [[hypothesis componentsSeparatedByString:@" "] lastObject];
    int score = [recognitionScore intValue];
    NSLog(@"Command is %@, score is %d", command, score);
    
    self.commandTextView.text = @"UNKNOWN";
    if ([command isEqualToString:@"LIGHTNING"]) {
        if (score >= [[self.thresholds objectAtIndex:0] integerValue]) {
            commandTextView.text = @"LIGHTNING";
            [self sendLightning];
        }
    } else if([command isEqualToString:@"WATER"]) {
        if (score >= [[self.thresholds objectAtIndex:1] integerValue]) {
            self.commandTextView.text = @"WATER";
            [self sendWater];
        }
    } else if([command isEqualToString:@"FIRE"]) {
        if (score >= [[self.thresholds objectAtIndex:2] integerValue]) {
            self.commandTextView.text = @"FIRE";
            [self sendFire];
        }
    } else if([command isEqualToString:@"LEAF"]) {
        if (score >= [[self.thresholds objectAtIndex:3] integerValue]) {
            self.commandTextView.text = @"LEAF";
            [self sendLeaf];
        }
    } else if([command isEqualToString:@"NOVA"]) {
        if (score >= [[self.thresholds objectAtIndex:4] integerValue]) {
            self.commandTextView.text = @"NOVA";
            [self sendNova];
        }
    } else if([command isEqualToString:@"PAUSE"]) {
        if (score >= [[self.thresholds objectAtIndex:5] integerValue]) {
            self.commandTextView.text = @"PAUSE";
            [self sendPause];
        }
    }
}

#ifdef kGetNbest   
- (void) pocketsphinxDidReceiveNBestHypothesisArray:(NSArray *)hypothesisArray {
    NSLog(@"hypothesisArray is %@", hypothesisArray);
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

- (void) audioRouteDidChangeToRoute:(NSString *)newRoute {
	NSLog(@"Audio route change. The new audio route is %@", newRoute);
	self.statusTextView.text = [NSString stringWithFormat:@"Status: Audio route change. The new audio route is %@",newRoute];
	[self.pocketsphinxController stopListening];
    [self startListening];
}

- (void) pocketsphinxDidStartCalibration {
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
    [socketIO sendEvent:@"detected" withData:nil];
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

- (IBAction)sourceSwitchChanged:(id)sender {
    if (((UISwitch *)sender).on) {
        NSLog(@"Using dynamic language model");
        [self.pocketsphinxController changeLanguageModelToFile:self.pathToDynamicallyGeneratedGrammar withDictionary:self.pathToDynamicallyGeneratedDictionary];
    } else {
        NSLog(@"Using static language model");
        [self.pocketsphinxController changeLanguageModelToFile:self.pathToGrammarToStartAppWith withDictionary:self.pathToDictionaryToStartAppWith];
    }
}

# pragma mark -
# pragma mark socket.IO-objc delegate methods

- (void) socketIODidConnect:(SocketIO *)socket {
    NSLog(@"socket.io connected.");
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet {
    NSLog(@"didReceiveEvent()");
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error {
    if ([error code] == SocketIOUnauthorized) {
        NSLog(@"not authorized");
    } else {
        NSLog(@"onError() %@", error);
    }
}

# pragma mark -
# pragma mark UI

- (IBAction)saveButtonPressed:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:self.thresholds forKey:@"threshold"];
    NSLog(@"Threshold saved %@", self.thresholds);
}

- (IBAction)sendLightning {
    [socketIO sendEvent:@"command" withData:@"LIGHTNING"];
}

- (IBAction)sendWater {
    [socketIO sendEvent:@"command" withData:@"WATER"];
}

- (IBAction)sendFire {
    [socketIO sendEvent:@"command" withData:@"FIRE"];
}

- (IBAction)sendLeaf {
    [socketIO sendEvent:@"command" withData:@"LEAF"];
}

- (IBAction)sendPause {
    [socketIO sendEvent:@"command" withData:@"PAUSE"];
}

- (IBAction)sendNova {
    [socketIO sendEvent:@"command" withData:@"NOVA"];
}

@end
