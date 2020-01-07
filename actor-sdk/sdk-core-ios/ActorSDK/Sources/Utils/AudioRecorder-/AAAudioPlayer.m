//#import "AAAudioPlayer.h"
//
//#import "ASQueue.h"
//
//#import "AAOpusAudioPlayerAU.h"
//#import "AANativeAudioPlayer.h"
//
//
//#import <AVFoundation/AVFoundation.h>
//
//@interface AAAudioPlayer ()
//{
//    bool _audioSessionIsActive;
//    bool _proximityState;
//}
//
//@end
//
//@implementation AAAudioPlayer
//
//+ (AAAudioPlayer *)audioPlayerForPath:(NSString *)path
//{
//    if (path == nil)
//        return nil;
//
//    if ([AAOpusAudioPlayerAU canPlayFile:path])
//        return [[AAOpusAudioPlayerAU alloc] initWithPath:path];
//    else
//        return [[AANativeAudioPlayer alloc] initWithPath:path];
//}
//
//- (instancetype)init
//{
//    self = [super init];
//    if (self != nil)
//    {
//    }
//    return self;
//}
//
//- (void)dealloc
//{
//}
//
//- (void)play
//{
//    [self playFromPosition:-1.0];
//}
//
//- (void)playFromPosition:(NSTimeInterval)__unused position
//{
//}
//
//- (void)pause
//{
//}
//
//- (void)stop
//{
//}
//
//- (NSTimeInterval)currentPositionSync:(bool)__unused sync
//{
//    return 0.0;
//}
//
//- (NSTimeInterval)duration
//{
//    return 0.0;
//}
//
//+ (ASQueue *)_playerQueue
//{
//    static ASQueue *queue = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^
//    {
//        queue = [[ASQueue alloc] initWithName:"im.alo.audioPlayerQueue"];
//    });
//
//    return queue;
//}
//
//- (void)_beginAudioSession
//{
//    [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
//    {
//        if (!_audioSessionIsActive)
//        {
//            __autoreleasing NSError *error = nil;
//            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//            bool overridePort = _proximityState && ![AAAudioPlayer isHeadsetPluggedIn];
//            if (![audioSession setCategory:overridePort ? AVAudioSessionCategoryPlayAndRecord :AVAudioSessionCategoryPlayback error:&error])
//                NSLog(@"[AAAudioPlayer audio session set category failed: %@]", error);
//            else if (![audioSession setActive:true error:&error])
//                NSLog(@"[AAAudioPlayer audio session activation failed: %@]", error);
//            else
//            {
////                if (![audioSession overrideOutputAudioPort:overridePort ? AVAudioSessionPortOverrideNone : AVAudioSessionPortOverrideSpeaker error:&error])
////                    NSLog(@"[AAAudioPlayer override route failed: %@]", error);
//                _audioSessionIsActive = true;
//            }
//        }
//    }];
//}
//
//- (void)_endAudioSession
//{
//    [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
//    {
//        if (_audioSessionIsActive)
//        {
//            __autoreleasing NSError *error = nil;
//            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//            if (![audioSession setActive:false error:&error])
//                NSLog(@"[AAAudioPlayer audio session deactivation failed: %@]", error);
//            if (![audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error])
//                NSLog(@"[AAAudioPlayer override route failed: %@]", error);
//
//            _audioSessionIsActive = false;
//        }
//    }];
//}
//
//- (void)_endAudioSessionFinal
//{
//    bool audioSessionIsActive = _audioSessionIsActive;
//    _audioSessionIsActive = false;
//
//    [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
//    {
//        if (audioSessionIsActive)
//        {
//            __autoreleasing NSError *error = nil;
//            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//            if (![audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error])
//                NSLog(@"[AAAudioPlayer override route failed: %@]", error);
//            if (![audioSession setActive:false error:&error])
//                NSLog(@"[AAAudioPlayer audio session deactivation failed: %@]", error);
//        }
//    }];
//}
//
//- (void)_notifyFinished
//{
//    id<AAAudioPlayerDelegate> delegate = _delegate;
//    if ([delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:)])
//        [delegate audioPlayerDidFinishPlaying:self];
//}
//
//+ (BOOL)isHeadsetPluggedIn
//{
//    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
//    for (AVAudioSessionPortDescription* desc in [route outputs]) {
//        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
//            return YES;
//    }
//    return NO;
//}
//
//@end

