//
//  CategorySelectionViewController.m
//  Little Learners
//
//  Created by YangShun on 3/4/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import "CategorySelectionViewController.h"
#import "SpellViewController.h"
#import "Utils.h"
#import "Constants.h"
#import "GameAudioManager.h"

@interface CategorySelectionViewController () {
    OpenEarsVoiceManager *openEarsVoiceManager;
    AVAudioPlayer *exitSound;
}

@end

@implementation CategorySelectionViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismiss {
    [[GameAudioManager sharedInstance] playExitSound];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using
    [[GameAudioManager sharedInstance] playCategorySound];
    SpellViewController *vc = [segue destinationViewController];
    UIButton *btn = sender;
    NSArray *items;
    switch (btn.tag) {
        case 0:
            items = @[@"APPLE", @"BANANA", @"CHERRY", @"STRAWBERRY", @"BLUEBERRY", @"PEAR", @"ORANGE", @"LEMON", @"LIME", @"PEACH", @"WATERMELON", @"COCONUT", @"PINEAPPLE"];
            break;
        case 1:
            items = @[@"BEAR", @"BULL", @"ELEPHANT", @"GIRAFFE", @"LEOPARD", @"LION", @"MONKEY", @"REINDEER", @"RHINOCEROS", @"SNAKE", @"WOLF", @"ZEBRA"];
        default:
            break;
    }

    NSArray *fiveRandomItems = [[[Utils sharedManager] shuffle:items] subarrayWithRange:NSMakeRange(0, NUMBER_OF_WORDS_IN_LEVEL)];
    vc.wordsArray = fiveRandomItems;
    
//    openEarsVoiceManager = [OpenEarsVoiceManager sharedOpenEarsVoiceManager];
//    openEarsVoiceManager.wordList = items;
}


@end
