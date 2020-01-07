//
//  GradientView.m
//  Copyright © 2015 VoIPGRID. All rights reserved.
//

#import "GradientView.h"

//#import "Configuration.h"

@implementation GradientView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initFromConfig];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initFromConfig];
    }
    return self;
}

- (void)initFromConfig {
//    ColorConfiguration *colorConfig = [Configuration defaultConfiguration].colorConfiguration;
//
    self.startColor = [UIColor colorWithRed:17 green:2 blue:56 alpha:1.0];
    self.endColor = [UIColor colorWithRed:35 green:2 blue:56 alpha:1.0];

    self.angle = 300;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CFArrayRef colors = (__bridge CFArrayRef) @[(id)self.startColor.CGColor, (id)self.endColor.CGColor];

    CGFloat locations[2] = { 0.0, 1.0 };
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, locations);

    CGFloat degree = self.angle * M_PI / 180;
    CGPoint startPoint = CGPointMake(self.center.x - cos(degree) * self.center.x, self.center.y - sin(degree) * self.center.y);
    CGPoint endPoint = CGPointMake(self.center.x + cos(degree) * self.center.x, self.center.y + sin(degree) * self.center.y);

    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation + kCGGradientDrawsAfterEndLocation);

    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

@end
