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

#ifndef SIGNSTATES_H
#define SIGNSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Sign;

// -------------------------------------------------------------------------------------

class SignState_Global : public State<Sign>, public Singleton<SignState_Global>
{
	friend class Singleton<SignState_Global>;
	
public:
	virtual void Execute(Sign* agent);
	virtual bool OnMessage(Sign* agent, const Telegram& telegram);
	
private:
	SignState_Global() {}
	SignState_Global(const SignState_Global&);
	virtual ~SignState_Global() {}
	SignState_Global& operator=(const SignState_Global&);
};

// -------------------------------------------------------------------------------------

class SignState_Hidden : public State<Sign>, public Singleton<SignState_Hidden>
{
	friend class Singleton<SignState_Hidden>;
	
public:
	virtual void Enter(Sign* agent);
	virtual void Execute(Sign* agent);
	virtual void Exit(Sign* agent);
	
private:
	SignState_Hidden() {}
	SignState_Hidden(const SignState_Hidden&);
	virtual ~SignState_Hidden() {}
	SignState_Hidden& operator=(const SignState_Hidden&);
};

// -------------------------------------------------------------------------------------

class SignState_Visible : public State<Sign>, public Singleton<SignState_Visible>
{
	friend class Singleton<SignState_Visible>;
	
public:
	virtual void Enter(Sign* agent);
	virtual void Execute(Sign* agent);
	virtual void Exit(Sign* agent);
	
private:
	SignState_Visible() {}
	SignState_Visible(const SignState_Visible&);
	virtual ~SignState_Visible() {}
	SignState_Visible& operator=(const SignState_Visible&);
};

// -------------------------------------------------------------------------------------

#endif
