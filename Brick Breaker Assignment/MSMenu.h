//
//  MSMenu.h
//  Brick Breaker Assignment
//
//  Created by Miguel Serrano on 24/06/14.
//  Copyright (c) 2014 Miguel Serrano. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MSMenu : SKNode

@property (nonatomic, assign) int levelNumber;

- (void)hide;
- (void)show;

@end
