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

#import "Flyer.h"
#import "FlyerStates.h"
#import "Ghost.h"
#import "LevelController.h"
#import "Game.h"


Flyer::Flyer(LevelController* level, CGPoint pos, NSDictionary* opt) :
	GameObjectFSM<Flyer>("Flyer", level, opt),
	mNumDeadlyContacts(0),
	mDeltaTime(0)
{
	// ---
	
	mIsEnemy = true;
	
	// ---
	
	int flyFrames[] = { 0, 1, 2, 3, 3, 2, 1, 0 };
	int flyNumFrames = sizeof(flyFrames) / sizeof(int);
	addAction("Fly", flyFrames, flyNumFrames, "Flyer", 0.04, true);
	
	// ---
	
	CCAction* fadeOutAction = [[CCFadeOut alloc] initWithDuration:0.5];
	addAction("Die", fadeOutAction);
	[fadeOutAction release];
	
	// ---
	
	CCSpriteFrame* initialFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Flyer0"];
	mNode = [[CCSprite alloc] initWithSpriteFrame:initialFrame];
	mNode.position = pos;
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 128;
	
	mPhyBody = instantiatePhysicsFor("Flyer", pos);
	
	State<Flyer>* startState = CommonState_Init<Flyer>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(FlyerState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Flyer::~Flyer()
{
	CCLOG(@"DEALLOC: Flyer");
	
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void Flyer::Fly()
{
	ApplyCorrectiveImpulse(mPhyBody, b2Vec2(-3, 0));
}

void Flyer::Die()
{
	CCSprite* sprite = (CCSprite*)mNode;
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Flyer4"];
	
	StartAction("Die");
	
	b2Vec2 deltaPos = mPhyBody->GetPosition() - mLevel->PlayerObj()->PhyBody()->GetPosition();
	SoundManager::Instance()->ScheduleDampenedEffect("EnemyKilled.caf", deltaPos);
	
	Ghost* ghost = new Ghost(mLevel, ccpAdd(mNode.position, PNGMakePoint(0, 15)));
	mLevel->AddGameObject(ghost);
}

void Flyer::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
}

void Flyer::ProcessContacts()
{
	mNumDeadlyContacts = 0;
	
	for (int i = 0; i < mContacts.size(); ++i)
	{
		CollisionInfo& colInfo = mContacts[i];
		
		if (colInfo.OtherFixUserData->KillsEnemy)
		{
			++mNumDeadlyContacts;
		}
	}
}
