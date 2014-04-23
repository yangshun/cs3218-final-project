//
//  ViewController.m
//  Little Learners
//
//  Created by YangShun on 3/4/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import "ViewController.h"
#import "GameAudioManager.h"
#import "GameViewController.h"
#import "Constants.h"

@interface ViewController () {
    AVAudioPlayer *playSound;
    IBOutlet UIImageView *logo;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[GameAudioManager sharedInstance] playBackgroundMusic];


}

- (void)viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{

            logo.transform = CGAffineTransformMakeTranslation(0.0f, 280.0f);
            logo.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3f
                              delay:0.f
                            options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                         animations:^{
                             logo.transform = CGAffineTransformRotate(logo.transform, 0.06f);
                         } completion:^(BOOL finished) {
                             
                         }];
    }];
}


- (IBAction)play:(id)sender {
    [[GameAudioManager sharedInstance] playPlaySound];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    [[GameAudioManager sharedInstance] stopBackgroundMusic];
    UIButton *btn = sender;
    if (btn.tag == 100) {
        GameViewController *gvc = [segue destinationViewController];
        NSMutableArray *array = [NSMutableArray arrayWithArray:FRUITS];
        gvc.wordArray = [array arrayByAddingObjectsFromArray:ANIMALS];
    }
}


@end
