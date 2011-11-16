//
//  TruckVehicle.mm
//  TinySeal
//
//  Created by Jon on 11/14/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "TruckVehicle.h"

@implementation TruckVehicle

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(id)CreateTruck:(b2World *) world  spawnPoint:(CGPoint) spawnPoint;
{
	
	self = [super init];
	if (self != nil) 
	{	
		
		// add cart //
		b2BodyDef bodyDef;
		bodyDef.type = b2_dynamicBody;
		//bodyDef.position.Set(spawnPoint.x/ m_physScale, spawnPoint.y/PTM_RATIO);
		bodyDef.position.Set(spawnPoint.x, spawnPoint.y);
		NSLog(@"spawn location = %f,%f", spawnPoint.x, spawnPoint.y);
		
		cart = world->CreateBody(&bodyDef);
		
		b2FixtureDef boxDef;
		boxDef.density = 10/2;
		boxDef.friction = 0.5;
		boxDef.restitution = 0.2;
		boxDef.filter.groupIndex = -1;
		
		b2PolygonShape box;
		box.SetAsBox(1.5f,0.3125f);
		boxDef.shape = &box;
		cart->CreateFixture(&boxDef);
		
		BodyInfo * bi = [[BodyInfo alloc] init];
		bi.name = @"mainbody";
		bi.spriteName = @"truck_body.png";
		cart->SetUserData(bi); 
		
		// Build the liftgate
		box.SetAsBox(0.4, 0.15, b2Vec2(-1.5, 0.3), b2_pi/2);
		boxDef.density = 0.01f;
		boxDef.shape = &box;
		cart->CreateFixture(&boxDef);
		
		
		// Build the cab (change the weight so it does not affect the truck)
		box.SetAsBox(0.4, 0.5, b2Vec2(1.0, 0.7), b2_pi/2);
		boxDef.density = 0.01;
		boxDef.shape = &box;		
		cart->CreateFixture(&boxDef);
		
		// Create the first shock housing
		box.SetAsBox(0.4, 0.15, b2Vec2(-1, -0.3), b2_pi/3);
		boxDef.density = 0.1;  // Make these weigh little
		boxDef.shape = &box;
		cart->CreateFixture(&boxDef);
		
		
		// Create the second shock housing
		box.SetAsBox(0.4, 0.15, b2Vec2(1, -0.3), -b2_pi/3);
		boxDef.shape = &box;
		cart->CreateFixture(&boxDef);
		
		
		// Create the axles
		axle1 = world->CreateBody(&bodyDef);
		
		// add the axles //
		box.SetAsBox(0.5,0.1,b2Vec2(1, -0.3),-b2_pi / 3);
		
		boxDef.density = 10;
		boxDef.shape = &box;
		axle1->CreateFixture(&boxDef);
		
		
		b2PrismaticJointDef prismaticJointDef;
		prismaticJointDef.Initialize(
									 cart,
									 axle1,
									 axle1->GetWorldCenter(),
									 b2Vec2(cos(b2_pi / 3), -sin(b2_pi / 3))
									 );
		prismaticJointDef.lowerTranslation = -0.3;
		prismaticJointDef.upperTranslation = 0.5;
		prismaticJointDef.enableLimit = true;
		prismaticJointDef.enableMotor = true;
		
		spring1 = (b2PrismaticJoint *) world->CreateJoint(&prismaticJointDef);
		
        
		axle2 = world->CreateBody(&bodyDef);
		
		box.SetAsBox(0.5,0.1,b2Vec2(-1, -0.3),b2_pi / 3);
		boxDef.shape = &box;
		axle2->CreateFixture(&boxDef);
		
		prismaticJointDef.Initialize(
									 cart,
									 axle2,
									 axle2->GetWorldCenter(),
									 b2Vec2( -cos(b2_pi / 3), -sin(b2_pi / 3))
									 );
		
		spring2 = (b2PrismaticJoint *) world->CreateJoint(&prismaticJointDef);
		
		
		// add wheels //
		b2FixtureDef circleDef;
		circleDef.density = 10/2;
		circleDef.friction = 5;
		circleDef.restitution = 0.2;
		circleDef.filter.groupIndex = -1;
		
		b2CircleShape circleShape;
		circleShape.m_radius = 0.7;
		circleDef.shape = &circleShape;
		
		int i = 0;
		for (i = 0; i < 2; i++)
		{
			
			b2BodyDef bodyDef;
			bodyDef.type = b2_dynamicBody;
			
			if (i == 0)
			{
				bodyDef.position.Set(
									 axle1->GetWorldCenter().x + (0.3) * cos(b2_pi / 3),
									 axle1->GetWorldCenter().y - (0.3) * sin(b2_pi / 3)
									 );
			}
			else
			{	
				bodyDef.position.Set(
									 axle2->GetWorldCenter().x - (0.3 * cos(b2_pi / 3)),
									 axle2->GetWorldCenter().y - (0.3 * sin(b2_pi / 3))
									 );
			}
			
			bodyDef.allowSleep = false;
			
			if (i == 0) 
			{
				wheel1 = world->CreateBody(&bodyDef);
				BodyInfo * bi = [[BodyInfo alloc] init];
				bi.name = @"wheel1";
				wheel1->SetUserData(bi); 
				circleDef.userData = bi;
				wheel1->CreateFixture(&circleDef);
				
			}
			else
			{
				wheel2 = world->CreateBody(&bodyDef);
				BodyInfo * bi = [[BodyInfo alloc] init];
				bi.name = @"wheel2";
				wheel2->SetUserData(bi);
				circleDef.userData = bi;
				wheel2->CreateFixture(&circleDef);
			}
            
		}
		
		
		// add joints //
		b2RevoluteJointDef revoluteJointDef;
		revoluteJointDef.enableMotor = true;
		
		revoluteJointDef.Initialize(axle1, wheel1, wheel1->GetWorldCenter());
		
		motor1 = (b2RevoluteJoint *) world->CreateJoint(&revoluteJointDef); 
		motor1->SetMotorSpeed(-b2_pi);
		motor1->SetMaxMotorTorque(cart->GetMass()*5);
		
		revoluteJointDef.Initialize(axle2, wheel2, wheel2->GetWorldCenter());
		motor2 = (b2RevoluteJoint *) world->CreateJoint(&revoluteJointDef); 
		motor2->SetMaxMotorTorque(cart->GetMass()*5);
		
		// calculate base spring force from the mass of the cart//
		baseSpringForce = cart->GetMass() * 8.5;
		
	}
	
	return self;
}

-(void)updateVehicle
{
    
	spring1->SetMaxMotorForce(baseSpringForce + (40 * baseSpringForce * pow(spring1->GetJointTranslation(), 2)));
	spring1->SetMotorSpeed(-20 * spring1->GetJointTranslation());
	
	spring2->SetMaxMotorForce(baseSpringForce + (40 * baseSpringForce * pow(spring2->GetJointTranslation(), 2)));
	spring2->SetMotorSpeed(-20 * spring2->GetJointTranslation());
	
	
	motor1->SetMotorSpeed(550*b2_pi * moveDirection);
	motor2->SetMotorSpeed(550*b2_pi * moveDirection);
    
	b2Vec2 linearVelocity = cart->GetLinearVelocity();
	
	//Global *global = [Global instance];
	//global.vehicle_linear_velocity = linearVelocity.x;
    
}

@end
