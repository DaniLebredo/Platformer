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

#import "CrackedTileStates.h"
#import "CrackedTile.h"

// -------------------------------------------------------------------------------------

template<> State<CrackedTile>* CommonState_Init<CrackedTile>::mNextState = CrackedTileState_Normal::Instance();

// -------------------------------------------------------------------------------------

void CrackedTileState_Global::Execute(CrackedTile* agent)
{
}

bool CrackedTileState_Global::OnMessage(CrackedTile* agent, const Telegram& telegram)
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

void CrackedTileState_Normal::Enter(CrackedTile* agent)
{
	CCLOG(@"CrackedTile: NORMAL");
}

void CrackedTileState_Normal::Execute(CrackedTile* agent)
{
	if (agent->HitCount() >= 3)
		agent->FSM()->ChangeState(CrackedTileState_Destroyed::Instance());
}

bool CrackedTileState_Normal::OnMessage(CrackedTile* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_WentOnScreen:
		{
			agent->OnWentOnScreen();
			return true;
		}
		
		case Msg_WentOffScreen:
		{
			agent->OnWentOffScreen();
			return true;
		}
		
		case Msg_HitByBullet:
		case Msg_HitByBomb:
		case Msg_HitByBarrelExplosion:
		{
			agent->IncreaseHitCount();
			return true;
		}
			break;
			
		default:
		{
			return false;
		}
			break;
	}
	
	return false;
}

// -------------------------------------------------------------------------------------

void CrackedTileState_Destroyed::Enter(CrackedTile* agent)
{
	CCLOG(@"CrackedTile: DESTROYED");
	agent->StartAction("Default");
}

void CrackedTileState_Destroyed::Execute(CrackedTile* agent)
{
	agent->PhyBody()->SetActive(false);
	
	if (agent->IsActionDone("Default"))
	{
		agent->SetDestroyed(true);
	}
}

// -------------------------------------------------------------------------------------
