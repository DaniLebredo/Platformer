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

#import "Cannon.h"
#import "CannonStates.h"
#import "Bullet.h"
#import "CannonBall.h"
#import "LevelController.h"
#import "Game.h"


Cannon::Cannon(LevelController* level, CGPoint pos, NSDictionary* opt) :
	GameObjectFSM<Cannon>("Cannon", level, opt),
	mLeft(true),
	mDeltaTime(0),
	mPeriod(1.5),
	mDelay(0),
	mTimeSinceLastShot(0)
{
	mOffset = PNGMakePoint(0, 0);
	
	// ---
	
	int frames[] = { 0, 1, 2, 3 };
	int numFrames = sizeof(frames) / sizeof(int);
	addAction("Default", frames, numFrames, "Cannon", 0.1, false);
	
	// ---
	
	CCSpriteFrame* initialFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Cannon0"];
	mNode = [[CCSprite alloc] initWithSpriteFrame:initialFrame];
	mNode.position = ccpAdd(pos, mOffset);
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 128;
	
	mPhyBody = instantiatePhysicsFor("Cannon", pos);
	
	if (opt)
	{
		NSString* left = [opt objectForKey:@"left"];
		if (left && [left isEqualToString:@"false"])
			mLeft = false;
		
		NSString* period = [opt objectForKey:@"period"];
		if (period)
		{
			mPeriod = [period floatValue];
			CCLOG(@"PERIOD = %f", mPeriod);
		}
		
		NSString* delay = [opt objectForKey:@"delay"];
		if (delay)
		{
			mDelay = [delay floatValue];
			CCLOG(@"DELAY = %f", mDelay);
			mTimeSinceLastShot = mPeriod - mDelay;
		}
	}
	
	SetLeft(mLeft);
	
	State<Cannon>* startState = CommonState_Init<Cannon>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(CannonState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Cannon::~Cannon()
{
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void Cannon::Reload()
{
	mLevel->MsgDispatcher()->DispatchMsg(ID(), ID(), Msg_Activated, NULL);
}

void Cannon::Fire()
{
	CGPoint offset = PNGMakePoint(27, 2);
	if (mLeft) offset.x *= -1;
	
	CGPoint pos = ccpAdd(mNode.position, offset);
	
	//Bullet* bullet = new Bullet(mLevel, pos, mLeft);
	CannonBall* bullet = new CannonBall(mLevel, pos, mLeft, false);
	mLevel->AddGameObject(bullet);
	
	b2Vec2 deltaPos = mPhyBody->GetPosition() - mLevel->PlayerObj()->PhyBody()->GetPosition();
	SoundManager::Instance()->ScheduleDampenedEffect("CannonFire.caf", deltaPos);
}

void Cannon::SetLeft(bool left)
{
	mLeft = left;
	mNode.scaleX = mLeft ? 1 : -1;
}

void Cannon::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
}

void Cannon::OnWentOnScreen()
{
	if (!mNode.visible)
		mNode.visible = YES;
}

void Cannon::OnWentOffScreen()
{
	if (mNode.visible)
		mNode.visible = NO;
}
