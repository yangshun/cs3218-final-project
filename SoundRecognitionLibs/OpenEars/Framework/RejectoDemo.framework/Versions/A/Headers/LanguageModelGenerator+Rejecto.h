//
//  LanguageModelGenerator+Rejecto.h
//  Rejecto
//
//  Created by Halle on 8/14/12.
//  Copyright (c) 2012 Politepix. All rights reserved.
//

#import <OpenEars/LanguageModelGenerator.h>

/**
 @category  LanguageModelGenerator(Rejecto)
 @brief  A plugin which adds the ability to reject out-of-vocabulary words and statements when using OpenEars or RapidEars speech recognition.
 
 ## Usage examples
 > What to add to your OpenEars implementation:
 @htmlinclude LanguageModelGenerator+Rejecto_Implementation.txt
 @warning It isn't necessary to use optionalExclusions in order to try to tell Rejecto not to add a phoneme that is equivalent to a word in your vocabulary (for instance, Rejecto will add a phoneme by default that represents the "I" sound in the word "I" and the word "EYE", but if those words (or another word using the "I" sound by itself) are in your vocabulary, it will automatically not add the rejection phoneme that has the "I" sound. It's only necessary to use optionalExclusions in the uncommon event that there is a phoneme that is being perceived more frequently than it is spoken, to the detriment of your speech detection of words that are really in your vocabulary.
 */

@interface LanguageModelGenerator (Rejecto) 


/**This is the method which replaces OpenEars' LanguageModelGenerator's generateLanguageModelFromArray: method in a project which you have added this plugin to. 
It generates a language model from an array of NSStrings which are the words and phrases you want PocketsphinxController or PocketsphinxController+RapidEars to understand. Putting a phrase in as a string makes it somewhat more probable that the phrase will be recognized as a phrase when spoken. fileName is the way you want the output files to be named, for instance if you enter "MyDynamicLanguageModel" you will receive files output to your Caches directory titled MyDynamicLanguageModel.dic and MyDynamicLanguageModel.DMP. The error that this method returns contains the paths to the files that were created in a successful generation effort in its userInfo when NSError == noErr. The words and phrases in languageModelArray must be written with capital letters exclusively, for instance "word" must appear as "WORD". You pass in the path to the acoustic model you want to use, e.g. [AcousticModel pathToModel:@"AcousticModelEnglish"] or [AcousticModel pathToModel:@"AcousticModelSpanish"] which are currently the only two acoustic models which work with Rejecto.

optionalExclusions can either be set to nil, or given an NSArray of NSStrings which contain phonemes which you do not want to have added to the rejection model. A case in which you might want to do this is when you have over-active rejection such that words that are really in the vocabulary are being rejected. You can first turn on deliverRejectedSpeechInHypotheses: in order to see which phonemes are being detected overzealously and then you can add them to the exclusionArray. Set this parameter to nil if you aren't using it.

usingVowelsOnly allows you to limit the rejection model to only vowel phonemes, which should improve performance in cases where that is desired. Set this parameter to FALSE if you aren't using it.

The last optional parameter is weight, which should usually be set to nil, but can also be set to an NSNumber with a floatValue that is greater than zero and equal or less than 2.0. This will increase or decrease the weighting of the rejection model relative to the rest of the vocabulary. If it is less than 1.0 it will reduce the probability that the rejection model is detected, and if it is more than 1.0 it will increase the probability that the rejection model is detected. Only use this if your testing reveals that the rejection model is either being detected too frequently, or not frequently enough. It defaults to 1.0 and if you don't set it to anything (and you shouldn't, unless you have reason to believe that you should increase or decrease the probability of the rejection model being detected) it will automatically use the right setting. If you set it to a value that is equal to 1.0, or zero or less, or more than 2.0, the weight setting will be ignored and the default will be used. An NSNumber with a float looks like this: [NSNumber numberWithFloat:1.1]. The weight setting has no effect on the rest of your vocabulary, only the rejection model probabilities. Set this parameter to nil if you aren't using it. */

- (NSError *) generateRejectingLanguageModelFromArray:(NSArray *)languageModelArray withFilesNamed:(NSString *)fileName withOptionalExclusions:(NSArray *) optionalExclusions usingVowelsOnly:(BOOL)vowelsOnly withWeight:(NSNumber *)weight forAcousticModelAtPath:(NSString *)acousticModelPath;


/**Rejecto defaults to hiding recognized statements which are not words from your vocabulary (out of vocabulary recognitions), however if you want to see them for troubleshooting purposes you can set this method to TRUE. Note: Rejecto uses a particular token to denote phonemes that it rejects, so the delivered hypotheses will consist of these tokens, which have the format ___REJ_AA where the last part is the phoneme of the detected (and rejected) phoneme and the first part is the token which allows OpenEars and RapidEars to ignore the recognition. Even if you are using a language model that has already been created by Rejecto and don't need to run generateRejectingLanguageModelFromArray: during your app session, it is still necessary to instantiate LanguageModelGenerator+Rejecto and run deliverRejectedSpeechInHypotheses:FALSE if you want to see the phonemes that Rejecto is rejecting as part of your hypotheses. If you do not need to see them, you don't have to run the method since the default is for hypotheses with Rejecto phonemes only to not be returned. */

- (void) deliverRejectedSpeechInHypotheses:(BOOL)trueorfalse;

@end
