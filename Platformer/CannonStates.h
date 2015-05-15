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

#ifndef CANNONSTATES_H
#define CANNONSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Cannon;

// -------------------------------------------------------------------------------------

class CannonState_Global : public State<Cannon>, public Singleton<CannonState_Global>
{
	friend class Singleton<CannonState_Global>;
	
public:
	virtual void Execute(Cannon* agent);
	virtual bool OnMessage(Cannon* agent, const Telegram& telegram);
	
private:
	CannonState_Global() {}
	CannonState_Global(const CannonState_Global&);
	virtual ~CannonState_Global() {}
	CannonState_Global& operator=(const CannonState_Global&);
};

// -------------------------------------------------------------------------------------

class CannonState_Wait : public State<Cannon>, public Singleton<CannonState_Wait>
{
	friend class Singleton<CannonState_Wait>;
	
public:
	virtual void Enter(Cannon* agent);
	virtual void Execute(Cannon* agent);
	virtual bool OnMessage(Cannon* agent, const Telegram& telegram);
	
private:
	CannonState_Wait() {}
	CannonState_Wait(const CannonState_Wait&);
	virtual ~CannonState_Wait() {}
	CannonState_Wait& operator=(const CannonState_Wait&);
};

// -------------------------------------------------------------------------------------

class CannonState_Reload : public State<Cannon>, public Singleton<CannonState_Reload>
{
	friend class Singleton<CannonState_Reload>;
	
public:
	virtual void Enter(Cannon* agent);
	virtual void Execute(Cannon* agent);
	virtual void Exit(Cannon* agent);
	
private:
	CannonState_Reload() {}
	CannonState_Reload(const CannonState_Reload&);
	virtual ~CannonState_Reload() {}
	CannonState_Reload& operator=(const CannonState_Reload&);
};

// -------------------------------------------------------------------------------------

class CannonState_Fire : public State<Cannon>, public Singleton<CannonState_Fire>
{
	friend class Singleton<CannonState_Fire>;
	
public:
	virtual void Enter(Cannon* agent);
	virtual void Execute(Cannon* agent);
	
private:
	CannonState_Fire() {}
	CannonState_Fire(const CannonState_Fire&);
	virtual ~CannonState_Fire() {}
	CannonState_Fire& operator=(const CannonState_Fire&);
};

// -------------------------------------------------------------------------------------

#endif
