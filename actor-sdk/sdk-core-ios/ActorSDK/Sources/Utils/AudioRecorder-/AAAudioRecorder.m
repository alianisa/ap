#import "AAAudioRecorder.h"
#import "ASQueue.h"
#import "AATimer.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "AAAlertView.h"

#define AAUseModernAudio true

#import "AAOpusAudioRecorder.h"

@interface AAAudioRecorder () <AVAudioRecorderDelegate>
{
    AATimer *_timer;

    AAOpusAudioRecorder *_modernRecorder;

    BOOL sessionCanceled;
}

@end

@implementation AAAudioRecorder

- (void)dealloc
{
    [self cleanup];
}

+ (ASQueue *)audioRecorderQueue
{
    static ASQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        queue = [[ASQueue alloc] initWithName:"org.actor.audioRecorderQueue"];
    });
    return queue;
}

static NSMutableDictionary *recordTimers()
{
    static NSMutableDictionary *dict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dict = [[NSMutableDictionary alloc] init];
    });

    return dict;
}

static int currentTimerId = 0;

static void playSoundCompleted(__unused SystemSoundID ssID, __unused void *clientData)
{
    [[AAAudioRecorder audioRecorderQueue] dispatchOnQueue:^
    {
        int timerId = currentTimerId;
        AATimer *timer = (AATimer *)recordTimers()[@(timerId)];
        if ([timer isScheduled])
            [timer resetTimeout:0.001];
    }];
}

- (void)start
{
    sessionCanceled = false;
    NSLog(@"[AAAudioRecorder start]");

    [[AAAudioRecorder audioRecorderQueue] dispatchOnQueue:^
    {
        void (^recordBlock)(bool) = ^(bool granted)
        {
            if (granted)
            {
                _modernRecorder = [[AAOpusAudioRecorder alloc] initWithFileEncryption:false];
                NSTimeInterval prepareStart = CFAbsoluteTimeGetCurrent();

                [_timer invalidate];

                static int nextTimerId = 0;
                int timerId = nextTimerId++;

                __weak AAAudioRecorder *weakSelf = self;
                NSTimeInterval timeout = MIN(1.0, MAX(0.1, 1.0 - (CFAbsoluteTimeGetCurrent() - prepareStart)));
                _timer = [[AATimer alloc] initWithTimeout:timeout repeat:false completion:^
                {
                    __strong AAAudioRecorder *strongSelf = weakSelf;
                    [strongSelf _commitRecord];
                } queue:[AAAudioRecorder audioRecorderQueue].nativeQueue];
                recordTimers()[@(timerId)] = _timer;
                [_timer start];

                currentTimerId = timerId;
                

//                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);

                static SystemSoundID soundId;
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^
                {
                    NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"begin_record.caf"];
                    NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:false];
                    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundId);
                    if (soundId != 0)
                        AudioServicesAddSystemSoundCompletion(soundId, NULL, kCFRunLoopCommonModes, &playSoundCompleted, NULL);
                });

                AudioServicesPlaySystemSound(soundId);
            }
            else
            {
                [[[AAAlertView alloc] initWithTitle:nil message:@"We needs access to your microphone for voice messages. Please go to Settings — Privacy — Microphone and set to ON" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        };

        if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
        {
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    recordBlock(granted);
                });
            }];
        }
        else
            recordBlock(true);
    }];
}

- (NSTimeInterval)currentDuration
{
    return [_modernRecorder currentDuration];
}

- (void)_commitRecord
{
    if(!sessionCanceled){
        [_modernRecorder record];

        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           id<AAAudioRecorderDelegate> delegate = _delegate;
                           [_delegate audioRecorderDidStartRecording];
                       });
    }
}

- (void)cleanup
{
    AAOpusAudioRecorder *modernRecorder = _modernRecorder;
    _modernRecorder = nil;

    AATimer *timer = _timer;
    _timer = nil;

    [[AAAudioRecorder audioRecorderQueue] dispatchOnQueue:^
    {
        [timer invalidate];

        if (modernRecorder != nil)
            [modernRecorder stop:NULL];
    }];
}

- (void)cancel
{
    sessionCanceled = true;

    [[AAAudioRecorder audioRecorderQueue] dispatchOnQueue:^
    {
        [self cleanup];
    }];
}

