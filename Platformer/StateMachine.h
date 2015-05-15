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

#ifndef STATEMACHINE_H
#define STATEMACHINE_H

#import <string>
#import "State.h"
#import "Telegram.h"


template <typename T>
class StateMachine
{
private:
	T* mOwner;
	
	State<T>* mCurrentState;
	State<T>* mPreviousState;
	State<T>* mNextState;
	State<T>* mGlobalState;
	
public:
	StateMachine(T* owner) :
		mOwner(owner), mCurrentState(NULL), mPreviousState(NULL), mNextState(NULL), mGlobalState(NULL) {}
	virtual ~StateMachine() {}
	
	void SetCurrentState(State<T>* s) { mCurrentState = s; }
	void SetGlobalState(State<T>* s) { mGlobalState = s; }
	void SetPreviousState(State<T>* s) { mPreviousState = s; }
	
	State<T>* CurrentState() const { return mCurrentState; }
	State<T>* GlobalState() const { return mGlobalState; }
	State<T>* PreviousState() const { return mPreviousState; }
	
	void Update() const;
	bool HandleMessage(const Telegram& telegram) const;
	void ChangeState(State<T>* newState);
	void RevertToPreviousState();
	bool IsInState(const State<T>* state) const;
	bool WasInState(const State<T>* state) const;
	bool WillBeInState(const State<T>* state) const;
};

template <typename T>
void StateMachine<T>::Update()const
{
	if (mGlobalState) mGlobalState->Execute(mOwner);
	if (mCurrentState) mCurrentState->Execute(mOwner);
}

template <typename T>
bool StateMachine<T>::HandleMessage(const Telegram& msg) const
{
	if (mCurrentState && mCurrentState->OnMessage(mOwner, msg)) return true;
	else if (mGlobalState && mGlobalState->OnMessage(mOwner, msg)) return true;
	else return false;
}

template <typename T>
void StateMachine<T>::ChangeState(State<T>* newState)
{
	assert(newState && "<StateMachine::ChangeState>:newState is NULL");
	
	mNextState = newState;
	
	mCurrentState->Exit(mOwner);
	
	mPreviousState = mCurrentState;
	mCurrentState = mNextState;
	mNextState = NULL;
	
	mCurrentState->Enter(mOwner);
}

template <typename T>
void StateMachine<T>::RevertToPreviousState()
{
	ChangeState(mPreviousState);
}

template <typename T>
bool StateMachine<T>::IsInState(const State<T>* state)const
{
	return typeid(*mCurrentState) == typeid(*state);
}

template <typename T>
bool StateMachine<T>::WasInState(const State<T>* state)const
{
	return typeid(*mPreviousState) == typeid(*state);
}

template <typename T>
bool StateMachine<T>::WillBeInState(const State<T>* state)const
{
	return typeid(*mNextState) == typeid(*state);
}

#endif
