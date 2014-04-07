//
//  SpellViewController.m
//  Little Learners
//
//  Created by YangShun on 3/4/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import "SpellViewController.h"
#import "Constants.h"

@interface SpellViewController () {
    IBOutlet UIView *blackBoard;
    IBOutlet UIImageView *wordImage;

    NSMutableArray *lettersArray;

    BOOL letterIsDragged;
    UILabel *letterBeingDragged;
    float letterWidth;
}


@end

@implementation SpellViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpViewForWordIndex:super.currentWordIndex];
}

- (void)setUpViewForWordIndex:(int)index {
    self.currentWord = self.wordsArray[index];
    
    lettersArray = [NSMutableArray new];
    letterWidth = blackBoard.frame.size.width/self.currentWord.length;
    letterBeingDragged = nil;
    letterIsDragged = NO;
    wordImage.image = super.imagesArray[index];
    [self generateLetterFramesForWord:self.currentWord];
}

- (IBAction)nextWord:(id)sender {
    [super nextWord];
    [self clearBlackBoard];
    [self setUpViewForWordIndex:self.currentWordIndex];
}

- (IBAction)previousWord:(id)sender {
    [super previousWord];
    [self clearBlackBoard];
    [self setUpViewForWordIndex:self.currentWordIndex];
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
        if ([self compareWord]) {
            self.view.userInteractionEnabled = NO;
            [self.cheerPlayer play];
            [self performSelector:@selector(nextWord:)
                    withObject:nil
                       afterDelay:1.f];
        }
    }
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

- (BOOL)compareWord {
    NSMutableString *word = [NSMutableString string];
    for (UILabel *l in lettersArray) {
        [word appendString:[NSString stringWithFormat:@"%@", l.text]];
    }
    return [word isEqualToString:self.currentWord];
}

- (IBAction)scramble:(id)sender {
    [self generateLetterFramesForWord:[self scrambleLettersArray:self.currentWord]];
}

- (void)didReceiveMemoryWarning
{
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
