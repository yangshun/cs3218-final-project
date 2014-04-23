//
//  GameViewController.m
//  Little Learners
//
//  Created by Xiangxin Sun on 19/4/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import "GameViewController.h"
#import "GameAudioManager.h"
#import "Utils.h"
#import "Constants.h"

@interface GameViewController () {
    
    OpenEarsVoiceManager *openEarsVoiceManager;
    
    NSMutableArray *leftLetterLabels;
    NSMutableArray *rightLetterLabels;
    NSString *leftCurrentWord;
    NSString *rightCurrentWord;
    NSMutableArray *usedWords;
    
    int leftLevel;
    int rightLevel;
}

@property (strong, nonatomic) IBOutlet UIImageView *readyGoImageView;
@property (strong, nonatomic) IBOutlet UIView *gamePanelView;
@property (strong, nonatomic) IBOutlet UIView *leftWordView;
@property (strong, nonatomic) IBOutlet UIView *rightWordView;
@property (strong, nonatomic) IBOutlet UIImageView *leftCongratsView;
@property (strong, nonatomic) IBOutlet UIImageView *rightCongratsView;
@property (strong, nonatomic) IBOutlet UIImageView *wellDoneView;

@end

@implementation GameViewController

BOOL rotated = NO;

@synthesize readyGoImageView;
@synthesize gamePanelView;
@synthesize leftWordView;
@synthesize rightWordView;
@synthesize leftStarCollection;
@synthesize rightStartCollection;
@synthesize leftCongratsView;
@synthesize rightCongratsView;
@synthesize wellDoneView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!openEarsVoiceManager) {
        openEarsVoiceManager = [OpenEarsVoiceManager new];
        [openEarsVoiceManager.openEarsEventsObserver setDelegate: self];
        openEarsVoiceManager.wordList = self.wordArray;
    }
    if (![openEarsVoiceManager isSuspended] || ![openEarsVoiceManager isListening]) {
        [openEarsVoiceManager startListening];
    }
    
    usedWords = [NSMutableArray array];
    leftLevel = rightLevel = 0;
}

-(void)viewDidAppear:(BOOL)animated {
    [self animateReadyGo];
}

-(void)viewDidDisappear:(BOOL)animated {
    self.gamePanelView.hidden = YES;
}

- (IBAction)dismiss {
    [[GameAudioManager sharedInstance] playExitSound];
    [openEarsVoiceManager stopListening];
    openEarsVoiceManager.openEarsEventsObserver = nil;
    openEarsVoiceManager = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)leftSkip {
    [usedWords removeObject:leftCurrentWord];
    [self next:YES];
}

- (IBAction)rightSkip {
    [usedWords removeObject:leftCurrentWord];
    [self next:NO];
}

- (void)animateReadyGo {
    self.readyGoImageView.hidden = NO;
    [UIView animateWithDuration:0.9 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.readyGoImageView.transform = CGAffineTransformMakeScale(180, 180);
    } completion:^(BOOL finished) {
        self.readyGoImageView.transform = CGAffineTransformIdentity;
        self.readyGoImageView.image = [UIImage imageNamed: @"text-go.png"];
        [UIView animateWithDuration:1 delay:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.readyGoImageView.transform = CGAffineTransformMakeScale(170, 170);
        } completion:^(BOOL finished) {
            self.readyGoImageView.transform = CGAffineTransformIdentity;
            self.readyGoImageView.hidden = YES;
            self.gamePanelView.hidden = NO;
            [self gameStart];
        }];
    }];
}

-(void)gameStart {
    [self next:YES];
    [self next:NO];
}

#pragma mark Game Helper Functions

-(void)next:(BOOL)isLeft {
    if (isLeft) {
        leftCurrentWord = [self nextWord];
        [self display:[[Utils sharedManager] scrambleLettersArray:leftCurrentWord] onLeft:YES];
    } else {
        rightCurrentWord = [self nextWord];
        [self display:[[Utils sharedManager] scrambleLettersArray:rightCurrentWord] onLeft:NO];
    }
}

