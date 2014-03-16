
#import <UIKit/UIKit.h>
#import "EZAudio.h"
#import <Accelerate/Accelerate.h>


@interface FFTViewController : UIViewController <EZMicrophoneDelegate>


@property (nonatomic,weak) IBOutlet EZAudioPlot *audioPlotFreq;
@property (nonatomic,weak) IBOutlet EZAudioPlotGL *audioPlotTime;
@property (nonatomic,strong) EZMicrophone *microphone;

@end
