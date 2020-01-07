#import "AAAudioPlayer.h"

//@interface AAOpusAudioPlayerAU : AAAudioPlayer
//
//+ (bool)canPlayFile:(NSString *)path;
//
//- (instancetype)initWithPath:(NSString *)path;
//
//@end

///

@interface AAOpusAudioPlayerAU : AAAudioPlayer

+ (bool)canPlayFile:(NSString *)path;

- (instancetype)initWithPath:(NSString *)path music:(bool)music controlAudioSession:(bool)controlAudioSession;

@end
