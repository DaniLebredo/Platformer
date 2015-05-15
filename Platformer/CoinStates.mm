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

#import "CoinStates.h"
#import "Coin.h"

// -------------------------------------------------------------------------------------

template<> State<Coin>* CommonState_Init<Coin>::mNextState = CoinState_Normal::Instance();

// -------------------------------------------------------------------------------------

void CoinState_Global::Execute(Coin* agent)
{
}

bool CoinState_Global::OnMessage(Coin* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_WentOnScreen:
		{
			if (!agent->FSM()->IsInState(CoinState_Collected::Instance()))
			{
				agent->OnWentOnScreen();
			}
			return true;
		}
			
		case Msg_WentOffScreen:
		{
			agent->OnWentOffScreen();
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

void CoinState_Normal::Enter(Coin* agent)
{
	CCLOG(@"Coin: NORMAL");
	agent->StartAction("Rotate");
}

void CoinState_Normal::Execute(Coin* agent)
{
	agent->ProcessContacts();
}

void CoinState_Normal::Exit(Coin* agent)
{
	agent->StopAction("Rotate");
}

bool CoinState_Normal::OnMessage(Coin* agent, const Telegram& telegram)
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

void CoinState_Collected::Enter(Coin* agent)
{
	CCLOG(@"Coin: COLLECTED");
	agent->Collect();
}

void CoinState_Collected::Execute(Coin* agent)
{
	agent->PhyBody()->SetActive(false);
	
	if (agent->IsActionDone("FadeOut"))
	{
		agent->SetDestroyed(true);
	}
}

// -------------------------------------------------------------------------------------
