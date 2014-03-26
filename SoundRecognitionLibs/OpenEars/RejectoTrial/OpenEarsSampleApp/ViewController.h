#import <UIKit/UIKit.h>

@class PocketsphinxController;
#import <OpenEars/OpenEarsEventsObserver.h>

@interface ViewController : UIViewController <OpenEarsEventsObserverDelegate> {
    
	OpenEarsEventsObserver *openEarsEventsObserver; // A class whose delegate methods which will allow us to stay informed of changes in the Flite and Pocketsphinx statuses.
	PocketsphinxController *pocketsphinxController; // The controller for Pocketsphinx (voice recognition).
	// FliteController *fliteController; // The controller for Flite (speech).
    
	// Some UI, not specifically related to OpenEars.
	IBOutlet UITextView *statusTextView;
	IBOutlet UITextView *heardTextView;
    IBOutlet UITextView *scoreTextView;
	IBOutlet UILabel *pocketsphinxDbLabel;
	int restartAttemptsDueToPermissionRequests;
    BOOL startupFailedDueToLackOfPermissions;
	// Strings which aren't required for OpenEars but which will help us show off the dynamic language features in this sample app.
	NSString *pathToGrammarToStartAppWith;
	NSString *pathToDictionaryToStartAppWith;
	
	NSString *pathToDynamicallyGeneratedGrammar;
	NSString *pathToDynamicallyGeneratedDictionary;

	
	// Our NSTimer that will help us read and display the input and output levels without locking the UI
	NSTimer *uiUpdateTimer;
}

// Example for reading out the input audio levels without locking the UI using an NSTimer
- (void) startDisplayingLevels;
- (void) stopDisplayingLevels;

// These three are the important OpenEars objects that this class demonstrates the use of.
@property (nonatomic, strong) OpenEarsEventsObserver *openEarsEventsObserver;
@property (nonatomic, strong) PocketsphinxController *pocketsphinxController;
// @property (nonatomic, strong) FliteController *fliteController;

// Some UI, not specifically related to OpenEars.
@property (nonatomic, strong) IBOutlet UITextView *statusTextView;
@property (nonatomic, strong) IBOutlet UITextView *heardTextView;
@property (nonatomic, strong) IBOutlet UITextView *scoreTextView;
@property (nonatomic, strong) IBOutlet UILabel *pocketsphinxDbLabel;

@property (nonatomic, assign) int restartAttemptsDueToPermissionRequests;
@property (nonatomic, assign) BOOL startupFailedDueToLackOfPermissions;

// Things which help us show off the dynamic language features.
@property (nonatomic, copy) NSString *pathToGrammarToStartAppWith;
@property (nonatomic, copy) NSString *pathToDictionaryToStartAppWith;
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedGrammar;
@property (nonatomic, copy) NSString *pathToDynamicallyGeneratedDictionary;

// Our NSTimer that will help us read and display the input and output levels without locking the UI
@property (nonatomic, strong) 	NSTimer *uiUpdateTimer;

@end

