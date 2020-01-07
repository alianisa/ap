#import <Foundation/Foundation.h>

@class AAAudioRecorder;

@protocol AAAudioRecorderDelegate <NSObject>

@required

- (void)audioRecorderDidStartRecording;

@end

@interface AAAudioRecorder : NSObject

@property (nonatomic, weak) id<AAAudioRecorderDelegate> delegate;
@property (nonatomic, strong) id activityHolder;

- (void)start;
- (NSTimeInterval)currentDuration;
- (void)cancel;
- (void)finish:(void (^)(NSString *, NSTimeInterval))completion;

@end

///

//@class AAAudioRecorder;
//@class AAAudioWaveform;
//
//@protocol AAAudioRecorderDelegate <NSObject>

//@optional
//
//- (void)audioRecorderDidStartRecording:(AAAudioRecorder *)audioRecorder;
//
//@end

//@required
//
//- (void)audioRecorderDidStartRecording;
//
//@end
//
//@interface AAAudioRecorder : NSObject
//
//@property (nonatomic, weak) id<AAAudioRecorderDelegate> delegate;
//@property (nonatomic, copy) id (^requestActivityHolder)();
//@property (nonatomic, copy) void (^pauseRecording)();
////@property (nonatomic, copy) void (^micLevel)(CGFloat);
//
//- (instancetype)initWithFileEncryption:(bool)fileEncryption;
//
////- (void)startWithSpeaker:(bool)speaker completion:(void (^)())completion;
//- (void)start;
//- (NSTimeInterval)currentDuration;
//- (void)cancel;
////- (void)finish:(void (^)(NSString *, NSTimeInterval, AAAudioWaveform *))completion;
//- (void)finish:(void (^)(NSString *, NSTimeInterval))completion;
//
//@end

