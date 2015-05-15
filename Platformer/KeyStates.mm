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

#import "KeyStates.h"
#import "Key.h"

// -------------------------------------------------------------------------------------

template<> State<Key>* CommonState_Init<Key>::mNextState = KeyState_Normal::Instance();

// -------------------------------------------------------------------------------------

void KeyState_Global::Execute(Key* agent)
{
	agent->ProcessContacts();
}

bool KeyState_Global::OnMessage(Key* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_WentOffScreen:
		{
			if (!agent->FSM()->IsInState(KeyState_Collected::Instance()) &&
				!agent->FSM()->IsInState(CommonState_OffScreen<Key>::Instance()))
			{
				agent->FSM()->ChangeState(CommonState_OffScreen<Key>::Instance());
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

void KeyState_Normal::Enter(Key* agent)
{
	CCLOG(@"Key: NORMAL");
}

void KeyState_Normal::Execute(Key* agent)
{
}

bool KeyState_Normal::OnMessage(Key* agent, const Telegram& telegram)
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

void KeyState_Collected::Enter(Key* agent)
{
	CCLOG(@"Key: COLLECTED");
	agent->Collect();
}

void KeyState_Collected::Execute(Key* agent)
{
	agent->PhyBody()->SetActive(false);
	
	if (agent->IsActionDone("FadeOut"))
	{
		agent->SetDestroyed(true);
	}
}

// -------------------------------------------------------------------------------------
