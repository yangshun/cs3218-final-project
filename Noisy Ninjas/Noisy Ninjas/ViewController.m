//
//  ViewController.m
//  Noisy Ninjas
//
//  Created by YangShun on 13/3/14.
//  Copyright (c) 2014 YangShun. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"
#import "AppDelegate.h"

@interface ViewController () {
    NSTimer *gameTimer;
    UIImageView *selfNinja;
    NSMutableArray *shurikens;
    
    BOOL updatePosition;
    BOOL directionIsUp;
    
    UIImageView *enemyNinja;
    NSMutableArray *enemyShurikens;
    
    UIView *healthBar;
    
    BOOL connected;
}

@property (nonatomic, strong) MCBrowserViewController *browserVC;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;
@property (nonatomic, strong) MCSession *mySession;
@property (nonatomic, strong) MCPeerID *myPeerID;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpMultipeer];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationNone];
    
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL
                                                 target:self
                                               selector:@selector(tick)
                                               userInfo:nil
                                                repeats:YES];
    
    directionIsUp = YES;
    
    selfNinja = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ninja-blue"]];
    selfNinja.frame = CGRectMake(0, SCREEN_HEIGHT/2 - NINJA_HEIGHT/2, NINJA_HEIGHT, NINJA_WIDTH);
    [self.view addSubview:selfNinja];
    
    healthBar = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 200, 20)];
    healthBar.backgroundColor = [UIColor colorWithRed:27.f/255.f
                                                green:214.f/255.f
                                                 blue:254.f/255.f
                                                alpha:1.0f];
    [self.view addSubview:healthBar];
    
    shurikens = [NSMutableArray new];
}


# pragma mark - MultiPeer methods

- (void)setUpMultipeer{
    //  Setup peer ID
    self.myPeerID = [[MCPeerID alloc] initWithDisplayName:[UIDevice currentDevice].name];
    
    //  Setup session
    self.mySession = [[MCSession alloc] initWithPeer:self.myPeerID];
    self.mySession.delegate = self;

    //  Setup BrowserViewController
    self.browserVC = [[MCBrowserViewController alloc] initWithServiceType:@"game"
                                                                  session:self.mySession];
    self.browserVC.delegate = self;
    
    //  Setup Advertiser
    self.advertiser = [[MCAdvertiserAssistant alloc] initWithServiceType:@"game"
                                                           discoveryInfo:nil
                                                                 session:self.mySession];
    connected = NO;
}

- (IBAction)showBrowserVC:(id)sender {
    [self presentViewController:self.browserVC animated:YES completion:nil];
    [self.advertiser start];
}

- (void)dismissBrowserVC{
    if ([[self.mySession connectedPeers] count] > 0) {
        if (!connected) {
            connected = YES;
            [self setUpEnemy];
        }
    }
    [self.browserVC dismissViewControllerAnimated:YES completion:nil];
}

#pragma marks MCBrowserViewControllerDelegate

