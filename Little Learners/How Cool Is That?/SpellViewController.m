//
//  SpellViewController.m
//  Little Learners
//
//  Created by YangShun on 3/4/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import "SpellViewController.h"
#import "Constants.h"
#import "GameAudioManager.h"

@interface SpellViewController () {
    IBOutlet UIView *blackBoard;
    IBOutlet UIImageView *wordImage;
    IBOutlet UIButton *prevButton;
    IBOutlet UIButton *nextButton;
    IBOutlet UILabel *progressLabel;

    NSMutableArray *lettersArray;

    BOOL letterIsDragged;
    UILabel *letterBeingDragged;
    float letterWidth;
    NSMutableArray *solvedWords;
    NSMutableArray *seenWords;

    OpenEarsVoiceManager *openEarsVoiceManager;
}

@end

@implementation SpellViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    solvedWords = [NSMutableArray new];
    seenWords = [NSMutableArray new];
    openEarsVoiceManager = [OpenEarsVoiceManager new];
    [openEarsVoiceManager.openEarsEventsObserver setDelegate: self];
    openEarsVoiceManager.wordList = self.wordsArray;
    [openEarsVoiceManager startListening];
    [self setUpButtonDisplay];
}

- (void)setUpViewForWordIndex:(int)index
                      natural:(BOOL)nat {
    self.currentWord = self.wordsArray[index];
    
    openEarsVoiceManager.currentWordToMatch = self.currentWord;

    lettersArray = [NSMutableArray new];
    letterWidth = blackBoard.frame.size.width/self.currentWord.length;
    letterBeingDragged = nil;
    letterIsDragged = NO;
    wordImage.image = super.imagesArray[index];
    [self generateLetterFramesForWord:self.currentWord];
    if (nat || ![seenWords containsObject:self.currentWord]) {
        [openEarsVoiceManager readCurrentWord];
        [seenWords addObject:self.currentWord];
    }
    [self scramble:nil];
    [self setUpButtonDisplay];
    progressLabel.text = [NSString stringWithFormat:@"%d / 5", self.currentWordIndex + 1];
}

- (void)viewDidAppear:(BOOL)animated {
    [self setUpViewForWordIndex:super.currentWordIndex natural:YES];
}

- (void)setUpButtonDisplay {
    prevButton.hidden = NO;
    nextButton.hidden = NO;
    if (self.currentWordIndex == 0) {
        prevButton.hidden = YES;
    } else if (self.currentWordIndex == 4) {
        nextButton.hidden = YES;
    }
}

- (IBAction)nextWord:(id)sender {
    [super nextWord];
    [self clearBlackBoard];
    [self setUpViewForWordIndex:self.currentWordIndex
                        natural:NO];
    [[GameAudioManager sharedInstance] playNavSound];
}

- (IBAction)previousWord:(id)sender {
    [super previousWord];
    [self clearBlackBoard];
    [self setUpViewForWordIndex:self.currentWordIndex
                        natural:NO];
    [[GameAudioManager sharedInstance] playNavSound];
}

#pragma mark - Letter Shuffling Methods

- (void)clearBlackBoard {
    
    for (UIView *sb in lettersArray) {
        [sb removeFromSuperview];
    }
    [lettersArray removeAllObjects];
}

- (void)generateLetterFramesForWord:(NSString *)word {
    
    [self clearBlackBoard];
    word = [word uppercaseString];
    NSUInteger numberOfLetters = [word length];
    self.view.userInteractionEnabled = YES;

    for (int i = 0; i < numberOfLetters; i++) {
        UILabel *letter = [[UILabel alloc] initWithFrame:CGRectMake(i * letterWidth, 0,
                                                                    letterWidth, HEIGHT_OF_LETTER)];
        letter.textAlignment = NSTextAlignmentCenter;
        letter.font = [UIFont fontWithName:@"Marker Felt" size:64.f];
        letter.textColor = [UIColor whiteColor];
        letter.text = [NSString stringWithFormat:@"%c", [word characterAtIndex:i]];
        letter.userInteractionEnabled = YES;
        [blackBoard addSubview:letter];
        [lettersArray addObject:letter];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(letterDrag:)];
        [letter addGestureRecognizer:panGesture];
    }
}

- (void)letterDrag:(UIPanGestureRecognizer *)panGesture {
    UILabel *letter = (UILabel *)panGesture.view;
    if (![letterBeingDragged isEqual:letter] && letterIsDragged) {
        return;
    }
    
    letterBeingDragged = letter;
    letterIsDragged = YES;
    [lettersArray removeObject:letter];
    CGPoint translation = [panGesture translationInView:letter.superview];

    CGPoint panningStartPoint = letter.center;
    letter.center = CGPointMake(panningStartPoint.x + translation.x,
                              panningStartPoint.y + translation.y);
    int draggedLetterCurrentIndex = (int)letter.center.x / (int)letterWidth;
    draggedLetterCurrentIndex = MAX(0, draggedLetterCurrentIndex);
    draggedLetterCurrentIndex = MIN(draggedLetterCurrentIndex, self.currentWord.length - 1);

    for (int i = 0; i < self.currentWord.length - 1; i++) {
        UIView *l = lettersArray[i];
        int num = 0;
        if (i < draggedLetterCurrentIndex) {
            num = i;
        } else {
            num = i + 1;
        }
        [UIView animateWithDuration:0.3f animations:^{
            l.center = CGPointMake(num * letterWidth + letterWidth/2, HEIGHT_OF_LETTER/2);
        }];
    }
    
    [panGesture setTranslation:CGPointMake(0, 0)
                        inView:letter.superview];
    
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        letterBeingDragged = nil;
        letterIsDragged = NO;
        [lettersArray insertObject:letter atIndex:draggedLetterCurrentIndex];
        [self snapLettersToFinalPosition];
        if ([self compareWordSpelling]) {
            [self correctWordDetected];
        }
    }
}

