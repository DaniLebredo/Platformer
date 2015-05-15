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

#ifndef SPIDERSTATES_H
#define SPIDERSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Spider;

// -------------------------------------------------------------------------------------

class SpiderState_Global : public State<Spider>, public Singleton<SpiderState_Global>
{
	friend class Singleton<SpiderState_Global>;
	
public:
	virtual void Execute(Spider* agent);
	virtual bool OnMessage(Spider* agent, const Telegram& telegram);
	
private:
	SpiderState_Global() {}
	SpiderState_Global(const SpiderState_Global&);
	virtual ~SpiderState_Global() {}
	SpiderState_Global& operator=(const SpiderState_Global&);
};

// -------------------------------------------------------------------------------------

class SpiderState_Walk : public State<Spider>, public Singleton<SpiderState_Walk>
{
	friend class Singleton<SpiderState_Walk>;
	
public:
	virtual void Enter(Spider* agent);
	virtual void Execute(Spider* agent);
	virtual void Exit(Spider* agent);
	
private:
	SpiderState_Walk() {}
	SpiderState_Walk(const SpiderState_Walk&);
	virtual ~SpiderState_Walk() {}
	SpiderState_Walk& operator=(const SpiderState_Walk&);
};

// -------------------------------------------------------------------------------------

class SpiderState_Attack : public State<Spider>, public Singleton<SpiderState_Attack>
{
	friend class Singleton<SpiderState_Attack>;
	
public:
	virtual void Enter(Spider* agent);
	virtual void Execute(Spider* agent);
	virtual void Exit(Spider* agent);
	
private:
	SpiderState_Attack() {}
	SpiderState_Attack(const SpiderState_Attack&);
	virtual ~SpiderState_Attack() {}
	SpiderState_Attack& operator=(const SpiderState_Attack&);
};

// -------------------------------------------------------------------------------------

class SpiderState_Dead : public State<Spider>, public Singleton<SpiderState_Dead>
{
	friend class Singleton<SpiderState_Dead>;
	
public:
	virtual void Enter(Spider* agent);
	virtual void Execute(Spider* agent);
	virtual bool OnMessage(Spider* agent, const Telegram& telegram);
	
private:
	SpiderState_Dead() {}
	SpiderState_Dead(const SpiderState_Dead&);
	virtual ~SpiderState_Dead() {}
	SpiderState_Dead& operator=(const SpiderState_Dead&);
};

// -------------------------------------------------------------------------------------

class SpiderState_Drowned : public State<Spider>, public Singleton<SpiderState_Drowned>
{
	friend class Singleton<SpiderState_Drowned>;
	
public:
	virtual void Enter(Spider* agent);
	virtual void Execute(Spider* agent);
	virtual bool OnMessage(Spider* agent, const Telegram& telegram);
	
private:
	SpiderState_Drowned() {}
	SpiderState_Drowned(const SpiderState_Drowned&);
	virtual ~SpiderState_Drowned() {}
	SpiderState_Drowned& operator=(const SpiderState_Drowned&);
};

// -------------------------------------------------------------------------------------

#endif
