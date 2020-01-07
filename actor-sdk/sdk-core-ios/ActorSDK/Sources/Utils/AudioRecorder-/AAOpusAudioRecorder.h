#import <Foundation/Foundation.h>

@interface AAOpusAudioRecorder : NSObject

- (instancetype)initWithFileEncryption:(bool)fileEncryption;

- (void)record;
- (NSString *)stop:(NSTimeInterval *)recordedDuration;
- (NSTimeInterval)currentDuration;

@end

///

//@class AAAudioWaveform;
//
//@interface AAOpusAudioRecorder : NSObject
//
//@property (nonatomic, copy) void (^pauseRecording)();
////@property (nonatomic, copy) void (^micLevel)(CGFloat);
//
//- (instancetype)initWithFileEncryption:(bool)fileEncryption;
//
//- (void)_beginAudioSession:(bool)speaker;
//- (void)prepareRecord:(bool)playTone completion:(void (^)())completion;
//- (void)record;
////- (NSString *)stopRecording:(NSTimeInterval *)recordedDuration waveform:(__autoreleasing AAAudioWaveform **)waveform;
//- (NSString *)stop:(NSTimeInterval *)recordedDuration;
//
//- (NSTimeInterval)currentDuration;
//
//@end

