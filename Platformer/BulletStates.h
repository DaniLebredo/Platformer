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

#ifndef BULLETSTATES_H
#define BULLETSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Bullet;

// -------------------------------------------------------------------------------------

class BulletState_Global : public State<Bullet>, public Singleton<BulletState_Global>
{
	friend class Singleton<BulletState_Global>;
	
public:
	virtual void Execute(Bullet* agent);
	virtual bool OnMessage(Bullet* agent, const Telegram& telegram);
	
private:
	BulletState_Global() {}
	BulletState_Global(const BulletState_Global&);
	virtual ~BulletState_Global() {}
	BulletState_Global& operator=(const BulletState_Global&);
};

// -------------------------------------------------------------------------------------

class BulletState_Flying : public State<Bullet>, public Singleton<BulletState_Flying>
{
	friend class Singleton<BulletState_Flying>;
	
public:
	virtual void Enter(Bullet* agent);
	virtual void Execute(Bullet* agent);
	virtual void Exit(Bullet* agent);
	virtual bool OnMessage(Bullet* agent, const Telegram& telegram);
	
private:
	BulletState_Flying() {}
	BulletState_Flying(const BulletState_Flying&);
	virtual ~BulletState_Flying() {}
	BulletState_Flying& operator=(const BulletState_Flying&);
};

// -------------------------------------------------------------------------------------

class BulletState_HitSomething : public State<Bullet>, public Singleton<BulletState_HitSomething>
{
	friend class Singleton<BulletState_HitSomething>;
	
public:
	virtual void Enter(Bullet* agent);
	virtual void Execute(Bullet* agent);
	
private:
	BulletState_HitSomething() {}
	BulletState_HitSomething(const BulletState_HitSomething&);
	virtual ~BulletState_HitSomething() {}
	BulletState_HitSomething& operator=(const BulletState_HitSomething&);
};

// -------------------------------------------------------------------------------------

#endif
