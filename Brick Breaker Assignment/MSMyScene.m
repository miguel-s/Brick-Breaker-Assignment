//
//  MSMyScene.m
//  Brick Breaker Assignment
//
//  Created by Miguel Serrano on 23/06/14.
//  Copyright (c) 2014 Miguel Serrano. All rights reserved.
//

#import "MSMyScene.h"

@implementation MSMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