#import "AAAudioPlayer.h"

#import "ASQueue.h"

#import "AAOpusAudioPlayerAU.h"
#import "AANativeAudioPlayer.h"

#import <AVFoundation/AVFoundation.h>

//#import "AAAudioSessionManager.h"

@interface AAAudioPlayer ()
{
    bool _music;
    bool _controlAudioSession;
    
    bool _audioSessionIsActive;
    bool _proximityState;
//    AAObserverProxy *_proximityChangedNotification;
//    AAHolder *_proximityChangeHolder;
    
//    SMetaDisposable *_currentAudioSession;
    bool _changingProximity;
    
//    SMetaDisposable *_routeChangeDisposable;
}

@end

@implementation AAAudioPlayer

+ (AAAudioPlayer *)audioPlayerForPath:(NSString *)path music:(bool)music controlAudioSession:(bool)controlAudioSession
{
    if (path == nil)
        return nil;
    
    if ([AAOpusAudioPlayerAU canPlayFile:path])
        return [[AAOpusAudioPlayerAU alloc] initWithPath:path music:music controlAudioSession:controlAudioSession];
    else
        return [[AANativeAudioPlayer alloc] initWithPath:path music:music controlAudioSession:controlAudioSession];
}

- (instancetype)init {
    return [self initWithMusic:false controlAudioSession:true];
}

- (instancetype)initWithMusic:(bool)music controlAudioSession:(bool)controlAudioSession
{
    self = [super init];
    if (self != nil)
    {
        _music = music;
        _controlAudioSession = controlAudioSession;
        
//        _currentAudioSession = [[SMetaDisposable alloc] init];
        if (!_music && _controlAudioSession) {
//            _proximityState = AAAppDelegateInstance.deviceProximityState;
//            _proximityChangedNotification = [[AAObserverProxy alloc] initWithTarget:self targetSelector:@selector(proximityChanged:) name:AADeviceProximityStateChangedNotification object:nil];
//            _proximityChangeHolder = [[AAHolder alloc] init];
//            [AAAppDelegateInstance.deviceProximityListeners addHolder:_proximityChangeHolder];
            
            __weak AAAudioPlayer *weakSelf = self;
//            _routeChangeDisposable = [[[AAAudioSessionManager routeChange] deliverOn:[SQueue mainQueue]] startWithNext:^(NSNumber *action) {
//                if ([action intValue] == AAAudioSessionRouteChangePause) {
//                    __strong AAAudioPlayer *strongSelf = weakSelf;
//                    if (strongSelf != nil) {
//                        [strongSelf pause:nil];
//                        [strongSelf _notifyPaused];
//                    }
//                }
//            }];
        }
    }
    return self;
}

- (void)dealloc
{
    if (!_music) {
//        [AAAppDelegateInstance.deviceProximityListeners removeHolder:_proximityChangeHolder];
    }
}

- (void)play
{
    [self playFromPosition:-1.0];
}

- (void)playFromPosition:(NSTimeInterval)__unused position
{
}

- (void)pause:(void (^)())completion
{
    if (completion) {
        completion();
    }
}

- (void)stop
{
}

- (NSTimeInterval)currentPositionSync:(bool)__unused sync
{
    return 0.0;
}

- (NSTimeInterval)duration
{
    return 0.0;
}

+ (ASQueue *)_playerQueue
{
    static ASQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      queue = [[ASQueue alloc] initWithName:"org.actor.audioPlayerQueue"];
                  });
    
    return queue;
}

//- (void)proximityChanged:(NSNotification *)__unused notification
//{
//    if (_music) {
//        return;
//    }
//
//    bool proximityState = AAAppDelegateInstance.deviceProximityState;
//    [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
//     {
//         _proximityState = proximityState;
//         bool overridePort = _proximityState && ![AAAudioPlayer isHeadsetPluggedIn];
//         __weak AAAudioPlayer *weakSelf = self;
//         _changingProximity = true;
//         [_currentAudioSession setDisposable:[[AAAudioSessionManager instance] requestSessionWithType:overridePort ? AAAudioSessionTypePlayAndRecordHeadphones : AAAudioSessionTypePlayVoice interrupted:^
//                                              {
//                                                  __strong AAAudioPlayer *strongSelf = weakSelf;
//                                                  if (strongSelf != nil && !strongSelf->_changingProximity)
//                                                  {
//                                                      [strongSelf stop];
//                                                      [strongSelf _notifyFinished];
//                                                  }
//                                              }]];
//         _changingProximity = false;
//     }];
//}

