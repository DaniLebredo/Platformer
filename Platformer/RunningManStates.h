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

#ifndef RUNNINGMANSTATES_H
#define RUNNINGMANSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class RunningMan;

// -------------------------------------------------------------------------------------

class RunningManState_Global : public State<RunningMan>, public Singleton<RunningManState_Global>
{
	friend class Singleton<RunningManState_Global>;
	
public:
	virtual void Execute(RunningMan* agent);
	virtual bool OnMessage(RunningMan* agent, const Telegram& telegram);
	
private:
	RunningManState_Global() {}
	RunningManState_Global(const RunningManState_Global&);
	virtual ~RunningManState_Global() {}
	RunningManState_Global& operator=(const RunningManState_Global&);
};

// -------------------------------------------------------------------------------------

class RunningManState_Walk : public State<RunningMan>, public Singleton<RunningManState_Walk>
{
	friend class Singleton<RunningManState_Walk>;
	
public:
	virtual void Enter(RunningMan* agent);
	virtual void Execute(RunningMan* agent);
	virtual void Exit(RunningMan* agent);
	
private:
	RunningManState_Walk() {}
	RunningManState_Walk(const RunningManState_Walk&);
	virtual ~RunningManState_Walk() {}
	RunningManState_Walk& operator=(const RunningManState_Walk&);
};

// -------------------------------------------------------------------------------------

class RunningManState_Fire : public State<RunningMan>, public Singleton<RunningManState_Fire>
{
	friend class Singleton<RunningManState_Fire>;
	
public:
	virtual void Enter(RunningMan* agent);
	virtual void Execute(RunningMan* agent);
	virtual void Exit(RunningMan* agent);
	
private:
	RunningManState_Fire() {}
	RunningManState_Fire(const RunningManState_Fire&);
	virtual ~RunningManState_Fire() {}
	RunningManState_Fire& operator=(const RunningManState_Fire&);
};

// -------------------------------------------------------------------------------------

class RunningManState_Dead : public State<RunningMan>, public Singleton<RunningManState_Dead>
{
	friend class Singleton<RunningManState_Dead>;
	
public:
	virtual void Enter(RunningMan* agent);
	virtual void Execute(RunningMan* agent);
	virtual bool OnMessage(RunningMan* agent, const Telegram& telegram);
	
private:
	RunningManState_Dead() {}
	RunningManState_Dead(const RunningManState_Dead&);
	virtual ~RunningManState_Dead() {}
	RunningManState_Dead& operator=(const RunningManState_Dead&);
};

// -------------------------------------------------------------------------------------

class RunningManState_Drowned : public State<RunningMan>, public Singleton<RunningManState_Drowned>
{
	friend class Singleton<RunningManState_Drowned>;
	
public:
	virtual void Enter(RunningMan* agent);
	virtual void Execute(RunningMan* agent);
	virtual bool OnMessage(RunningMan* agent, const Telegram& telegram);
	
private:
	RunningManState_Drowned() {}
	RunningManState_Drowned(const RunningManState_Drowned&);
	virtual ~RunningManState_Drowned() {}
	RunningManState_Drowned& operator=(const RunningManState_Drowned&);
};

// -------------------------------------------------------------------------------------

#endif
