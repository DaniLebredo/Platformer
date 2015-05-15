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
 
#import "EndOfLevel.h"
#import "EndOfLevelStates.h"
#import "PlayerNormal.h"
#import "PlayerGravity.h"
#import "LevelController.h"
#import "Game.h"


EndOfLevel::EndOfLevel(LevelController* level, CGPoint pos) :
	GameObjectFSM<EndOfLevel>("EndOfLevel", level),
	mIndex(0),
	mMinDistance(5), mMinDistanceSquared(mMinDistance * mMinDistance)
{
	// --
	
	mOffset = PNGMakePoint(0, 30);
	
	// --
	
	CCSpriteFrame* initialFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Lamp0"];
	mNode = [[CCSprite alloc] initWithSpriteFrame:initialFrame];
	mNode.position = ccpAdd(pos, mOffset);
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 128;
	
	mPhyBody = instantiatePhysicsFor("EndOfLevel", pos);
	
	State<EndOfLevel>* startState = CommonState_Init<EndOfLevel>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(EndOfLevelState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

EndOfLevel::~EndOfLevel()
{
	//CCLOG(@"DEALLOC: EndOfLevel");
	
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

bool EndOfLevel::IsPlayerNearby()
{
	b2Vec2 offset = mLevel->PlayerObj()->PhyBody()->GetPosition() - mPhyBody->GetPosition();
	return offset.LengthSquared() <= mMinDistanceSquared;
}

void EndOfLevel::GotFound()
{
	SoundManager::Instance()->ScheduleEffect("EndOfLevel.caf");
	
	Telegram telegram(ID_IRRELEVANT, ID_IRRELEVANT, Msg_LevelComplete, NULL);
	mLevel->HandleMessage(telegram);
}

void EndOfLevel::ProcessContacts()
{
	for (int i = 0; i < mContacts.size(); ++i)
	{
		CollisionInfo& colInfo = mContacts[i];
		
		if (colInfo.OtherObject->Class() == "Player")
		{
			if (mLevel->NumLivesLeft() > 0)
			{
				FSM()->ChangeState(EndOfLevelState_Found::Instance());
				break;
			}
		}
	}
}
