//
//  MSMyScene.m
//  Brick Breaker Assignment
//
//  Created by Miguel Serrano on 23/06/14.
//  Copyright (c) 2014 Miguel Serrano. All rights reserved.
//

#import "MSMyScene.h"
#import "MSBrick.h"
#import "MSMenu.h"

@interface MSMyScene ()

@property (nonatomic, assign) int lives;
@property (nonatomic, assign) int currentLevel;

@end

@implementation MSMyScene
{
    SKSpriteNode *_paddle;
    CGPoint _touchLocation;
    CGFloat _ballSpeed;
    SKNode *_brickLayer;
    BOOL _ballReleased;
    BOOL _positioningBall;
    NSArray *_hearts;
    SKLabelNode *_levelLabel;
    MSMenu *_menu;
    SKAction *_ballBounceSound;
    SKAction *_paddleBounceSound;
    SKAction *_levelUpSound;
    SKAction *_loseLifeSound;
}

static const int kMSFinalLevel = 2;

static const uint32_t kMSBallCategory       = 0x1 << 0;
static const uint32_t kMSPaddleCategory     = 0x1 << 1;
//static const uint32_t kMSBrickCategory      = 0x1 << 2; (declared in MSBrick.h)
static const uint32_t kMSEdgeCategory       = 0x1 << 3;

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        // Set contact delegate
        self.physicsWorld.contactDelegate = self;
        
        // Turn off gravity
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        
        // Set background
        self.backgroundColor = [SKColor whiteColor];
        
        // Add game edge
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0.0, -128.0, self.size.width, self.size.height + 100.0)];
        self.physicsBody.categoryBitMask = kMSEdgeCategory;
        self.physicsBody.collisionBitMask = 0;
        self.physicsBody.contactTestBitMask = 0;
        
        // Add HUD bar
        SKSpriteNode *bar = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithRed:212.0/255.0 green:212.0/255.0 blue:212.0/255.0 alpha:1.0] size:CGSizeMake(self.size.width, 28.0)];
        bar.anchorPoint = CGPointMake(0.0, 1.0);
        bar.position = CGPointMake(0.0, self.size.height);
        [self addChild:bar];
        
        // Add level label
        _levelLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
        _levelLabel.fontColor = [SKColor grayColor];
        _levelLabel.fontSize = 15.0;
        _levelLabel.text = @"Level 0";
        _levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _levelLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
        _levelLabel.position = CGPointMake(10.0, -10.0);
        [bar addChild:_levelLabel];
        
        // Add hearts (heart size 26x22)
        _hearts = @[[SKSpriteNode spriteNodeWithImageNamed:@"HeartFull"],
                    [SKSpriteNode spriteNodeWithImageNamed:@"HeartFull"]];
        for (int i = 0; i < _hearts.count; i++) {
            SKSpriteNode *heart = (SKSpriteNode*)_hearts[i];
            heart.position = CGPointMake(self.size.width - (16.0 + (29 * i)), self.size.height - 14.0);
            [self addChild:heart];
        }
        
        // Set up brick layer
        _brickLayer = [SKNode node];
        _brickLayer.position = CGPointMake(0.0, self.size.height - 28.0);
        [self addChild:_brickLayer];
        
        // Add paddle
        _paddle = [SKSpriteNode spriteNodeWithImageNamed:@"Paddle"];
        _paddle.position = CGPointMake(self.size.width * 0.5, 90.0);
        _paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_paddle.size];
        _paddle.physicsBody.dynamic = NO;
        _paddle.physicsBody.categoryBitMask = kMSPaddleCategory;
        _paddle.physicsBody.collisionBitMask = 0;
        _paddle.physicsBody.contactTestBitMask = 0;
        [self addChild:_paddle];
        
        // Set sounds
        _ballBounceSound = [SKAction playSoundFileNamed:@"BallBounce.caf" waitForCompletion:NO];
        _paddleBounceSound = [SKAction playSoundFileNamed:@"PaddleBounce.caf" waitForCompletion:NO];
        _levelUpSound = [SKAction playSoundFileNamed:@"LevelUp.caf" waitForCompletion:NO];
        _loseLifeSound = [SKAction playSoundFileNamed:@"LoseLife.caf" waitForCompletion:NO];
        
        // Add menu
        _menu = [[MSMenu alloc] init];
        _menu.position = CGPointMake(self.size.width * 0.5, self.size.height * 0.5);
        [self addChild:_menu];
        
        // Set initial values
        _ballSpeed = 250.0;
        _ballReleased = NO;
        self.currentLevel = 0;
        self.lives = 2;
        
        // Add initial ball
        [self newBall];
        
        // Load level
        [self loadLevel:self.currentLevel];
    }
    return self;
}

