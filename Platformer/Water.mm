/*
 * The MIT License (MIT)
 * 
 * Copyright (c) 2014 Pointy Nose Games
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "Water.h"
#import "WaterStates.h"
#import "Waves1DNode.h"
#import "LevelController.h"
#import "Game.h"


Water::Water(LevelController* level, CGPoint pos, NSDictionary* opt) :
	GameObjectFSM<Water>("Water", level, opt),
	mDeltaTime(0),
	mTimeSinceLastSplash(0),
	mWidth(PNGMakeFloat(26 + 13)),
	mHeight(PNGMakeFloat(26 - 13))
{
	if (opt)
	{
		NSString* width = [opt objectForKey:@"width"];
		if (width) mWidth = PNGMakeFloat([width floatValue] + 13);
		
		NSString* height = [opt objectForKey:@"height"];
		if (height) mHeight = PNGMakeFloat([height floatValue] - 13);
	}
	
	// Update AABB
	mTop = mHeight;
	mRight = mWidth;

	// Visuals
	CGRect bounds = CGRectMake(0, 0, mWidth, mHeight);
	int count = mWidth / PNGMakeFloat(3.25);
	
	mNode = [[Waves1DNode alloc] initWithBounds:bounds count:count damping:0.95 diffusion:0.9];
	mNode.position = ccpSub(pos, PNGMakePoint(0.75 * 26, 0.5 * 26));
	((Waves1DNode*)mNode).color = ccc4f(0.3, 0.3, 0.8, 0.75);
	
	// Physics
	b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set((mNode.position.x + 0.5 * mWidth) / mPtmRatio,
						 (mNode.position.y + mHeight) / mPtmRatio);
	bodyDef.userData = this;
	mPhyBody = mPhyWorld->CreateBody(&bodyDef);
	
	float widthMultiplier = 0.5;
	float heightMultiplier = 0.05;
	b2Vec2 offset = b2Vec2(0, -0.15);
	
	float width = bounds.size.width / mPtmRatio;
	float height = 1;
	
	b2PolygonShape shape;
	shape.SetAsBox(widthMultiplier * width, heightMultiplier * height, offset, 0);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;
	fixtureDef.density = 1;
	fixtureDef.friction = 1;
	fixtureDef.filter.categoryBits = Game::Instance()->Data().Categories("CATEGORY_WATER");
	fixtureDef.filter.maskBits = Game::Instance()->Data().Masks("MASK_ALL");
	
	FixtureUserData* fixUserData = new FixtureUserData(3, false);
	fixtureDef.userData = static_cast<void*>(fixUserData);
	
	mPhyBody->CreateFixture(&fixtureDef);
	
	// States
	State<Water>* startState = CommonState_Init<Water>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(WaterState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Water::~Water()
{
	CCLOG(@"DEALLOC: Water");
	
	if (mPhyBody != NULL)
	{
		FixtureUserData* fixUserData = static_cast<FixtureUserData*>(mPhyBody->GetFixtureList()->GetUserData());
		
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
		
		delete fixUserData;
		fixUserData = NULL;
	}
}

void Water::MakeSplash(float x, float amount)
{
	[((Waves1DNode*)mNode) makeSplashAt:x amount:PNGMakeFloat(amount)];
}

void Water::MakeRandomSplash(float amount, bool randomDirection)
{
	float x = mWidth * rand() / RAND_MAX;
	float sign = randomDirection && (rand() % 2 == 0) ? -1 : 1;
	
	MakeSplash(x, sign * amount);
}

void Water::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
}

void Water::UpdateDraw()
{
}

void Water::UpdateDraw(float t)
{
}

void Water::PreSolve(CollisionInfo* colInfo)
{
	colInfo->Contact->SetEnabled(false);
}

void Water::BeginContact(CollisionInfo* colInfo)
{
	// Every object keeps track of how many water contacts it has.
	colInfo->OtherObject->SetNumWaterContacts(colInfo->OtherObject->NumWaterContacts() + 1);
	mLevel->MsgDispatcher()->DispatchMsg(ID(), colInfo->OtherObject->ID(), Msg_BeginCollisionWithWater, NULL);
	
	// If this is its first water contact, make a splash.
	if (colInfo->OtherObject->NumWaterContacts() == 1)
	{
		b2WorldManifold manifold;
		colInfo->Contact->GetWorldManifold(&manifold);
		
		b2Vec2 contactPoint = manifold.points[0];
		
		if (colInfo->Contact->GetManifold()->pointCount == 2)
		{
			contactPoint += manifold.points[1];
			contactPoint *= 0.5;
		}
		
		float sign = manifold.normal.y > 0 ? -1 : 1;
		float x = contactPoint.x * mPtmRatio - mNode.position.x;
		MakeSplash(x, sign * 5);
		
		// Play a sound.
		
		b2Vec2 deltaPos = contactPoint - mLevel->PlayerObj()->PhyBody()->GetPosition();
		
		SoundManager::Instance()->ScheduleDampenedEffect("WaterSplash.caf", deltaPos);
	}
}

void Water::EndContact(CollisionInfo* colInfo)
{
	colInfo->OtherObject->SetNumWaterContacts(colInfo->OtherObject->NumWaterContacts() - 1);
}

void Water::OnWentOnScreen()
{
	if (!mNode.visible)
		mNode.visible = YES;
}

void Water::OnWentOffScreen()
{
	if (mNode.visible)
		mNode.visible = NO;
}
