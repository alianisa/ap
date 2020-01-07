#import "NSObject+TGLock.h"

#import <objc/runtime.h>

static const char *lockPropertyKey = "TGObjectLock::lock";

@interface AAObjectLockImpl : NSObject
{
    AA_SYNCHRONIZED_DEFINE(objectLock);
}

- (void)aaTakeLock;
- (void)aaFreeLock;

@end

@implementation AAObjectLockImpl

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        AA_SYNCHRONIZED_INIT(objectLock);
    }
    return self;
}

- (void)aaTakeLock
{
    AA_SYNCHRONIZED_BEGIN(objectLock);
}

- (void)aaFreeLock
{
    AA_SYNCHRONIZED_END(objectLock);
}

@end

@implementation NSObject (AALock)

- (void)aaLockObject
{
    AAObjectLockImpl *lock = (AAObjectLockImpl *)objc_getAssociatedObject(self, lockPropertyKey);
    if (lock == nil)
    {
        @synchronized(self)
        {
            lock = [[AAObjectLockImpl alloc] init];
            objc_setAssociatedObject(self, lockPropertyKey, lock, OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    [lock aaTakeLock];
}

- (void)aaUnlockObject
{
    AAObjectLockImpl *lock = (AAObjectLockImpl *)objc_getAssociatedObject(self, lockPropertyKey);
    if (lock == nil)
    {
        @synchronized(self)
        {
            lock = [[AAObjectLockImpl alloc] init];
            objc_setAssociatedObject(self, lockPropertyKey, lock, OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    [lock aaFreeLock];
}

@end
