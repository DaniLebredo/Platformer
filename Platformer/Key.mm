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

#import "Key.h"
#import "KeyStates.h"
#import "Stars.h"
#import "LevelController.h"
#import "Game.h"


Key::Key(LevelController* level, CGPoint pos,  NSDictionary* opt) :
	GameObjectFSM<Key>("Key", level, opt),
	mDeltaTime(0)
{
	// --
	
	CCAction* scaleDownAction = [[CCScaleTo alloc] initWithDuration:0.4 scale:0];
	addAction("ScaleDown", scaleDownAction);
	[scaleDownAction release];
	
	// --
	
	CCAction* fadeOutAction = [[CCFadeTo alloc] initWithDuration:0.4 opacity:0];
	addAction("FadeOut", fadeOutAction);
	[fadeOutAction release];
	
	// --

	CCSpriteFrame* initialFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Key0"];
	mNode = [[CCSprite alloc] initWithSpriteFrame:initialFrame];
	mNode.position = pos;
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 128;
	
	mPhyBody = instantiatePhysicsFor("Coin", pos);
	
	State<Key>* startState = CommonState_Init<Key>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(KeyState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Key::~Key()
{
	// CCLOG(@"DEALLOC: Key");
	
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void Key::Collect()
{
	mLevel->MsgDispatcher()->DispatchMsg(ID(), mLevel->PlayerObj()->ID(), Msg_KeyPickedUp, NULL);
	
	SoundManager::Instance()->ScheduleEffect("KeyCollected.caf");
	
	StartAction("ScaleDown");
	StartAction("FadeOut");
	
	Stars* stars = new Stars(mLevel, mNode.position);
	mLevel->AddGameObject(stars);
}

void Key::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
}

void Key::ProcessContacts()
{
	for (int i = 0; i < mContacts.size(); ++i)
	{
		CollisionInfo& colInfo = mContacts[i];
		
		if (colInfo.OtherObject->Class() == "Player")
		{
			FSM()->ChangeState(KeyState_Collected::Instance());
			break;
		}
	}
}