- (void)finish:(void (^)(NSString *, NSTimeInterval))completion
{
    [[AAAudioRecorder audioRecorderQueue] dispatchOnQueue:^
    {
        NSString *resultPath = nil;
        NSTimeInterval resultDuration = 0.0;

        if (_modernRecorder != nil)
        {
            NSTimeInterval recordedDuration = 0.0;
            NSString *path = [_modernRecorder stop:&recordedDuration];
            if (path != nil && recordedDuration > 0.01)
            {
                resultPath = path;
                resultDuration = recordedDuration;
            }
        }

        if (completion != nil)
            completion(resultPath, resultDuration);
    }];
}


@end





//////



//@interface AAAudioRecorder () <AVAudioRecorderDelegate>
//{
//    AATimer *_timer;
//    bool _stopped;
//
//    AAOpusAudioRecorder *_modernRecorder;
//    AVAudioPlayer *_tonePlayer;
//    id _activityHolder;
//
//    BOOL sessionCanceled;
//
////    SMetaDisposable *_activityDisposable;
//}
//
//@end
//
//@implementation AAAudioRecorder
//
////- (instancetype)initWithFileEncryption:(bool)fileEncryption
////{
////    self = [super init];
////    if (self != nil)
////    {
////        _modernRecorder = [[AAOpusAudioRecorder alloc] initWithFileEncryption:fileEncryption];
////
////        _activityDisposable = [[SMetaDisposable alloc] init];
////
////        [[AAAudioRecorder audioRecorderQueue] dispatchOnQueue:^
////         {
////             __weak AAAudioRecorder *weakSelf = self;
////             _modernRecorder.pauseRecording = ^{
////                 __strong AAAudioRecorder *strongSelf = weakSelf;
////                 if (strongSelf != nil && strongSelf->_pauseRecording) {
////                     strongSelf->_pauseRecording();
////                 }
////             };
////         }];
////    }
////    return self;
////}
//
//- (void)dealloc
//{
//    [self cleanup];
////    [_activityDisposable dispose];
//}
//
////- (void)setMicLevel:(void (^)(CGFloat))micLevel {
////    _micLevel = [micLevel copy];
////    _modernRecorder.micLevel = micLevel;
////}
//
//+ (ASQueue *)audioRecorderQueue
//{
//    static ASQueue *queue = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^
//                  {
//                      queue = [[ASQueue alloc] initWithName:"org.actor.audioRecorderQueue"];
//                  });
//    return queue;
//}
//
//static NSMutableDictionary *recordTimers()
//{
//    static NSMutableDictionary *dict = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^
//                  {
//                      dict = [[NSMutableDictionary alloc] init];
//                  });
//
//    return dict;
//}
//
//static int currentTimerId = 0;
//
//static void playSoundCompleted(__unused SystemSoundID ssID, __unused void *clientData)
//{
//    int timerId = currentTimerId;
//    AATimer *timer = (AATimer *)recordTimers()[@(timerId)];
//    dispatch_block_t block = ^{
//        if ([timer isScheduled]) {
//            [timer fireAndInvalidate];
////            AALog(@"vibration completed");
//        }
//    };
//
////    if (![AAViewController isWidescreen]) {
////        AADispatchAfter(0.2, [AAAudioRecorder audioRecorderQueue].nativeQueue, block);
////    } else {
////        block();
////    }
//}
//
////- (void)startWithSpeaker:(bool)speaker1 completion:(void (^)())completion
////{
////    __weak AAAudioRecorder *weakSelf = self;
//////    [_activityDisposable setDisposable:[[[SSignal complete] delay:0.3 onQueue:[SQueue mainQueue]] startWithNext:nil error:nil completed:^{
////        __strong AAAudioRecorder *strongSelf = weakSelf;
////        if (strongSelf != nil && strongSelf->_requestActivityHolder) {
////            strongSelf->_activityHolder = strongSelf->_requestActivityHolder();
////        }
////    }]];
////
////    __unused static SystemSoundID soundId;
////    static dispatch_once_t onceToken;
////    dispatch_once(&onceToken, ^
////                  {
////                      /*NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"begin_record.caf"];
////                       NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:false];
////                       AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundId);
////                       if (soundId != 0) {
////                       //AudioServicesAddSystemSoundCompletion(soundId, NULL, kCFRunLoopCommonModes, &playSoundCompleted, NULL);
////                       }*/
////                      AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, kCFRunLoopCommonModes, &playSoundCompleted, NULL);
////                  });
////
//////    AALog(@"[AAAudioRecorder start]");
////
////    [[AAAudioRecorder audioRecorderQueue] dispatchOnQueue:^
////     {
////         void (^recordBlock)(bool) = ^(bool granted)
////         {
////             if (granted)
////             {
////                 [_timer invalidate];
////
////                 AALog(@"[AAAudioRecorder initialized session]");
////
////                 if (!_stopped && completion) {
////                     completion();
////                 }
////
////                 bool headphones = [AAMusicPlayer isHeadsetPluggedIn];
////                 bool speaker = headphones || speaker1;
////                 NSTimeInterval startTime = CACurrentMediaTime();
////                 [_modernRecorder _beginAudioSession:speaker];
////                 AALog(@"AudioSession time: %f s", CACurrentMediaTime() - startTime);
////
////                 /*static int nextTimerId = 0;
////                  int timerId = nextTimerId++;
////                  NSTimeInterval timeout = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? 0.5 : 1.0;
////                  __weak AAAudioRecorder *weakSelf = self;
////                  _timer = [[AATimer alloc] initWithTimeout:timeout repeat:false completion:^
////                  {
////                  AALog(@"[AAAudioRecorder record]");
////                  __strong AAAudioRecorder *strongSelf = weakSelf;
////
////                  [strongSelf _commitRecord];
////                  } queue:[AAAudioRecorder audioRecorderQueue].nativeQueue];
////                  recordTimers()[@(timerId)] = strongSelf->_timer;
////                  [strongSelf->_timer start];
////
////                  [strongSelf->_modernRecorder _beginAudioSession:speaker];
////                  currentTimerId = timerId;
////                  if (!speaker) {
////                  if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
////                  [strongSelf->_timer fireAndInvalidate];
////                  } else {
////                  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
////                  }
////                  } else {
////                  }
////
////                  [strongSelf->_timer fireAndInvalidate];*/
////
////                 [self _prepareRecord:speaker completion:nil];
////                 [self _commitRecord];
////             }
////             else
////             {
////                 [AAAccessChecker checkMicrophoneAuthorizationStatusForIntent:AAMicrophoneAccessIntentVoice alertDismissCompletion:nil];
////             }
////         };
////
////         if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
////         {
////             [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted)
////              {
////                  AADispatchOnMainThread(^
////                                         {
////                                             recordBlock(granted);
////                                         });
////              }];
////         }
////         else
////             recordBlock(true);
////     }];
////}
//
//- (void)start
//{
//    sessionCanceled = false;
//    NSLog(@"[AAAudioRecorder start]");
//
//    [[AAAudioRecorder audioRecorderQueue] dispatchOnQueue:^
//    {
//        void (^recordBlock)(bool) = ^(bool granted)
//        {
//            if (granted)
//            {
//                _modernRecorder = [[AAOpusAudioRecorder alloc] initWithFileEncryption:false];
//                NSTimeInterval prepareStart = CFAbsoluteTimeGetCurrent();
//
//                [_timer invalidate];
//
//                static int nextTimerId = 0;
//                int timerId = nextTimerId++;
//
//                __weak AAAudioRecorder *weakSelf = self;
//                NSTimeInterval timeout = MIN(1.0, MAX(0.1, 1.0 - (CFAbsoluteTimeGetCurrent() - prepareStart)));
//                _timer = [[AATimer alloc] initWithTimeout:timeout repeat:false completion:^
//                {
//                    __strong AAAudioRecorder *strongSelf = weakSelf;
//                    [strongSelf _commitRecord];
//                } queue:[AAAudioRecorder audioRecorderQueue].nativeQueue];
//                recordTimers()[@(timerId)] = _timer;
//                [_timer start];
//
//                currentTimerId = timerId;
//
//                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
//
//                static SystemSoundID soundId;
//                static dispatch_once_t onceToken;
//                dispatch_once(&onceToken, ^
//                {
//                    NSString *path = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"begin_record.caf"];
//                    NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:false];
//                    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundId);
//                    if (soundId != 0)
//                        AudioServicesAddSystemSoundCompletion(soundId, NULL, kCFRunLoopCommonModes, &playSoundCompleted, NULL);
//                });
//
//                AudioServicesPlaySystemSound(soundId);
//            }
//            else
//            {
//                [[[AAAlertView alloc] initWithTitle:nil message:@"We needs access to your microphone for voice messages. Please go to Settings — Privacy — Microphone and set to ON" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//            }
//        };
//
//        if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
//        {
//            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted)
//            {
//                dispatch_async(dispatch_get_main_queue(), ^
//                {
//                    recordBlock(granted);
//                });
//            }];
//        }
//        else
//            recordBlock(true);
//    }];
//}
//
//- (NSTimeInterval)currentDuration
//{
//    return [_modernRecorder currentDuration];
//}
//
//- (void)_prepareRecord:(bool)playTone completion:(void (^)())completion {
//    [_modernRecorder prepareRecord:playTone completion:^{
//        [[AAAudioRecorder audioRecorderQueue] dispatchOnQueue:^{
//            if (completion) {
//                completion();
//            }
//        }];
//    }];
//}
//
////- (void)_commitRecord
////{
//////    [_modernRecorder record];
//////
//////    AADispatchOnMainThread(^
//////                           {
//////                               id<AAAudioRecorderDelegate> delegate = _delegate;
//////                               if ([delegate respondsToSelector:@selector(audioRecorderDidStartRecording:)])
//////                                   [delegate audioRecorderDidStartRecording:self];
//////                           });
//////}
////
////    if(!sessionCanceled){
////        [_modernRecorder record];
////
////        dispatch_async(dispatch_get_main_queue(), ^
////                       {
////                           id<AAAudioRecorderDelegate> delegate = _delegate;
////                           [_delegate audioRecorderDidStartRecording];
////                       });
////    }
////}
//- (void)_commitRecord
//{
//    if(!sessionCanceled){
//        [_modernRecorder record];
//
//        dispatch_async(dispatch_get_main_queue(), ^
//                       {
//                           id<AAAudioRecorderDelegate> delegate = _delegate;
//                           [_delegate audioRecorderDidStartRecording];
//                       });
//    }
//}
//
//- (void)cleanup
//{
//    AAOpusAudioRecorder *modernRecorder = _modernRecorder;
//    _modernRecorder = nil;
//
//    AATimer *timer = _timer;
//    _timer = nil;
//
//    [[AAAudioRecorder audioRecorderQueue] dispatchOnQueue:^
//     {
//         [timer invalidate];
//
//         if (modernRecorder != nil)
//             [modernRecorder stopRecording:NULL waveform:NULL];
//     }];
//}
//
//- (void)cancel
//{
//    sessionCanceled = true;
//
////    [_activityDisposable dispose];
//    _stopped = true;
//    [[AAAudioRecorder audioRecorderQueue] dispatchOnQueue:^
//     {
//         [self cleanup];
//     }];
//}
////- (void)finish:(void (^)(NSString *, NSTimeInterval))completion
////{
////    [[AAAudioRecorder audioRecorderQueue] dispatchOnQueue:^
////    {
////        NSString *resultPath = nil;
////        NSTimeInterval resultDuration = 0.0;
//
////- (void)finish:(void (^)(NSString *, NSTimeInterval, AAAudioWaveform *))completion
//- (void)finish:(void (^)(NSString *, NSTimeInterval))completion
//
//{
////    [_activityDisposable dispose];
//    _stopped = true;
//    [[AAAudioRecorder audioRecorderQueue] dispatchOnQueue:^
//     {
//         NSString *resultDataItem = nil;
//         NSTimeInterval resultDuration = 0.0;
//         AAAudioWaveform *resultWaveform = nil;
////         __autoreleasing AALiveUploadActorData *liveData = nil;
//
//         if (_modernRecorder != nil)
//         {
//             NSTimeInterval recordedDuration = 0.0;
//             AAAudioWaveform *waveform = nil;
//             NSString *dataItem = [_modernRecorder stopRecording:&recordedDuration waveform:&waveform];
//             if (dataItem != nil && recordedDuration > 0.5)
//             {
//                 resultDataItem = dataItem;
//                 resultDuration = recordedDuration;
//                 resultWaveform = waveform;
//             }
//         }
//
//         if (completion != nil)
////             completion(resultDataItem, resultDuration, resultWaveform);
//             completion(resultDataItem, resultDuration);
//
//     }];
//}
//
//
//@end

