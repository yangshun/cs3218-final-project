#import <UIKit/UIKit.h>

@class PocketsphinxController;
#import <OpenEars/OpenEarsEventsObserver.h>

@interface ViewController : UIViewController <OpenEarsEventsObserverDelegate> {
    
	OpenEarsEventsObserver *openEarsEventsObserver;
	PocketsphinxController *pocketsphinxController;
    
    NSMutableArray *thresholds;
    
	IBOutlet UITextView *statusTextView;
	IBOutlet UITextView *heardTextView;
    IBOutlet UITextView *scoreTextView;
    IBOutlet UITextView *commandTextView;
	int restartAttemptsDueToPermissionRequests;
    BOOL startupFailedDueToLackOfPermissions;

	NSString *pathToGrammarToStartAppWith;
	NSString *pathToDictionaryToStartAppWith;
	NSString *pathToDynamicallyGeneratedGrammar;
	NSString *pathToDynamicallyGeneratedDictionary;

	NSTimer *uiUpdateTimer;
}

@property (nonatomic, strong) OpenEarsEventsObserver *openEarsEventsObserver;
@property (nonatomic, strong) PocketsphinxController *pocketsphinxController;
@property (nonatomic, strong) NSMutableArray *thresholds;

@property (nonatomic, strong) IBOutlet UISwitch *sourceSwitch;

@property (nonatomic, strong) IBOutlet UITextView *statusTextView;
@property (nonatomic, strong) IBOutlet UITextView *heardTextView;
@property (nonatomic, strong) IBOutlet UITextView *scoreTextView;
@property (strong, nonatomic) IBOutlet UITextView *commandTextView;

@property (strong, nonatomic) IBOutlet UISlider *lightningSlider;
@property (strong, nonatomic) IBOutlet UISlider *waterSlider;
@property (strong, nonatomic) IBOutlet UISlider *leafSlider;
@property (strong, nonatomic) IBOutlet UISlider *fireSlider;
@property (strong, nonatomic) IBOutlet UISlider *novaSlider;
@property (strong, nonatomic) IBOutlet UISlider *pauseSlider;

@property (strong, nonatomic) IBOutlet UILabel *lightningLabel;
@property (strong, nonatomic) IBOutlet UILabel *waterLabel;
@property (strong, nonatomic) IBOutlet UILabel *leafLabel;
@property (strong, nonatomic) IBOutlet UILabel *fireLabel;
@property (strong, nonatomic) IBOutlet UILabel *novaLabel;
@property (strong, nonatomic) IBOutlet UILabel *pauseLabel;

- (IBAction)sourceSwitchChanged:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;

@property (nonatomic, copy) NSString *pathToGrammarToStartAppWith;
@property (nonatomic, copy) NSString *pathToDictionaryToStartAppWith;
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedGrammar;
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedDictionary;

@property (nonatomic, assign) int restartAttemptsDueToPermissionRequests;
@property (nonatomic, assign) BOOL startupFailedDueToLackOfPermissions;

@property (nonatomic, strong) 	NSTimer *uiUpdateTimer;

@end

