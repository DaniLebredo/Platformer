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

#ifndef PENDULUMSTATES_H
#define PENDULUMSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Pendulum;

// -------------------------------------------------------------------------------------

class PendulumState_Global : public State<Pendulum>, public Singleton<PendulumState_Global>
{
	friend class Singleton<PendulumState_Global>;
	
public:
	virtual void Execute(Pendulum* agent);
	virtual bool OnMessage(Pendulum* agent, const Telegram& telegram);
	
private:
	PendulumState_Global() {}
	PendulumState_Global(const PendulumState_Global&);
	virtual ~PendulumState_Global() {}
	PendulumState_Global& operator=(const PendulumState_Global&);
};

// -------------------------------------------------------------------------------------

class PendulumState_Normal : public State<Pendulum>, public Singleton<PendulumState_Normal>
{
	friend class Singleton<PendulumState_Normal>;
	
public:
	virtual void Enter(Pendulum* agent);
	virtual void Execute(Pendulum* agent);
	
private:
	PendulumState_Normal() {}
	PendulumState_Normal(const PendulumState_Normal&);
	virtual ~PendulumState_Normal() {}
	PendulumState_Normal& operator=(const PendulumState_Normal&);
};

// -------------------------------------------------------------------------------------

#endif
