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

#import "Barrel.h"
#import "BarrelStates.h"
#import "LevelController.h"
#import "Explosion.h"
#import "Game.h"


Barrel::Barrel(LevelController* level, CGPoint pos, NSDictionary* opt) :
	GameObjectFSM<Barrel>("Barrel", level, opt),
	mMovable(false),
	mDeltaTime(0),
	mTimeSinceStartedCounting(0),
	mMinDistance(3.5), mMinDistanceSquared(mMinDistance * mMinDistance)
{
	mOffset = PNGMakePoint(0, -0.5);
	
	if (opt)
	{
		NSString* movable = [opt objectForKey:@"movable"];
		if (movable && [movable isEqualToString:@"true"]) mMovable = true;
	}
	
	NSString* initialFrameName = mMovable ? @"Barrel1" : @"Barrel0";
	CCSpriteFrame* initialFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:initialFrameName];
	mNode = [[CCSprite alloc] initWithSpriteFrame:initialFrame];
	mNode.position = ccpAdd(pos, mOffset);
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 32;
	
	std::string phyTemplateName = mMovable ? "BarrelMovable" : "BarrelStatic";
	mPhyBody = instantiatePhysicsFor(phyTemplateName, pos);

	State<Barrel>* startState = CommonState_Init<Barrel>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(BarrelState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Barrel::~Barrel()
{
	CCLOG(@"DESTROYED: Barrel");
	
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void Barrel::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
}

void Barrel::OnWentOnScreen()
{
	if (!mNode.visible)
		mNode.visible = YES;
}

void Barrel::OnWentOffScreen()
{
	if (mNode.visible)
		mNode.visible = NO;
}


void Barrel::lookForAffectedGameObjs()
{
	for (GameObjList::const_iterator it = mLevel->GameObjMgr()->Begin(); it != mLevel->GameObjMgr()->End(); ++it)
	{
		GameObject* gObj = *it;
		
		if (isGameObjAffected(gObj))
		{
			mLevel->MsgDispatcher()->DispatchMsg(ID(), gObj->ID(), Msg_HitByBarrelExplosion, NULL);
		}
	}
}

bool Barrel::isGameObjAffected(GameObject* gObj)
{
	if (ID() == gObj->ID() || gObj->PhyBody() == NULL) return false;
	
	b2Vec2 offset = gObj->PhyBody()->GetPosition() - mPhyBody->GetPosition();
	return offset.LengthSquared() <= mMinDistanceSquared;
}

void Barrel::Explode()
{
	Explosion* explosion = new Explosion(mLevel, mNode.position);
	mLevel->AddGameObject(explosion);
	
	b2Vec2 deltaPos = mPhyBody->GetPosition() - mLevel->PlayerObj()->PhyBody()->GetPosition();
	SoundManager::Instance()->ScheduleDampenedEffect("Explosion.caf", deltaPos);
	
	lookForAffectedGameObjs();
}
