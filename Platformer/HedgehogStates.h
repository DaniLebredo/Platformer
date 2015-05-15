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

#ifndef HEDGEHOGSTATES_H
#define HEDGEHOGSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Hedgehog;

// -------------------------------------------------------------------------------------

class HedgehogState_Global : public State<Hedgehog>, public Singleton<HedgehogState_Global>
{
	friend class Singleton<HedgehogState_Global>;
	
public:
	virtual void Execute(Hedgehog* agent);
	virtual bool OnMessage(Hedgehog* agent, const Telegram& telegram);
	
private:
	HedgehogState_Global() {}
	HedgehogState_Global(const HedgehogState_Global&);
	virtual ~HedgehogState_Global() {}
	HedgehogState_Global& operator=(const HedgehogState_Global&);
};

// -------------------------------------------------------------------------------------

class HedgehogState_Walk : public State<Hedgehog>, public Singleton<HedgehogState_Walk>
{
	friend class Singleton<HedgehogState_Walk>;
	
public:
	virtual void Enter(Hedgehog* agent);
	virtual void Execute(Hedgehog* agent);
	virtual void Exit(Hedgehog* agent);
	
private:
	HedgehogState_Walk() {}
	HedgehogState_Walk(const HedgehogState_Walk&);
	virtual ~HedgehogState_Walk() {}
	HedgehogState_Walk& operator=(const HedgehogState_Walk&);
};

// -------------------------------------------------------------------------------------

class HedgehogState_Think : public State<Hedgehog>, public Singleton<HedgehogState_Think>
{
	friend class Singleton<HedgehogState_Think>;
	
public:
	virtual void Enter(Hedgehog* agent);
	virtual void Execute(Hedgehog* agent);
	virtual void Exit(Hedgehog* agent);
	
private:
	HedgehogState_Think() {}
	HedgehogState_Think(const HedgehogState_Think&);
	virtual ~HedgehogState_Think() {}
	HedgehogState_Think& operator=(const HedgehogState_Think&);
};

// -------------------------------------------------------------------------------------

class HedgehogState_Dead : public State<Hedgehog>, public Singleton<HedgehogState_Dead>
{
	friend class Singleton<HedgehogState_Dead>;
	
public:
	virtual void Enter(Hedgehog* agent);
	virtual void Execute(Hedgehog* agent);
	virtual bool OnMessage(Hedgehog* agent, const Telegram& telegram);
	
private:
	HedgehogState_Dead() {}
	HedgehogState_Dead(const HedgehogState_Dead&);
	virtual ~HedgehogState_Dead() {}
	HedgehogState_Dead& operator=(const HedgehogState_Dead&);
};

// -------------------------------------------------------------------------------------

class HedgehogState_Drowned : public State<Hedgehog>, public Singleton<HedgehogState_Drowned>
{
	friend class Singleton<HedgehogState_Drowned>;
	
public:
	virtual void Enter(Hedgehog* agent);
	virtual void Execute(Hedgehog* agent);
	virtual bool OnMessage(Hedgehog* agent, const Telegram& telegram);
	
private:
	HedgehogState_Drowned() {}
	HedgehogState_Drowned(const HedgehogState_Drowned&);
	virtual ~HedgehogState_Drowned() {}
	HedgehogState_Drowned& operator=(const HedgehogState_Drowned&);
};

// -------------------------------------------------------------------------------------

#endif