- (void)correctWordDetected {
    [solvedWords addObject:self.currentWord];
    self.view.userInteractionEnabled = NO;
    [[GameAudioManager sharedInstance] playCheerSound];
    [self performSelector:@selector(nextWord:)
               withObject:nil
               afterDelay:4.f];
}

- (void)snapLettersToFinalPosition {
    for (int i = 0; i < lettersArray.count; i++) {
        UIView *l = lettersArray[i];
        [UIView animateWithDuration:0.3f animations:^{
            l.center = CGPointMake(i * letterWidth + letterWidth/2, HEIGHT_OF_LETTER/2);
        }];
    }
}

- (NSString *)scrambleLettersArray:(NSString *)inputString {
    
    NSUInteger length = [inputString length];
    
    if (!length) return nil;
    
    unichar *buffer = calloc(length, sizeof (unichar));
    
    [inputString getCharacters:buffer range:NSMakeRange(0, length)];
    
    for (int i = length - 1; i >= 0; i--){
        int j = arc4random() % (i + 1);
        unichar c = buffer[i];
        buffer[i] = buffer[j];
        buffer[j] = c;
    }
    
    NSString *scrambledWord = [NSString stringWithCharacters:buffer length:length];
    free(buffer);
    
    // caution, autoreleased. Allocate explicitly above or retain below to
    // keep the string.
    return scrambledWord;
}

- (BOOL)compareWordSpelling {
    NSMutableString *word = [NSMutableString string];
    for (UILabel *l in lettersArray) {
        [word appendString:[NSString stringWithFormat:@"%@", l.text]];
    }
    return [word isEqualToString:self.currentWord];
}

- (IBAction)scramble:(id)sender {
    [self generateLetterFramesForWord:[self scrambleLettersArray:self.currentWord]];
}


#pragma mark - Voice Control

- (BOOL)compareWordReading:(NSString*) heard {
    return [[heard componentsSeparatedByString:@" "] containsObject:self.currentWord];
}

- (IBAction)listenBtnPressed {
    [openEarsVoiceManager readCurrentWord];
}

- (IBAction)readBtnPressed {
    [openEarsVoiceManager resumeListening];
}

#pragma mark -
#pragma mark Open Ears Delegate Methods

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis
                         recognitionScore:(NSString *)recognitionScore
                              utteranceID:(NSString *)utteranceID {
	NSLog(@"Heard %@, score %@", hypothesis, recognitionScore);
    if ([self compareWordReading:hypothesis]) {
        [self correctWordDetected];
        [openEarsVoiceManager pauseListening];
    }
}

- (void) pocketsphinxRecognitionLoopDidStart {
	NSLog(@"Pocketsphinx is starting up.");
}

- (void) pocketsphinxDidStartCalibration {
	NSLog(@"Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
	NSLog(@"Pocketsphinx calibration is complete.");
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"Pocketsphinx is now listening.");
    [openEarsVoiceManager pauseListening];
}

- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) audioSessionInterruptionDidBegin {
	NSLog(@"AudioSession interruption began.");
	[openEarsVoiceManager stopListening];
}

- (void) audioSessionInterruptionDidEnd {
	NSLog(@"AudioSession interruption ended.");
    [openEarsVoiceManager startListening];
}

- (void) audioInputDidBecomeUnavailable {
	NSLog(@"The audio input has become unavailable");
	[openEarsVoiceManager stopListening];
}

- (void) audioInputDidBecomeAvailable {
	NSLog(@"The audio input is available");
    [openEarsVoiceManager startListening];
}

- (void) audioRouteDidChangeToRoute:(NSString *)newRoute {
	NSLog(@"Audio route change. The new audio route is %@", newRoute);
	[openEarsVoiceManager stopListening];
    [openEarsVoiceManager startListening];
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
	NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFail {
	NSLog(@"Setting up the continuous recognition loop has failed for some reason, please turn on [OpenEarsLogging startOpenEarsLogging] in OpenEarsConfig.h to learn more.");
}

- (void) testRecognitionCompleted {
	NSLog(@"A test file which was submitted for direct recognition via the audio driver is done.");
    [openEarsVoiceManager stopListening];
    
}

- (void) pocketsphinxFailedNoMicPermissions {
    NSLog(@"The user has never set mic permissions or denied permission to this app's mic, so listening will not start.");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