- (void)newBall {
    // Remove all active balls
    [self enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    _ballReleased = NO;
    
    // Initialize new ball
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"BallBlue"];
    ball.position = CGPointMake(0.0, _paddle.size.height);
    [_paddle addChild:ball];
    
    // Center paddle
    _paddle.position = CGPointMake(self.size.width * 0.5, _paddle.position.y);
}

- (void)loadLevel:(int)levelNumber {
    [_brickLayer removeAllChildren];
    
    NSArray *level = nil;
    
    switch (levelNumber) {
        case 0:
            level = @[@[@0,@0,@0,@0,@0,@0],
                      @[@0,@0,@0,@0,@0,@0],
                      @[@0,@0,@0,@0,@0,@0],
                      @[@0,@0,@0,@0,@0,@0],
                      @[@0,@0,@1,@0,@4,@0]];
            break;
        case 1:
            level = @[@[@1,@1,@1,@1,@1,@1],
                      @[@0,@0,@0,@0,@0,@0],
                      @[@3,@3,@1,@1,@3,@3],
                      @[@2,@2,@2,@2,@2,@2],
                      @[@2,@2,@4,@4,@2,@2]];
            break;
        case 2:
            level = @[@[@1,@1,@1,@1,@1,@1],
                      @[@1,@1,@3,@3,@1,@1],
                      @[@1,@1,@1,@1,@1,@1],
                      @[@2,@2,@2,@2,@2,@2],
                      @[@3,@3,@2,@2,@3,@3]];
            break;
        case 18:
            level = @[@[@18,@18,@18,@18,@18,@18],
                      @[@0,@0,@0,@0,@0,@0],
                      @[@19,@19,@19,@19,@19,@19],
                      @[@0,@0,@0,@0,@0,@0],
                      @[@18,@18,@18,@18,@18,@18],
                      @[@0,@0,@0,@0,@0,@0],
                      @[@19,@19,@19,@19,@19,@19]];
            break;
        default:
            break;
    }
    
    int row = 0;
    int col = 0;
    
    for (NSArray *rowBricks in level) {
        col = 0;
        for (NSNumber *brickType in rowBricks) {
            if ([brickType intValue] > 0) {
                MSBrick *brick = [[MSBrick alloc] initWithType:(BrickType)[brickType intValue]];
                if (brick) {
                    brick.position = CGPointMake(2.0 + (brick.size.width * 0.5) + ((3.0 + brick.size.width) * col), -(2.0 + (brick.size.height) + ((3.0 + brick.size.height) * row)));
                    [_brickLayer addChild:brick];
                }
            }
            col++;
        }
        row++;
    }
}

- (BOOL)isLevelComplete {
    for (SKNode *node in _brickLayer.children) {
        if ([node isKindOfClass:[MSBrick class]]) {
            if (!((MSBrick *)node).indestructible) {
                return NO;
            }
        }
    }
    return YES;
}

- (SKSpriteNode *)createBallWithPosition:(CGPoint)position andVelocity:(CGVector)velocity {
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"BallBlue"];
    ball.name = @"ball";
    ball.position = position;
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.size.width * 0.5];
    ball.physicsBody.velocity = velocity;
    ball.physicsBody.friction = 0.0;
    ball.physicsBody.linearDamping = 0.0;
    ball.physicsBody.restitution = 1.0;
    ball.physicsBody.categoryBitMask = kMSBallCategory;
    ball.physicsBody.collisionBitMask = kMSPaddleCategory | kMSBrickCategory | kMSEdgeCategory ;
    ball.physicsBody.contactTestBitMask = kMSPaddleCategory | kMSBrickCategory | kMSEdgeCategory;
    [self addChild:ball];
    return ball;
}

- (void)spawnExtraBallAt:(CGPoint)position {
    CGVector direction;
    if (arc4random_uniform(2) == 0) {
        direction = CGVectorMake(cosf(M_PI_4), sinf(M_PI_4));
    } else {
        direction = CGVectorMake(cosf(M_PI * 0.75), sinf(M_PI * 0.75));
    }
    [self createBallWithPosition:position andVelocity:CGVectorMake(direction.dx * _ballSpeed, direction.dy * _ballSpeed)];
}

- (void)update:(NSTimeInterval)currentTime {
    if ([self isLevelComplete]) {
        
        // Next level
        self.currentLevel++;
        if (self.currentLevel > kMSFinalLevel) {
            self.currentLevel = 0;
            self.lives = 2;
        }
        [self loadLevel:self.currentLevel];
        [self newBall];
        [_menu show];
        [self runAction:_levelUpSound];
    } else if (_ballReleased && !_positioningBall && ![self childNodeWithName:@"ball"]) {
        self.lives--;
        
        // Game over
        if (self.lives < 0) {
            self.lives = 2;
            self.currentLevel = 0;
            [self loadLevel:self.currentLevel];
            [_menu show];
        }
        [self newBall];
        [self runAction:_loseLifeSound];
    }
}

