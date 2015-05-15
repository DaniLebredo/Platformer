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

#ifndef COMMONSTATES_H
#define COMMONSTATES_H

#import "State.h"
#import "Singleton.h"
#import "Telegram.h"

// -------------------------------------------------------------------------------------

template <typename T>
class CommonState_Init : public State<T>, public Singleton<CommonState_Init<T> >
{
	friend class Singleton<CommonState_Init<T> >;
	
public:
	virtual bool OnMessage(T* agent, const Telegram& telegram)
	{
		switch(telegram.Msg)
		{
			case Msg_GameObjAddedToScene:
			{
				agent->FSM()->ChangeState(mNextState);
				return true;
			}
				
			default:
			{
				return false;
			}
		}
		
		return false;
	}
	
private:
	CommonState_Init() {}
	CommonState_Init(const CommonState_Init<T>&);
	virtual ~CommonState_Init() {}
	CommonState_Init<T>& operator=(const CommonState_Init<T>&);
	
	static State<T>* mNextState;
};

// -------------------------------------------------------------------------------------

template <typename T>
class CommonState_OffScreen : public State<T>, public Singleton<CommonState_OffScreen<T> >
{
	friend class Singleton<CommonState_OffScreen<T> >;
	
public:
	virtual void Enter(T* agent)
	{
		agent->OnWentOffScreen();
	}
	
	virtual void Exit(T* agent)
	{
		agent->OnWentOnScreen();
	}
	
	virtual bool OnMessage(T* agent, const Telegram& telegram)
	{
		switch(telegram.Msg)
		{
			case Msg_WentOnScreen:
			{
				agent->FSM()->RevertToPreviousState();
				return true;
			}
				
			default:
			{
				return false;
			}
		}
		
		return false;
	}
	
private:
	CommonState_OffScreen() {}
	CommonState_OffScreen(const CommonState_OffScreen<T>&);
	virtual ~CommonState_OffScreen() {}
	CommonState_OffScreen<T>& operator=(const CommonState_OffScreen<T>&);
};

// -------------------------------------------------------------------------------------

#endif
