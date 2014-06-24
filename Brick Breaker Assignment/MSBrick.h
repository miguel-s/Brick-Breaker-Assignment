//
//  MSBrick.h
//  Brick Breaker Assignment
//
//  Created by Miguel Serrano on 23/06/14.
//  Copyright (c) 2014 Miguel Serrano. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum : NSUInteger {
    Green   = 1,
    Blue    = 2,
    Grey    = 3,
    Yellow  = 4,
    MimiA   = 18,
    MimiB   = 19,
} BrickType;

static const uint32_t kMSBrickCategory = 0x1 << 2;

@interface MSBrick : SKSpriteNode

@property (nonatomic, assign) BrickType type;
@property (nonatomic, assign) BOOL indestructible;
@property (nonatomic, assign) BOOL spawnsExtraBall;

- (instancetype)initWithType:(BrickType)type;
- (void)hit;

@end
