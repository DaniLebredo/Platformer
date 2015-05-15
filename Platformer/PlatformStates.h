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

#ifndef PLATFORMSTATES_H
#define PLATFORMSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Platform;

// -------------------------------------------------------------------------------------

class PlatformState_Global : public State<Platform>, public Singleton<PlatformState_Global>
{
	friend class Singleton<PlatformState_Global>;
	
public:
	virtual void Execute(Platform* agent);
	virtual bool OnMessage(Platform* agent, const Telegram& telegram);
	
private:
	PlatformState_Global() {}
	PlatformState_Global(const PlatformState_Global&);
	virtual ~PlatformState_Global() {}
	PlatformState_Global& operator=(const PlatformState_Global&);
};

// -------------------------------------------------------------------------------------

class PlatformState_Inactive : public State<Platform>, public Singleton<PlatformState_Inactive>
{
	friend class Singleton<PlatformState_Inactive>;
	
public:
	virtual void Enter(Platform* agent);
	virtual void Execute(Platform* agent);
	virtual bool OnMessage(Platform* agent, const Telegram& telegram);
	
private:
	PlatformState_Inactive() {}
	PlatformState_Inactive(const PlatformState_Inactive&);
	virtual ~PlatformState_Inactive() {}
	PlatformState_Inactive& operator=(const PlatformState_Inactive&);
};

// -------------------------------------------------------------------------------------

class PlatformState_Moving : public State<Platform>, public Singleton<PlatformState_Moving>
{
	friend class Singleton<PlatformState_Moving>;
	
public:
	virtual void Enter(Platform* agent);
	virtual void Execute(Platform* agent);
	
private:
	PlatformState_Moving() {}
	PlatformState_Moving(const PlatformState_Moving&);
	virtual ~PlatformState_Moving() {}
	PlatformState_Moving& operator=(const PlatformState_Moving&);
};

// -------------------------------------------------------------------------------------

class PlatformState_Stop : public State<Platform>, public Singleton<PlatformState_Stop>
{
	friend class Singleton<PlatformState_Stop>;
	
public:
	virtual void Enter(Platform* agent);
	virtual void Execute(Platform* agent);
	virtual void Exit(Platform* agent);
	
private:
	PlatformState_Stop() {}
	PlatformState_Stop(const PlatformState_Stop&);
	virtual ~PlatformState_Stop() {}
	PlatformState_Stop& operator=(const PlatformState_Stop&);
};

// -------------------------------------------------------------------------------------

#endif
