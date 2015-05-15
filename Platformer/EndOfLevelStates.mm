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

#import "EndOfLevelStates.h"
#import "EndOfLevel.h"

// -------------------------------------------------------------------------------------

template<> State<EndOfLevel>* CommonState_Init<EndOfLevel>::mNextState = EndOfLevelState_PlayerFar::Instance();

// -------------------------------------------------------------------------------------

void EndOfLevelState_Global::Execute(EndOfLevel* agent)
{
}

bool EndOfLevelState_Global::OnMessage(EndOfLevel* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_WentOffScreen:
		{
			if (!agent->FSM()->IsInState(CommonState_OffScreen<EndOfLevel>::Instance()))
			{
				agent->FSM()->ChangeState(CommonState_OffScreen<EndOfLevel>::Instance());
			}
			return true;
		}
			
		default:
		{
			return false;
		}
	}
	
	return false;
}

// -------------------------------------------------------------------------------------

void EndOfLevelState_PlayerFar::Enter(EndOfLevel* agent)
{
	CCLOG(@"EndOfLevel: PLAYER FAR");
	CCSprite* sprite = (CCSprite*)agent->Node();
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Lamp0"];
}

void EndOfLevelState_PlayerFar::Execute(EndOfLevel* agent)
{
	agent->ProcessContacts();
	
	if (agent->IsPlayerNearby())
	{
		agent->FSM()->ChangeState(EndOfLevelState_PlayerClose::Instance());
	}
}

void EndOfLevelState_PlayerFar::Exit(EndOfLevel* agent)
{
}

bool EndOfLevelState_PlayerFar::OnMessage(EndOfLevel* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		default:
		{
			return false;
		}
	}
	
	return false;
}

// -------------------------------------------------------------------------------------

void EndOfLevelState_PlayerClose::Enter(EndOfLevel* agent)
{
	CCLOG(@"EndOfLevel: PLAYER CLOSE");
	CCSprite* sprite = (CCSprite*)agent->Node();
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Lamp1"];
}

void EndOfLevelState_PlayerClose::Execute(EndOfLevel* agent)
{
	agent->ProcessContacts();
	
	if (!agent->IsPlayerNearby())
	{
		agent->FSM()->ChangeState(EndOfLevelState_PlayerFar::Instance());
	}
}

void EndOfLevelState_PlayerClose::Exit(EndOfLevel* agent)
{
}

bool EndOfLevelState_PlayerClose::OnMessage(EndOfLevel* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		default:
		{
			return false;
		}
	}
	
	return false;
}

// -------------------------------------------------------------------------------------

void EndOfLevelState_Found::Enter(EndOfLevel* agent)
{
	CCLOG(@"EndOfLevel: FOUND");
	agent->GotFound();
}

void EndOfLevelState_Found::Execute(EndOfLevel* agent)
{
}

// -------------------------------------------------------------------------------------
