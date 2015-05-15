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

#ifndef BOULDERSTATES_H
#define BOULDERSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Boulder;

// -------------------------------------------------------------------------------------

class BoulderState_Global : public State<Boulder>, public Singleton<BoulderState_Global>
{
	friend class Singleton<BoulderState_Global>;
	
public:
	virtual void Execute(Boulder* agent);
	virtual bool OnMessage(Boulder* agent, const Telegram& telegram);
	
private:
	BoulderState_Global() {}
	BoulderState_Global(const BoulderState_Global&);
	virtual ~BoulderState_Global() {}
	BoulderState_Global& operator=(const BoulderState_Global&);
};

// -------------------------------------------------------------------------------------

class BoulderState_Roll : public State<Boulder>, public Singleton<BoulderState_Roll>
{
	friend class Singleton<BoulderState_Roll>;
	
public:
	virtual void Enter(Boulder* agent);
	virtual void Execute(Boulder* agent);
	virtual void Exit(Boulder* agent);
	virtual bool OnMessage(Boulder* agent, const Telegram& telegram);
	
private:
	BoulderState_Roll() {}
	BoulderState_Roll(const BoulderState_Roll&);
	virtual ~BoulderState_Roll() {}
	BoulderState_Roll& operator=(const BoulderState_Roll&);
};

// -------------------------------------------------------------------------------------

class BoulderState_Stopped : public State<Boulder>, public Singleton<BoulderState_Stopped>
{
	friend class Singleton<BoulderState_Stopped>;
	
public:
	virtual void Enter(Boulder* agent);
	virtual void Execute(Boulder* agent);
	virtual bool OnMessage(Boulder* agent, const Telegram& telegram);
	
private:
	BoulderState_Stopped() {}
	BoulderState_Stopped(const BoulderState_Stopped&);
	virtual ~BoulderState_Stopped() {}
	BoulderState_Stopped& operator=(const BoulderState_Stopped&);
};

// -------------------------------------------------------------------------------------

#endif
