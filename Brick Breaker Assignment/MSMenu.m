//
//  MSMenu.m
//  Brick Breaker Assignment
//
//  Created by Miguel Serrano on 24/06/14.
//  Copyright (c) 2014 Miguel Serrano. All rights reserved.
//

#import "MSMenu.h"

@implementation MSMenu
{
    SKSpriteNode *_menuPanel;
    SKSpriteNode *_playButton;
    SKLabelNode *_menuText;
    SKLabelNode *_buttonText;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _menuPanel = [SKSpriteNode spriteNodeWithImageNamed:@"MenuPanel"];
        _menuPanel.position = CGPointZero;
        [self addChild:_menuPanel];
        
        _playButton = [SKSpriteNode spriteNodeWithImageNamed:@"Button"];
        _playButton.name = @"playButton";
        _playButton.position = CGPointMake(0.0, -((_menuPanel.size.height * 0.5) + (_playButton.size.height * 0.5) + 10.0));
        [self addChild:_playButton];
        
        _menuText = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
        _menuText.fontSize = 15.0;
        _menuText.fontColor = [SKColor grayColor];
        _menuText.text = @"LEVEL 0";
        _menuText.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _menuText.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _menuText.position = CGPointZero;
        [_menuPanel addChild:_menuText];
        
        _buttonText = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
        _buttonText.name = @"playLabel";
        _buttonText.fontSize = 15.0;
        _buttonText.fontColor = [SKColor grayColor];
        _buttonText.text = @"PLAY";
        _buttonText.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        _buttonText.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        _buttonText.position = CGPointMake(0.0, 2.0);
        [_playButton addChild:_buttonText];
        
    }
    return self;
}

- (void)show {
    SKAction *slideLeft = [SKAction moveByX:-260.0 y:0.0 duration:0.5];
    slideLeft.timingMode = SKActionTimingEaseOut;
    SKAction *slideRight = [SKAction moveByX:260.0 y:0.0 duration:0.5];
    slideRight.timingMode = SKActionTimingEaseOut;
    
    _menuPanel.position = CGPointMake(260.0, _menuPanel.position.y);
    _playButton.position = CGPointMake(-260.0, _playButton.position.y);
    
    [_menuPanel runAction:slideLeft];
    [_playButton runAction:slideRight];
    
    self.hidden = NO;
}

- (void)hide {
    SKAction *slideLeft = [SKAction moveByX:-260.0 y:0.0 duration:0.5];
    slideLeft.timingMode = SKActionTimingEaseIn;
    SKAction *slideRight = [SKAction moveByX:260.0 y:0.0 duration:0.5];
    slideRight.timingMode = SKActionTimingEaseIn;
    
    _menuPanel.position = CGPointMake(0.0, _menuPanel.position.y);
    _playButton.position = CGPointMake(0.0, _playButton.position.y);
    
    [_menuPanel runAction:slideLeft];
    [_playButton runAction:slideRight completion:^{
        self.hidden = YES;
    }];
}

#pragma mark - Setters

- (void)setLevelNumber:(int)levelNumber {
    _levelNumber = levelNumber;
    _menuText.text = [NSString stringWithFormat:@"LEVEL %i", levelNumber];
}

@end
