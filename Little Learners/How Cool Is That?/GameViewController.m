//
//  GameViewController.m
//  Little Learners
//
//  Created by Xiangxin Sun on 19/4/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import "GameViewController.h"
#import "GameAudioManager.h"

@interface GameViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *readyGoImageView;

@end

@implementation GameViewController

@synthesize readyGoImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
    [self animateReadyGo];
}

- (IBAction)dismiss {
    [[GameAudioManager sharedInstance] playExitSound];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)animateReadyGo {
    self.readyGoImageView.hidden = NO;
    [UIView animateWithDuration:0.9 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.readyGoImageView.transform = CGAffineTransformMakeScale(200, 200);
    } completion:^(BOOL finished) {
        self.readyGoImageView.transform = CGAffineTransformIdentity;
        self.readyGoImageView.image = [UIImage imageNamed: @"text-go.png"];
        [UIView animateWithDuration:1 delay:0.8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.readyGoImageView.transform = CGAffineTransformMakeScale(200, 200);
        } completion:^(BOOL finished) {
            self.readyGoImageView.transform = CGAffineTransformIdentity;
            self.readyGoImageView.hidden = YES;
        }];
    }];
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
