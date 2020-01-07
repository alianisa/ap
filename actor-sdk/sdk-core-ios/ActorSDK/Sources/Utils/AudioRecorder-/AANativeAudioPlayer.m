#import "AANativeAudioPlayer.h"

#import "ASQueue.h"

#import <AVFoundation/AVFoundation.h>

//@interface AANativeAudioPlayer () <AVAudioPlayerDelegate>
//{
//    AVAudioPlayer *_audioPlayer;
//}
//
//@end
//
//@implementation AANativeAudioPlayer
//
//- (instancetype)initWithPath:(NSString *)path
//{
//    self = [super init];
//    if (self != nil)
//    {
//        __autoreleasing NSError *error = nil;
//        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
//        _audioPlayer.delegate = self;
//
//        if (_audioPlayer == nil || error != nil)
//        {
//            [self cleanupWithError];
//        }
//    }
//    return self;
//}
//
//- (void)dealloc
//{
//    [self cleanup];
//}
//
//- (void)cleanupWithError
//{
//    [self cleanup];
//}
//
//- (void)cleanup
//{
//    AVAudioPlayer *audioPlayer = _audioPlayer;
//    _audioPlayer.delegate = nil;
//    _audioPlayer = nil;
//
//    [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
//    {
//        [audioPlayer stop];
//    }];
//
//    [self _endAudioSessionFinal];
//}
//
//- (void)playFromPosition:(NSTimeInterval)position
//{
//    [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
//    {
//        [self _beginAudioSession];
//
//        if (position >= 0.0)
//            [_audioPlayer setCurrentTime:position];
//        [_audioPlayer play];
//    }];
//}
//
//- (void)pause
//{
//    [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
//    {
//        [_audioPlayer pause];
//    }];
//}
//
//- (void)stop
//{
//    [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
//    {
//        [_audioPlayer stop];
//    }];
//}
//
//- (NSTimeInterval)currentPositionSync:(bool)sync
//{
//    __block NSTimeInterval result = 0.0;
//
//    dispatch_block_t block = ^
//    {
//        result = [_audioPlayer currentTime];
//    };
//
//    if (sync)
//        [[AAAudioPlayer _playerQueue] dispatchOnQueue:block synchronous:true];
//    else
//        block();
//
//    return result;
//}
//
//- (NSTimeInterval)duration
//{
//    return [_audioPlayer duration];
//}
//
//- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)__unused player successfully:(BOOL)__unused flag
//{
//    [self _notifyFinished];
//}
//
//@end

@interface AANativeAudioPlayer ()
{
    AVPlayerItem *_currentItem;
}

@end

@implementation AANativeAudioPlayer

- (instancetype)initWithPath:(NSString *)path music:(bool)music controlAudioSession:(bool)controlAudioSession
{
    self = [super initWithMusic:music controlAudioSession:controlAudioSession];
    if (self != nil)
    {
        __autoreleasing NSError *error = nil;
        NSString *realPath = path;
        NSArray *audioExtensions = @[@"mp3", @"aac", @"m4a", @"mov", @"mp4"];
        if (![audioExtensions containsObject:realPath.pathExtension.lowercaseString]) {
            realPath = [path stringByAppendingPathExtension:@"mp3"];
            [[NSFileManager defaultManager] createSymbolicLinkAtPath:realPath withDestinationPath:path error:nil];
        }
        _currentItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:realPath]];
        if (_currentItem != nil) {
            _player = [[AVPlayer alloc] initWithPlayerItem:_currentItem];
//            _didPlayToEndObserver = [[AAObserverProxy alloc] initWithTarget:self targetSelector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
        }
        
        if (_player == nil || error != nil)
        {
            [self cleanupWithError];
        }
    }
    return self;
}

- (void)dealloc
{
    [self cleanup];
}

- (void)cleanupWithError
{
    [self cleanup];
}

- (void)cleanup
{
    AVPlayer *player = _player;
    _player = nil;
    
    [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
     {
         [player pause];
     }];
    
    [self _endAudioSessionFinal];
}

- (void)playFromPosition:(NSTimeInterval)position
{
    [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
     {
         [self _beginAudioSession];
         
         if (position >= 0.0) {
             CMTime targetTime = CMTimeMakeWithSeconds(position, NSEC_PER_SEC);
             [_currentItem seekToTime:targetTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
         }
         [_player play];
     }];
}

- (void)pause:(void (^)())completion
{
    [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
     {
         [_player pause];
         if (completion) {
             completion();
         }
     }];
}

- (void)stop
{
    [[AAAudioPlayer _playerQueue] dispatchOnQueue:^
     {
         [_player pause];
     }];
}

- (NSTimeInterval)currentPositionSync:(bool)sync
{
    __block NSTimeInterval result = 0.0;
    
    dispatch_block_t block = ^
    {
        result = CMTimeGetSeconds(_currentItem.currentTime);
    };
    
    if (sync)
        [[AAAudioPlayer _playerQueue] dispatchOnQueue:block synchronous:true];
    else
        block();
    
    return result;
}

- (NSTimeInterval)duration
{
    return CMTimeGetSeconds(_currentItem.duration);
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)__unused player successfully:(BOOL)__unused flag
{
}

- (void)playerItemDidPlayToEndTime:(NSNotification *)__unused notification
{
    [_player pause];
    
    [self _notifyFinished];
}

@end

