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

#import "Door.h"
#import "DoorStates.h"
#import "PlayerNormal.h"
#import "LevelController.h"
#import "Game.h"


Door::Door(LevelController* level, CGPoint pos,  NSDictionary* opt) :
	GameObjectFSM<Door>("Door", level, opt),
	mDeltaTime(0)
{
	mOffset = PNGMakePoint(0, 13);
	
	// --
	
	int frames[] = { 0, 1, 2, 3, 4, 5 };
	int numFrames = sizeof(frames) / sizeof(int);
	addAction("Open", frames, numFrames, "Door", 0.05, false);
	
	// --
	
	CCSpriteFrame* initialFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Door0"];
	mNode = [[CCSprite alloc] initWithSpriteFrame:initialFrame];
	mNode.position = ccpAdd(pos, mOffset);
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 128;
	
	mPhyBody = instantiatePhysicsFor("Door", pos);
	
	State<Door>* startState = CommonState_Init<Door>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(DoorState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Door::~Door()
{
	// CCLOG(@"DEALLOC: Door");
	
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void Door::Open()
{
	mLevel->MsgDispatcher()->DispatchMsg(ID(), mLevel->PlayerObj()->ID(), Msg_DoorOpened, NULL);
	
	b2Vec2 deltaPos = mPhyBody->GetPosition() - mLevel->PlayerObj()->PhyBody()->GetPosition();
	SoundManager::Instance()->ScheduleDampenedEffect("Door.caf", deltaPos);
	
	StartAction("Open");
}

void Door::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
}

void Door::ProcessContacts()
{
	for (int i = 0; i < mContacts.size(); ++i)
	{
		CollisionInfo& colInfo = mContacts[i];
		
		if (colInfo.OtherObject->Class() == "Player")
		{
			PlayerNormal* player = static_cast<PlayerNormal*>(colInfo.OtherObject);
			
			if (player->NumKeys() > 0)
			{
				mLevel->MsgDispatcher()->DispatchMsg(ID(), mLevel->PlayerObj()->ID(), Msg_KeyLost, NULL);
				mLevel->MsgDispatcher()->DispatchMsg(ID(), ID(), Msg_Activated, NULL);
				break;
			}
		}
	}
}

void Door::OnWentOnScreen()
{
	if (!mNode.visible)
		mNode.visible = YES;
}

void Door::OnWentOffScreen()
{
	if (mNode.visible)
		mNode.visible = NO;
}