//- (void)_beginAudioSession
//{
//    if (!_controlAudioSession) {
//        return;
//    }
//
//    [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
//     {
//         __weak AAAudioPlayer *weakSelf = self;
//         if (_music) {
//             [_currentAudioSession setDisposable:[[AAAudioSessionManager instance] requestSessionWithType:AAAudioSessionTypePlayMusic interrupted:^
//                                                  {
//                                                      __strong AAAudioPlayer *strongSelf = weakSelf;
//                                                      if (strongSelf != nil && !strongSelf->_changingProximity)
//                                                      {
//                                                          [strongSelf pause:nil];
//                                                          [strongSelf _notifyPaused];
//                                                      }
//                                                  }]];
//         } else {
//             bool overridePort = _proximityState && ![AAAudioPlayer isHeadsetPluggedIn];
//             [_currentAudioSession setDisposable:[[AAAudioSessionManager instance] requestSessionWithType:overridePort ? AAAudioSessionTypePlayAndRecordHeadphones : AAAudioSessionTypePlayVoice interrupted:^
//                                                  {
//                                                      __strong AAAudioPlayer *strongSelf = weakSelf;
//                                                      if (strongSelf != nil && !strongSelf->_changingProximity)
//                                                      {
//                                                          [strongSelf stop];
//                                                          [strongSelf _notifyFinished];
//                                                      }
//                                                  }]];
//         }
//     }];
//}

- (void)_beginAudioSession
{
    [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        if (!_audioSessionIsActive)
        {
            __autoreleasing NSError *error = nil;
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            bool overridePort = _proximityState && ![AAAudioPlayer isHeadsetPluggedIn];
            if (![audioSession setCategory:overridePort ? AVAudioSessionCategoryPlayAndRecord :AVAudioSessionCategoryPlayback error:&error])
                NSLog(@"[AAAudioPlayer audio session set category failed: %@]", error);
            else if (![audioSession setActive:true error:&error])
                NSLog(@"[AAAudioPlayer audio session activation failed: %@]", error);
            else
            {
//                if (![audioSession overrideOutputAudioPort:overridePort ? AVAudioSessionPortOverrideNone : AVAudioSessionPortOverrideSpeaker error:&error])
//                    NSLog(@"[AAAudioPlayer override route failed: %@]", error);
                _audioSessionIsActive = true;
            }
        }
    }];
}

//- (void)_endAudioSession
//{
//    if (!_controlAudioSession) {
//        return;
//    }
//
//    [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
//     {
//         [_currentAudioSession setDisposable:nil];
//     }];
//}

- (void)_endAudioSession
{
    if (!_controlAudioSession) {
        return;
    }
    [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
    {
        if (_audioSessionIsActive)
        {
            __autoreleasing NSError *error = nil;
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            if (![audioSession setActive:false error:&error])
                NSLog(@"[AAAudioPlayer audio session deactivation failed: %@]", error);
            if (![audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error])
                NSLog(@"[AAAudioPlayer override route failed: %@]", error);

            _audioSessionIsActive = false;
        }
    }];
}

- (void)_endAudioSessionFinal
{
    if (!_controlAudioSession) {
        return;
    }
    
//    SMetaDisposable *currentAudioSession = _currentAudioSession;
    
//    [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
//     {
//         [currentAudioSession setDisposable:nil];
//     }];
        [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
        {
            if (_audioSessionIsActive)
            {
                __autoreleasing NSError *error = nil;
                AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                if (![audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error])
                    NSLog(@"[AAAudioPlayer override route failed: %@]", error);
                if (![audioSession setActive:false error:&error])
                    NSLog(@"[AAAudioPlayer audio session deactivation failed: %@]", error);
            }
        }];
}

- (void)_notifyFinished
{
    id<AAAudioPlayerDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:)])
        [delegate audioPlayerDidFinishPlaying:self];
}

- (void)_notifyPaused {
    id<AAAudioPlayerDelegate> delegate = _delegate;
    if ([delegate respondsToSelector:@selector(audioPlayerDidPause:)])
        [delegate audioPlayerDidPause:self];
}

+ (bool)isHeadsetPluggedIn
{
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription *desc in [route outputs])
    {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return true;
    }
    return false;
}

@end

