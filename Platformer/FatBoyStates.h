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

#ifndef FATBOYSTATES_H
#define FATBOYSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class FatBoy;

// -------------------------------------------------------------------------------------

class FatBoyState_Global : public State<FatBoy>, public Singleton<FatBoyState_Global>
{
	friend class Singleton<FatBoyState_Global>;
	
public:
	virtual void Execute(FatBoy* agent);
	virtual bool OnMessage(FatBoy* agent, const Telegram& telegram);
	
private:
	FatBoyState_Global() {}
	FatBoyState_Global(const FatBoyState_Global&);
	virtual ~FatBoyState_Global() {}
	FatBoyState_Global& operator=(const FatBoyState_Global&);
};

// -------------------------------------------------------------------------------------

class FatBoyState_Walk : public State<FatBoy>, public Singleton<FatBoyState_Walk>
{
	friend class Singleton<FatBoyState_Walk>;
	
public:
	virtual void Enter(FatBoy* agent);
	virtual void Execute(FatBoy* agent);
	virtual void Exit(FatBoy* agent);
	
private:
	FatBoyState_Walk() {}
	FatBoyState_Walk(const FatBoyState_Walk&);
	virtual ~FatBoyState_Walk() {}
	FatBoyState_Walk& operator=(const FatBoyState_Walk&);
};

// -------------------------------------------------------------------------------------

class FatBoyState_Fire : public State<FatBoy>, public Singleton<FatBoyState_Fire>
{
	friend class Singleton<FatBoyState_Fire>;
	
public:
	virtual void Enter(FatBoy* agent);
	virtual void Execute(FatBoy* agent);
	virtual void Exit(FatBoy* agent);
	
private:
	FatBoyState_Fire() {}
	FatBoyState_Fire(const FatBoyState_Fire&);
	virtual ~FatBoyState_Fire() {}
	FatBoyState_Fire& operator=(const FatBoyState_Fire&);
};

// -------------------------------------------------------------------------------------

class FatBoyState_Dead : public State<FatBoy>, public Singleton<FatBoyState_Dead>
{
	friend class Singleton<FatBoyState_Dead>;
	
public:
	virtual void Enter(FatBoy* agent);
	virtual void Execute(FatBoy* agent);
	virtual bool OnMessage(FatBoy* agent, const Telegram& telegram);
	
private:
	FatBoyState_Dead() {}
	FatBoyState_Dead(const FatBoyState_Dead&);
	virtual ~FatBoyState_Dead() {}
	FatBoyState_Dead& operator=(const FatBoyState_Dead&);
};

// -------------------------------------------------------------------------------------

class FatBoyState_Drowned : public State<FatBoy>, public Singleton<FatBoyState_Drowned>
{
	friend class Singleton<FatBoyState_Drowned>;
	
public:
	virtual void Enter(FatBoy* agent);
	virtual void Execute(FatBoy* agent);
	virtual bool OnMessage(FatBoy* agent, const Telegram& telegram);
	
private:
	FatBoyState_Drowned() {}
	FatBoyState_Drowned(const FatBoyState_Drowned&);
	virtual ~FatBoyState_Drowned() {}
	FatBoyState_Drowned& operator=(const FatBoyState_Drowned&);
};

// -------------------------------------------------------------------------------------

#endif
