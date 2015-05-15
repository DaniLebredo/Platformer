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

#ifndef FISHSTATES_H
#define FISHSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Fish;

// -------------------------------------------------------------------------------------

class FishState_Global : public State<Fish>, public Singleton<FishState_Global>
{
	friend class Singleton<FishState_Global>;
	
public:
	virtual void Execute(Fish* agent);
	virtual bool OnMessage(Fish* agent, const Telegram& telegram);
	
private:
	FishState_Global() {}
	FishState_Global(const FishState_Global&);
	virtual ~FishState_Global() {}
	FishState_Global& operator=(const FishState_Global&);
};

// -------------------------------------------------------------------------------------

class FishState_Swim : public State<Fish>, public Singleton<FishState_Swim>
{
	friend class Singleton<FishState_Swim>;
	
public:
	virtual void Enter(Fish* agent);
	virtual void Execute(Fish* agent);
	virtual void Exit(Fish* agent);
	virtual bool OnMessage(Fish* agent, const Telegram& telegram);
	
private:
	FishState_Swim() {}
	FishState_Swim(const FishState_Swim&);
	virtual ~FishState_Swim() {}
	FishState_Swim& operator=(const FishState_Swim&);
};

// -------------------------------------------------------------------------------------

class FishState_Fly : public State<Fish>, public Singleton<FishState_Fly>
{
	friend class Singleton<FishState_Fly>;
	
public:
	virtual void Enter(Fish* agent);
	virtual void Execute(Fish* agent);
	virtual void Exit(Fish* agent);
	
private:
	FishState_Fly() {}
	FishState_Fly(const FishState_Fly&);
	virtual ~FishState_Fly() {}
	FishState_Fly& operator=(const FishState_Fly&);
};

// -------------------------------------------------------------------------------------

class FishState_Dead : public State<Fish>, public Singleton<FishState_Dead>
{
	friend class Singleton<FishState_Dead>;
	
public:
	virtual void Enter(Fish* agent);
	virtual void Execute(Fish* agent);
	
private:
	FishState_Dead() {}
	FishState_Dead(const FishState_Dead&);
	virtual ~FishState_Dead() {}
	FishState_Dead& operator=(const FishState_Dead&);
};

// -------------------------------------------------------------------------------------

#endif
