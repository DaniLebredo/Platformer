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

#ifndef BARRELSTATE_H
#define BARRELSTATE_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Barrel;

// -------------------------------------------------------------------------------------

class BarrelState_Global : public State<Barrel>, public Singleton<BarrelState_Global>
{
	friend class Singleton<BarrelState_Global>;
	
public:
	virtual void Execute(Barrel* agent);
	
private:
	BarrelState_Global() {}
	BarrelState_Global(const BarrelState_Global&);
	virtual ~BarrelState_Global() {}
	BarrelState_Global& operator=(const BarrelState_Global&);
};

// -------------------------------------------------------------------------------------

class BarrelState_Normal : public State<Barrel>, public Singleton<BarrelState_Normal>
{
	friend class Singleton<BarrelState_Normal>;
	
public:
	virtual void Enter(Barrel* agent);
	virtual void Execute(Barrel* agent);
	virtual bool OnMessage(Barrel* agent, const Telegram& telegram);
	
private:
	BarrelState_Normal() {}
	BarrelState_Normal(const BarrelState_Normal&);
	virtual ~BarrelState_Normal() {}
	BarrelState_Normal& operator=(const BarrelState_Normal&);
};

// -------------------------------------------------------------------------------------

class BarrelState_ExplodeWithDelay : public State<Barrel>, public Singleton<BarrelState_ExplodeWithDelay>
{
	friend class Singleton<BarrelState_ExplodeWithDelay>;
	
public:
	virtual void Enter(Barrel* agent);
	virtual void Execute(Barrel* agent);
	
private:
	BarrelState_ExplodeWithDelay() {}
	BarrelState_ExplodeWithDelay(const BarrelState_ExplodeWithDelay&);
	virtual ~BarrelState_ExplodeWithDelay() {}
	BarrelState_ExplodeWithDelay& operator=(const BarrelState_ExplodeWithDelay&);
};

// -------------------------------------------------------------------------------------

class BarrelState_Explode : public State<Barrel>, public Singleton<BarrelState_Explode>
{
	friend class Singleton<BarrelState_Explode>;
	
public:
	virtual void Enter(Barrel* agent);
	virtual void Execute(Barrel* agent);
	
private:
	BarrelState_Explode() {}
	BarrelState_Explode(const BarrelState_Explode&);
	virtual ~BarrelState_Explode() {}
	BarrelState_Explode& operator=(const BarrelState_Explode&);
};

// -------------------------------------------------------------------------------------

#endif
