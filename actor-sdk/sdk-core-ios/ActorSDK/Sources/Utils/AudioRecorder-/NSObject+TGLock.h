#import <Foundation/Foundation.h>

#import <pthread.h>

#define AA_SYNCHRONIZED_DEFINE(lock) pthread_mutex_t _AA_SYNCHRONIZED_##lock
#define AA_SYNCHRONIZED_INIT(lock) pthread_mutex_init(&_AA_SYNCHRONIZED_##lock, NULL)
#define AA_SYNCHRONIZED_BEGIN(lock) pthread_mutex_lock(&_AA_SYNCHRONIZED_##lock);
#define AA_SYNCHRONIZED_END(lock) pthread_mutex_unlock(&_AA_SYNCHRONIZED_##lock);

@interface NSObject (AALock)

- (void)aaLockObject;
- (void)aaUnlockObject;

@end
