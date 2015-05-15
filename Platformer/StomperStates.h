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

#ifndef STOMPERSTATES_H
#define STOMPERSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Stomper;

// -------------------------------------------------------------------------------------

class StomperState_Global : public State<Stomper>, public Singleton<StomperState_Global>
{
	friend class Singleton<StomperState_Global>;
	
public:
	virtual void Execute(Stomper* agent);
	virtual bool OnMessage(Stomper* agent, const Telegram& telegram);
	
private:
	StomperState_Global() {}
	StomperState_Global(const StomperState_Global&);
	virtual ~StomperState_Global() {}
	StomperState_Global& operator=(const StomperState_Global&);
};

// -------------------------------------------------------------------------------------

class StomperState_FallingDown : public State<Stomper>, public Singleton<StomperState_FallingDown>
{
	friend class Singleton<StomperState_FallingDown>;
	
public:
	virtual void Enter(Stomper* agent);
	virtual void Execute(Stomper* agent);
	
private:
	StomperState_FallingDown() {}
	StomperState_FallingDown(const StomperState_FallingDown&);
	virtual ~StomperState_FallingDown() {}
	StomperState_FallingDown& operator=(const StomperState_FallingDown&);
};

// -------------------------------------------------------------------------------------

class StomperState_RisingUp : public State<Stomper>, public Singleton<StomperState_RisingUp>
{
	friend class Singleton<StomperState_RisingUp>;
	
public:
	virtual void Enter(Stomper* agent);
	virtual void Execute(Stomper* agent);
	
private:
	StomperState_RisingUp() {}
	StomperState_RisingUp(const StomperState_RisingUp&);
	virtual ~StomperState_RisingUp() {}
	StomperState_RisingUp& operator=(const StomperState_RisingUp&);
};

// -------------------------------------------------------------------------------------

class StomperState_Waiting : public State<Stomper>, public Singleton<StomperState_Waiting>
{
	friend class Singleton<StomperState_Waiting>;
	
public:
	virtual void Enter(Stomper* agent);
	virtual void Execute(Stomper* agent);
	
private:
	StomperState_Waiting() {}
	StomperState_Waiting(const StomperState_Waiting&);
	virtual ~StomperState_Waiting() {}
	StomperState_Waiting& operator=(const StomperState_Waiting&);
};

// -------------------------------------------------------------------------------------

#endif
