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

#import "Button.h"
#import "ButtonStates.h"
#import "LevelController.h"
#import "Game.h"


Button::Button(LevelController* level, CGPoint pos, NSDictionary* opt) :
	GameObjectFSM<Button>("Button", level, opt)
{
	// --
	
	mOffset = PNGMakePoint(0, 0);
	
	// --
	
	CCSpriteFrame* initialFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Switch0"];
	mNode = [[CCSprite alloc] initWithSpriteFrame:initialFrame];
	mNode.position = ccpAdd(pos, mOffset);
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 128;
	
	mPhyBody = instantiatePhysicsFor("Button", pos);
	
	if (opt)
	{
		NSString* targetId = [opt objectForKey:@"targetId"];
		if (targetId) mTargetId = std::string(targetId.UTF8String);
	}
	
	State<Button>* startState = CommonState_Init<Button>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(ButtonState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Button::~Button()
{
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void Button::Push()
{
	SoundManager::Instance()->ScheduleEffect("Switch.caf");
	
	CCSprite* sprite = (CCSprite*)mNode;
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Switch1"];
	
	GameObject* targetGameObj = mLevel->GameObjMgr()->GetGameObjectByTag(mTargetId);
	if (targetGameObj) mLevel->MsgDispatcher()->DispatchMsg(ID(), targetGameObj->ID(), Msg_Activated, NULL);
}

void Button::Update(ccTime dt)
{
	GameObjectFSM::Update(dt);
}

void Button::ProcessContacts()
{
	for (int i = 0; i < mContacts.size(); ++i)
	{
		CollisionInfo& colInfo = mContacts[i];
		
		if (colInfo.OtherObject->Class() == "Player")
		{
			FSM()->ChangeState(ButtonState_Pushed::Instance());
			break;
		}
	}
}