// Notifies the delegate, when the user taps the done button
- (void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController {
    [self dismissBrowserVC];
}

// Notifies delegate that the user taps the cancel button.
- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController {
    [self dismissBrowserVC];
}

#pragma mark MCSessionDelegate

- (void)session:(MCSession *)session
 didReceiveData:(NSData *)data
       fromPeer:(MCPeerID *)peerID {
    NSString *message = [[NSString alloc] initWithData:data
                                              encoding:NSUTF8StringEncoding];
    
    NSArray *messageComponents = [message componentsSeparatedByString:@":"];
    NSString *key = messageComponents[0];
    if ([key isEqualToString:@"ninja"]) {
        float newY = [messageComponents[1] floatValue];
        dispatch_async(dispatch_get_main_queue(),^{
            [self updateNinjaPosition:enemyNinja
                          toNewCenter:CGPointMake(enemyNinja.center.x, newY)];
        });
    } else if ([key isEqualToString:@"shuriken"]) {
        float shurikenY = [messageComponents[1] floatValue];
        dispatch_async(dispatch_get_main_queue(),^{
            UIImageView *shuriken = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shuriken-4-point-star"]];
            shuriken.frame = CGRectMake(0, 0, SHURIKEN_SIZE, SHURIKEN_SIZE);
            shuriken.center = CGPointMake(enemyNinja.center.x - 40.f, shurikenY);
            [enemyShurikens addObject:shuriken];
            [self.view addSubview:shuriken];
        });
    }
}

- (void)session:(MCSession *)session
           peer:(MCPeerID *)peerID
 didChangeState:(MCSessionState)state{
//    [self dismissBrowserVC];
}


# pragma mark - Game methods

- (void)setUpEnemy {
    enemyNinja = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ninja-red"]];
    enemyNinja.frame = CGRectMake(SCREEN_WIDTH - NINJA_WIDTH,
                                  SCREEN_HEIGHT/2 - NINJA_HEIGHT/2,
                                  NINJA_HEIGHT,
                                  NINJA_WIDTH);
    enemyNinja.transform = CGAffineTransformMakeScale(-1.f, 1.f);
    [self.view addSubview:enemyNinja];

    enemyShurikens = [NSMutableArray new];
}

- (void)tick {
    if (updatePosition) {
        int movement = directionIsUp ? -MOVEMENT_DIST : MOVEMENT_DIST;
        [self updateNinjaPosition:selfNinja
                      toNewCenter:CGPointMake(selfNinja.center.x,
                                              selfNinja.center.y + movement)];
        if (connected) {
            NSString *message = [NSString stringWithFormat:@"ninja:%f", selfNinja.center.y];
            NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            if (![self.mySession sendData:data
                                  toPeers:[self.mySession connectedPeers]
                                 withMode:MCSessionSendDataReliable
                                    error:&error]) {
                NSLog(@"[Error] %@", error);
            }
        }
    }
    
    [self updateShurikensPosition];
    [self checkCollisionWithSelfNinja];
}

- (void)updateNinjaPosition:(UIImageView *)ninja
                toNewCenter:(CGPoint)center {
    float newY = center.y;
    newY = MIN(newY, SCREEN_HEIGHT - NINJA_HEIGHT/2);
    newY = MAX(NINJA_HEIGHT/2, newY);
    ninja.center = CGPointMake(ninja.center.x, newY);
}

- (void)checkCollisionWithSelfNinja {
    NSMutableArray *outOfBoundsEnemyShurikens = [NSMutableArray new];
    for (UIImageView *shuriken in enemyShurikens) {
        if (sqrt(pow(shuriken.center.x - selfNinja.center.x, 2) +
                 pow(shuriken.center.y - selfNinja.center.y, 2)) <
            SHURIKEN_SIZE/2 + NINJA_WIDTH/2) {
            
            healthBar.frame = CGRectMake(healthBar.frame.origin.x,
                                         healthBar.frame.origin.y,
                                         healthBar.frame.size.width - 20,
                                         healthBar.frame.size.height);
            [outOfBoundsEnemyShurikens addObject:shuriken];
            [shuriken removeFromSuperview];
        }
    }
    [enemyShurikens removeObjectsInArray:outOfBoundsEnemyShurikens];
}

- (void)updateShurikensPosition {
    
    NSMutableArray *outOfBoundsShurikens = [NSMutableArray new];
    
    for (UIImageView *shuriken in shurikens) {
        shuriken.center = CGPointMake(shuriken.center.x + 20.f,
                                      shuriken.center.y);
        shuriken.transform = CGAffineTransformRotate(shuriken.transform, 10.f);
        
        if (shuriken.center.x > SCREEN_WIDTH) {
            [outOfBoundsShurikens addObject:shuriken];
            [shuriken removeFromSuperview];
        }
    }
    
    [shurikens removeObjectsInArray:outOfBoundsShurikens];
    
    NSMutableArray *outOfBoundsEnemyShurikens = [NSMutableArray new];
    
    for (UIImageView *shuriken in enemyShurikens) {
        shuriken.center = CGPointMake(shuriken.center.x - 20.f,
                                      shuriken.center.y);
        shuriken.transform = CGAffineTransformRotate(shuriken.transform, -10.f);
        
        if (shuriken.center.x < 0) {
            [outOfBoundsEnemyShurikens addObject:shuriken];
            [shuriken removeFromSuperview];
        }
    }
    
    [enemyShurikens removeObjectsInArray:outOfBoundsEnemyShurikens];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UI elements interaction

- (IBAction)upButtonTouchDown {
    updatePosition = YES;
    directionIsUp = YES;
}

- (IBAction)downButtonTouchDown {
    updatePosition = YES;
    directionIsUp = NO;
}

- (IBAction)cancelMovement {
    updatePosition = NO;
}

- (IBAction)shoot:(id)sender {
    UIImageView *shuriken = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shuriken-4-point-star"]];
    shuriken.frame = CGRectMake(0, 0, SHURIKEN_SIZE, SHURIKEN_SIZE);
    shuriken.center = CGPointMake(selfNinja.center.x + 40.f, selfNinja.center.y);
    [shurikens addObject:shuriken];
    [self.view addSubview:shuriken];
    
    NSString *message = [NSString stringWithFormat:@"shuriken:%f", selfNinja.center.y];
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;

    if (![self.mySession sendData:data
                          toPeers:[self.mySession connectedPeers]
                         withMode:MCSessionSendDataReliable
                            error:&error]) {
        NSLog(@"[Error] %@", error);
    }
}

@end
