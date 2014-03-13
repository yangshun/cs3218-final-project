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
    selfNinja.frame = CGRectMake(0, 0, NINJA_HEIGHT, NINJA_WIDTH);
    [self.view addSubview:selfNinja];
    
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
        connected = YES;
        [self setUpEnemy];
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
    dispatch_async(dispatch_get_main_queue(),^{
        [self updateNinjaPosition:enemyNinja
                      toNewCenter:CGPointFromString(message)];
    });
    
}

- (void)session:(MCSession *)session
           peer:(MCPeerID *)peerID
 didChangeState:(MCSessionState)state{
//    [self dismissBrowserVC];
}


# pragma mark - Game methods

- (void)setUpEnemy {
    enemyNinja = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ninja-red"]];
    enemyNinja.frame = CGRectMake(SCREEN_WIDTH - NINJA_WIDTH, 0, NINJA_HEIGHT, NINJA_WIDTH);
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
            NSString *message = NSStringFromCGPoint(CGPointMake(enemyNinja.center.x,
                                                                selfNinja.center.y));
            NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            if (![self.mySession sendData:data
                                  toPeers:[self.mySession connectedPeers]
                                 withMode:MCSessionSendDataUnreliable
                                    error:&error]) {
                NSLog(@"[Error] %@", error);
            }
        }
    }
    
    [self updateShurikensPosition];
}

- (void)updateNinjaPosition:(UIImageView *)ninja
                toNewCenter:(CGPoint)center {
    float newY = center.y;
    newY = MIN(newY, SCREEN_HEIGHT - NINJA_HEIGHT/2);
    newY = MAX(NINJA_HEIGHT/2, newY);
    ninja.center = CGPointMake(ninja.center.x, newY);
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
}

@end
