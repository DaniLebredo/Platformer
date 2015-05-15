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

#ifndef BOMBSTATES_H
#define BOMBSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Bomb;

// -------------------------------------------------------------------------------------

class BombState_Global : public State<Bomb>, public Singleton<BombState_Global>
{
	friend class Singleton<BombState_Global>;
	
public:
	virtual void Execute(Bomb* agent);
	virtual bool OnMessage(Bomb* agent, const Telegram& telegram);
	
private:
	BombState_Global() {}
	BombState_Global(const BombState_Global&);
	virtual ~BombState_Global() {}
	BombState_Global& operator=(const BombState_Global&);
};

// -------------------------------------------------------------------------------------

class BombState_Flying : public State<Bomb>, public Singleton<BombState_Flying>
{
	friend class Singleton<BombState_Flying>;
	
public:
	virtual void Enter(Bomb* agent);
	virtual void Execute(Bomb* agent);
	virtual void Exit(Bomb* agent);
	virtual bool OnMessage(Bomb* agent, const Telegram& telegram);
	
private:
	BombState_Flying() {}
	BombState_Flying(const BombState_Flying&);
	virtual ~BombState_Flying() {}
	BombState_Flying& operator=(const BombState_Flying&);
};

// -------------------------------------------------------------------------------------

class BombState_HitSomething : public State<Bomb>, public Singleton<BombState_HitSomething>
{
	friend class Singleton<BombState_HitSomething>;
	
public:
	virtual void Enter(Bomb* agent);
	virtual void Execute(Bomb* agent);
	
private:
	BombState_HitSomething() {}
	BombState_HitSomething(const BombState_HitSomething&);
	virtual ~BombState_HitSomething() {}
	BombState_HitSomething& operator=(const BombState_HitSomething&);
};

// -------------------------------------------------------------------------------------

#endif
