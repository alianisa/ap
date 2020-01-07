#import "AAAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
//
//@interface AANativeAudioPlayer : AAAudioPlayer
//
//- (instancetype)initWithPath:(NSString *)path;
//
//@end


@interface AANativeAudioPlayer : AAAudioPlayer

@property (nonatomic, readonly) AVPlayer *player;

- (instancetype)initWithPath:(NSString *)path music:(bool)music controlAudioSession:(bool)controlAudioSession;

@end
