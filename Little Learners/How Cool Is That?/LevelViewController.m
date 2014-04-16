//
//  LevelViewController.m
//  Little Learners
//
//  Created by YangShun on 8/4/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import "LevelViewController.h"
#import "GameAudioManager.h"

@interface LevelViewController () {
    
}

@end

@implementation LevelViewController

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
    
    self.currentWordIndex = 0;
    self.imagesArray = [NSMutableArray new];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Noun List"
                                                     ofType:@"plist"];
    
    NSDictionary *plistDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    for (NSString *s in self.wordsArray) {
        UIImage *img = [UIImage imageNamed:plistDict[s]];
        [self.imagesArray addObject:img];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)nextWord {
    if (self.currentWordIndex < self.wordsArray.count - 1) {
        self.currentWordIndex++;
    }
}

- (void)previousWord {
    if (self.currentWordIndex > 0) {
        self.currentWordIndex--;
    }
}

- (IBAction)dismiss {
    [[GameAudioManager sharedInstance] playExitSound];
    [self dismissViewControllerAnimated:YES completion:nil];
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
