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

#ifndef CANNONBALLSTATES_H
#define CANNONBALLSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class CannonBall;

// -------------------------------------------------------------------------------------

class CannonBallState_Global : public State<CannonBall>, public Singleton<CannonBallState_Global>
{
	friend class Singleton<CannonBallState_Global>;
	
public:
	virtual void Execute(CannonBall* agent);
	virtual bool OnMessage(CannonBall* agent, const Telegram& telegram);
	
private:
	CannonBallState_Global() {}
	CannonBallState_Global(const CannonBallState_Global&);
	virtual ~CannonBallState_Global() {}
	CannonBallState_Global& operator=(const CannonBallState_Global&);
};

// -------------------------------------------------------------------------------------

class CannonBallState_Flying : public State<CannonBall>, public Singleton<CannonBallState_Flying>
{
	friend class Singleton<CannonBallState_Flying>;
	
public:
	virtual void Enter(CannonBall* agent);
	virtual void Execute(CannonBall* agent);
	virtual void Exit(CannonBall* agent);
	virtual bool OnMessage(CannonBall* agent, const Telegram& telegram);
	
private:
	CannonBallState_Flying() {}
	CannonBallState_Flying(const CannonBallState_Flying&);
	virtual ~CannonBallState_Flying() {}
	CannonBallState_Flying& operator=(const CannonBallState_Flying&);
};

// -------------------------------------------------------------------------------------

class CannonBallState_HitSomething : public State<CannonBall>, public Singleton<CannonBallState_HitSomething>
{
	friend class Singleton<CannonBallState_HitSomething>;
	
public:
	virtual void Enter(CannonBall* agent);
	virtual void Execute(CannonBall* agent);
	
private:
	CannonBallState_HitSomething() {}
	CannonBallState_HitSomething(const CannonBallState_HitSomething&);
	virtual ~CannonBallState_HitSomething() {}
	CannonBallState_HitSomething& operator=(const CannonBallState_HitSomething&);
};

// -------------------------------------------------------------------------------------

#endif