- (void)didSimulatePhysics {
    [self enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.frame.origin.y + node.frame.size.height < 0) {
            [node removeFromParent];
        }
    }];
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *firstBody;
    SKPhysicsBody *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // Contact between Ball and Paddle
    if(firstBody.categoryBitMask == kMSBallCategory && secondBody.categoryBitMask == kMSPaddleCategory) {
        //Check if ball above paddle
        if (firstBody.node.position.y > secondBody.node.position.y) {
            // Get contact point in paddle
            CGPoint pointInPaddle = [secondBody.node convertPoint:contact.contactPoint fromNode:self];
            // Contact point as percentage of paddle width
            CGFloat x = (pointInPaddle.x + secondBody.node.frame.size.width * 0.5) / secondBody.node.frame.size.width;
            // Limit percentage and flip it
            CGFloat multiplier = 1.0 - fmax(fmin(x, 1.0), 0.0);
            // Get bounce angle based on ball position on paddle
            CGFloat angle = (M_PI_2 * multiplier) + M_PI_4;
            // Convert angle to vector
            CGVector direction = CGVectorMake(cosf(angle), sinf(angle));
            // Bounce ball
            firstBody.velocity = CGVectorMake(direction.dx * _ballSpeed, direction.dy * _ballSpeed);
        }
        [self runAction:_paddleBounceSound];
    }
    
    // Contact between Ball and Brick
    if(firstBody.categoryBitMask == kMSBallCategory && secondBody.categoryBitMask == kMSBrickCategory) {
        if ([secondBody.node respondsToSelector:@selector(hit)]) {
            [secondBody.node performSelector:@selector(hit)];
            if (((MSBrick*)secondBody.node).spawnsExtraBall) {
                [self spawnExtraBallAt:[_brickLayer convertPoint:secondBody.node.position toNode:self]];
            }
        }
        [self runAction:_ballBounceSound];
    }
    if(firstBody.categoryBitMask == kMSBallCategory && secondBody.categoryBitMask == kMSEdgeCategory) {
        [self runAction:_ballBounceSound];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        if (_menu.hidden) {
            if (!_ballReleased) {
                _positioningBall = YES;
            }
        }
        _touchLocation = [touch locationInNode:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_menu.hidden) {
        if (_positioningBall) {
            _positioningBall = NO;
            _ballReleased = YES;
            [_paddle removeAllChildren];
            [self createBallWithPosition:CGPointMake(_paddle.position.x, _paddle.position.y + _paddle.size.height) andVelocity:CGVectorMake(0.0, _ballSpeed)];
        }
    } else {
        for (UITouch *touch in touches) {
            if ([[_menu nodeAtPoint:[touch locationInNode:_menu]].name isEqualToString:@"playButton"]) {
                [_menu hide];
            } else if ([[_menu nodeAtPoint:[touch locationInNode:_menu]].name isEqualToString:@"playLabel"]) {
                [_menu hide];
            }
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (_menu.hidden) {
        for (UITouch *touch in touches) {
            
            // Paddle movement
            CGFloat xMovement = [touch locationInNode:self].x - _touchLocation.x;
            _paddle.position = CGPointMake(_paddle.position.x + xMovement, _paddle.position.y);
            
            // Paddle movement limit
            CGFloat paddleMinX = 0.0 + _paddle.size.width * 0.5;
            CGFloat paddleMaxX = self.size.width - _paddle.size.width * 0.5;
            
            if (_paddle.position.x < paddleMinX) {
                _paddle.position = CGPointMake(paddleMinX, _paddle.position.y);
            }
            if (_paddle.position.x > paddleMaxX) {
                _paddle.position = CGPointMake(paddleMaxX, _paddle.position.y);
            }
            
            _touchLocation = [touch locationInNode:self];
        }
    }
}

#pragma mark - Setters

- (void)setLives:(int)lives {
    _lives = lives;
    for (int i = 0; i < _hearts.count; i++) {
        SKSpriteNode *heart = (SKSpriteNode *)_hearts[i];
        if (lives > i) {
            heart.texture = [SKTexture textureWithImageNamed:@"HeartFull"];
        } else {
            heart.texture = [SKTexture textureWithImageNamed:@"HeartEmpty"];
        }
    }
}

- (void)setCurrentLevel:(int)currentLevel {
    _currentLevel = currentLevel;
    _levelLabel.text = [NSString stringWithFormat:@"LEVEL %i", currentLevel];
    _menu.levelNumber = currentLevel;
}

@end