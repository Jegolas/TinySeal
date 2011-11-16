//
//  TruckVehicle.h
//  TinySeal
//
//  Created by Jon on 11/14/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"
#import "BodyInfo.h"
//#import "Global.h"
#import "cocos2d.h"


@interface TruckVehicle : NSObject {
    
	b2Body *body;
	b2Body *wheel1;
	b2Body *wheel2;
	b2Body *axle1;
	b2Body *axle2;
	b2RevoluteJoint *motorJoint;
	b2RevoluteJoint *motor1;
	b2RevoluteJoint *motor2;
	b2PrismaticJoint *spring1;
	b2PrismaticJoint *spring2;
	float baseSpringForce;
@public
	float moveDirection;
//	CCSpriteSheet* _spriteManager;
	CCSprite* bodysprite;
	b2Body *cart;
	
}


-(id) CreateTruck:(b2World *) world spawnPoint:(CGPoint) spawnPoint;

-(void)updateVehicle;

@end
