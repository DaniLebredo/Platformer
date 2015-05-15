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

#ifndef CONCRETESLABSTATES_H
#define CONCRETESLABSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class ConcreteSlab;

// -------------------------------------------------------------------------------------

class ConcreteSlabState_Global : public State<ConcreteSlab>, public Singleton<ConcreteSlabState_Global>
{
	friend class Singleton<ConcreteSlabState_Global>;
	
public:
	virtual bool OnMessage(ConcreteSlab* agent, const Telegram& telegram);
	virtual void Execute(ConcreteSlab* agent);
	
private:
	ConcreteSlabState_Global() {}
	ConcreteSlabState_Global(const ConcreteSlabState_Global&);
	virtual ~ConcreteSlabState_Global() {}
	ConcreteSlabState_Global& operator=(const ConcreteSlabState_Global&);
};

// -------------------------------------------------------------------------------------

class ConcreteSlabState_Normal : public State<ConcreteSlab>, public Singleton<ConcreteSlabState_Normal>
{
	friend class Singleton<ConcreteSlabState_Normal>;
	
public:
	virtual void Enter(ConcreteSlab* agent);
	virtual void Execute(ConcreteSlab* agent);
	virtual bool OnMessage(ConcreteSlab* agent, const Telegram& telegram);
	
private:
	ConcreteSlabState_Normal() {}
	ConcreteSlabState_Normal(const ConcreteSlabState_Normal&);
	virtual ~ConcreteSlabState_Normal() {}
	ConcreteSlabState_Normal& operator=(const ConcreteSlabState_Normal&);
};

// -------------------------------------------------------------------------------------

class ConcreteSlabState_FallingDown : public State<ConcreteSlab>, public Singleton<ConcreteSlabState_FallingDown>
{
	friend class Singleton<ConcreteSlabState_FallingDown>;
	
public:
	virtual void Enter(ConcreteSlab* agent);
	virtual void Execute(ConcreteSlab* agent);
	
private:
	ConcreteSlabState_FallingDown() {}
	ConcreteSlabState_FallingDown(const ConcreteSlabState_FallingDown&);
	virtual ~ConcreteSlabState_FallingDown() {}
	ConcreteSlabState_FallingDown& operator=(const ConcreteSlabState_FallingDown&);
};

// -------------------------------------------------------------------------------------

#endif