-(void)giveAwardTo:(BOOL)left and:(BOOL)right {
    if (left) {
        ((UIImageView *)[self.leftStarCollection objectAtIndex:leftLevel]).image = [UIImage imageNamed:@"star.png"];
        leftLevel += 1;
    }
    if (right) {
        ((UIImageView *)[self.rightStartCollection objectAtIndex:rightLevel]).image = [UIImage imageNamed:@"star.png"];
        rightLevel += 1;
    }
    
    if (leftLevel < 5 && rightLevel < 5) {
        if (left) [self next:YES];
        if (right) [self next:NO];
        return;
    }
    
    UIImageView *result;
    
    if (leftLevel >= 5 && rightLevel >= 5) {
        result = self.wellDoneView;
    } else if(leftLevel >= 5) {
        result = self.leftCongratsView;
    } else {
        result = self.rightCongratsView;
    }
    [openEarsVoiceManager stopListening];
    [[GameAudioManager sharedInstance] playCheerSound];
    result.hidden = NO;
    
    [self performSelector:@selector(shake:) withObject:result afterDelay:0.2];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:6];
}

-(void) shake:(UIImageView *)congratsView {
    [UIView beginAnimations:@"shake" context:nil];
    congratsView.transform = rotated ? CGAffineTransformMakeRotation(0.06): CGAffineTransformMakeRotation(-0.06);
    rotated = !rotated;
    [UIView commitAnimations];
    [self performSelector:@selector(shake:) withObject:congratsView afterDelay:0.2];
}


-(NSString *)nextWord {
    NSString *word = [self.wordArray objectAtIndex: arc4random() % [self.wordArray count]];
    int i = 0;
    while ([usedWords containsObject:word] && i < 8) {
        word = [self.wordArray objectAtIndex: arc4random() % [self.wordArray count]];
        i++;
    }
    [usedWords addObject:word];
    return word;
}

-(void)display: (NSString *)word onLeft:(BOOL)isLeft {
    [self clearBlackBoard:isLeft];
    if (isLeft) leftLetterLabels = [NSMutableArray array];
    else rightLetterLabels = [NSMutableArray array];
    
    word = [word uppercaseString];
    NSUInteger numberOfLetters = [word length];
    self.view.userInteractionEnabled = YES;
    float letterWidth = leftWordView.frame.size.width/word.length;
    for (int i = 0; i < numberOfLetters; i++) {
        UILabel *letter = [[UILabel alloc] initWithFrame:CGRectMake(i * letterWidth, 0,
                                                                    letterWidth, HEIGHT_OF_LETTER)];
        letter.textAlignment = NSTextAlignmentCenter;
        letter.font = [UIFont fontWithName:@"Marker Felt" size:48.f];
        letter.textColor = [UIColor whiteColor];
        letter.text = [NSString stringWithFormat:@"%c", [word characterAtIndex:i]];
        letter.userInteractionEnabled = YES;
        if (isLeft) {
            [leftWordView addSubview:letter];
            [leftLetterLabels addObject:letter];
        } else {
            [rightWordView addSubview:letter];
            [rightLetterLabels addObject:letter];
        }
    }
}

- (void)clearBlackBoard:(BOOL)isLeft {
    
    NSMutableArray *lettersArray = rightLetterLabels;
    if (isLeft)
        lettersArray = leftLetterLabels;
    for (UIView *sb in lettersArray) {
        [sb removeFromSuperview];
    }
    [lettersArray removeAllObjects];
}


#pragma mark Open Ears Delegate Methods

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis
                         recognitionScore:(NSString *)recognitionScore
                              utteranceID:(NSString *)utteranceID {
	NSLog(@"Heard %@, score %@", hypothesis, recognitionScore);
    NSLog(@"leftLevel %d, rightLevel %d", leftLevel, rightLevel);
    [self giveAwardTo:[[hypothesis componentsSeparatedByString:@" "] containsObject:leftCurrentWord]
                  and:[[hypothesis componentsSeparatedByString:@" "] containsObject:rightCurrentWord]];
}

- (void) pocketsphinxRecognitionLoopDidStart {
	NSLog(@"GameView Pocketsphinx is starting up.");
}

- (void) pocketsphinxDidStartCalibration {
	NSLog(@"GameView Pocketsphinx calibration has started.");
}

- (void) pocketsphinxDidCompleteCalibration {
	NSLog(@"GameView Pocketsphinx calibration is complete.");
}

- (void) pocketsphinxDidStartListening {
	NSLog(@"GameView Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
	NSLog(@"GameView Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
	NSLog(@"GameView Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidStopListening {
	NSLog(@"GameView Pocketsphinx has stopped listening.");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
