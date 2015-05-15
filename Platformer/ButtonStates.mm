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

#import "ButtonStates.h"
#import "Button.h"

// -------------------------------------------------------------------------------------

template<> State<Button>* CommonState_Init<Button>::mNextState = ButtonState_Normal::Instance();

// -------------------------------------------------------------------------------------

void ButtonState_Global::Execute(Button* agent)
{
}

// -------------------------------------------------------------------------------------

void ButtonState_Normal::Enter(Button* agent)
{
	CCLOG(@"Button: NORMAL");
}

void ButtonState_Normal::Execute(Button* agent)
{
	agent->ProcessContacts();
}

bool ButtonState_Normal::OnMessage(Button* agent, const Telegram& telegram)
{
	switch(telegram.Msg)
	{
		case Msg_HitByBullet:
		case Msg_HitByBomb:
		{
			agent->FSM()->ChangeState(ButtonState_Pushed::Instance());
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

void ButtonState_Pushed::Enter(Button* agent)
{
	CCLOG(@"Button: PUSHED");
	agent->Push();
}

void ButtonState_Pushed::Execute(Button* agent)
{
}

// -------------------------------------------------------------------------------------
