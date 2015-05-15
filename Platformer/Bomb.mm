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

#import "Bomb.h"
#import "BombStates.h"
#import "Explosion.h"
#import "LevelController.h"
#import "Game.h"


Bomb::Bomb(LevelController* level, CGPoint pos, const b2Vec2& initialVelocity) :
	GameObjectFSM<Bomb>("Bomb", level),
	mDeltaTime(0), mTimeSinceExploded(0),
	mMinDistance(2.5), mMinDistanceSquared(mMinDistance * mMinDistance)
{
	// ---
	
	CCAction* pulsateAction = [[CCRepeatForever alloc] initWithAction:
							   [CCSequence actions:
								[CCTintTo actionWithDuration:0.125 red:255 green:0 blue:0],
								[CCTintTo actionWithDuration:0.125 red:255 green:255 blue:255],
								nil]];
	addAction("Pulsate", pulsateAction);
	[pulsateAction release];
	
	// ---
	
	mNode = [[CCSprite alloc] initWithFile:@"Bomb.png"];
	mNode.position = pos;
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 255;
	
	// ---
	
	mPhyBody = instantiatePhysicsFor("Bomb", pos);
	
	ApplyCorrectiveImpulse(mPhyBody, initialVelocity);
	
	State<Bomb>* startState = CommonState_Init<Bomb>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(BombState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Bomb::~Bomb()
{
	// CCLOG(@"DEALLOC: Bomb");
	
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void Bomb::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
}

void Bomb::lookForAffectedGameObjs()
{
	for (GameObjList::const_iterator it = mLevel->GameObjMgr()->Begin(); it != mLevel->GameObjMgr()->End(); ++it)
	{
		GameObject* gObj = *it;
		
		if (isGameObjAffected(gObj))
		{
			mLevel->MsgDispatcher()->DispatchMsg(ID(), gObj->ID(), Msg_HitByBomb, NULL);
		}
	}
}

bool Bomb::isGameObjAffected(GameObject* gObj)
{
	if (ID() == gObj->ID() || gObj->PhyBody() == NULL) return false;
	
	b2Vec2 offset = gObj->PhyBody()->GetPosition() - mPhyBody->GetPosition();
	return offset.LengthSquared() <= mMinDistanceSquared;
}

void Bomb::Explode()
{
	MakeBodyNotCollidable(mPhyBody);
	
	mNode.visible = NO;
	
	Explosion* explosion = new Explosion(mLevel, mNode.position);
	mLevel->AddGameObject(explosion);
	
	b2Vec2 deltaPos = mPhyBody->GetPosition() - mLevel->PlayerObj()->PhyBody()->GetPosition();
	SoundManager::Instance()->ScheduleDampenedEffect("Explosion.caf", deltaPos);
	
	lookForAffectedGameObjs();
}

void Bomb::ProcessContacts()
{
	for (int i = 0; i < mContacts.size(); ++i)
	{
		CollisionInfo& colInfo = mContacts[i];
		
		// Hit just the first contact.
		mLevel->MsgDispatcher()->DispatchMsg(ID(), colInfo.OtherObject->ID(), Msg_HitByBomb, NULL);
		FSM()->ChangeState(BombState_HitSomething::Instance());
		break;
	}
}

void Bomb::PreSolve(CollisionInfo* colInfo)
{
	colInfo->Contact->SetEnabled(false);
}
