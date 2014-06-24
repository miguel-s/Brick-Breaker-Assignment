//
//  MSBrick.m
//  Brick Breaker Assignment
//
//  Created by Miguel Serrano on 23/06/14.
//  Copyright (c) 2014 Miguel Serrano. All rights reserved.
//

#import "MSBrick.h"

@implementation MSBrick
{
    SKAction *_brickSmashSound;
}

- (instancetype)initWithType:(BrickType)type {
    
    switch (type) {
        case Green:
            self = [super initWithImageNamed:@"BrickGreen"];
            break;
        case Blue:
            self = [super initWithImageNamed:@"BrickBlue"];
            break;
        case Grey:
            self = [super initWithImageNamed:@"BrickGrey"];
            break;
        case Yellow:
            self = [super initWithImageNamed:@"BrickYellow"];
            break;
        case MimiA:
            self = [super initWithImageNamed:@"MBrickGreen"];
            break;
        case MimiB:
            self = [super initWithImageNamed:@"MBrickBlue"];
            break;
        default:
            self = nil;
            break;
    }
    
    if (self) {
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.dynamic = NO;
        self.physicsBody.categoryBitMask = kMSBrickCategory;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = 0;
        self.type = type;
        self.indestructible = (self.type == Grey);
        self.spawnsExtraBall = (self.type == Yellow);
        
        _brickSmashSound = [SKAction playSoundFileNamed:@"BrickSmash.caf" waitForCompletion:NO];
    }
    
    return self;
}

- (void)hit {
    switch (self.type) {
        case Green:
            [self createExplosion];
            [self runAction:_brickSmashSound];
            [self runAction:[SKAction removeFromParent]];
            break;
        case Blue:
            self.type = Green;
            break;
        case Grey:
            break;
        case Yellow:
            [self createExplosion];
            [self runAction:_brickSmashSound];
            [self runAction:[SKAction removeFromParent]];
            break;
        case MimiA:
            [self createExplosion];
            [self runAction:[SKAction removeFromParent]];
            break;
        case MimiB:
            [self createExplosion];
            [self runAction:[SKAction removeFromParent]];
            break;
        default:
            break;
    }
}

- (void)createExplosion {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"BrickExplosion" ofType:@"sks"];
    SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    explosion.position = self.position;
    [self.parent addChild:explosion];
    
    SKAction *removeExplosion = [SKAction sequence:@[[SKAction waitForDuration:explosion.particleLifetime + explosion.particleLifetimeRange],
                                                     [SKAction removeFromParent]]];
    [explosion runAction:removeExplosion];
}

#pragma mark - Setters

- (void)setType:(BrickType)type {
    _type = type;
    
    switch (type) {
        case Green:
            self.texture = [SKTexture textureWithImageNamed:@"BrickGreen"];
            break;
        case Blue:
            self.texture = [SKTexture textureWithImageNamed:@"BrickBlue"];
            break;
        case Grey:
            self.texture = [SKTexture textureWithImageNamed:@"BrickGrey"];
            break;
        case Yellow:
            self.texture = [SKTexture textureWithImageNamed:@"BrickYellow"];
            break;
        case MimiA:
            self.texture = [SKTexture textureWithImageNamed:@"MBrickGreen"];
            break;
        case MimiB:
            self.texture = [SKTexture textureWithImageNamed:@"MBrickBlue"];
            break;
        default:
            break;
    }
}

@end
