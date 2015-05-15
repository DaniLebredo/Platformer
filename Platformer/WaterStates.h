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

#ifndef WATERSTATES_H
#define WATERSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Water;

// -------------------------------------------------------------------------------------

class WaterState_Global : public State<Water>, public Singleton<WaterState_Global>
{
	friend class Singleton<WaterState_Global>;
	
public:
	virtual void Execute(Water* agent);
	virtual bool OnMessage(Water* agent, const Telegram& telegram);
	
private:
	WaterState_Global() {}
	WaterState_Global(const WaterState_Global&);
	virtual ~WaterState_Global() {}
	WaterState_Global& operator=(const WaterState_Global&);
};

// -------------------------------------------------------------------------------------

class WaterState_Normal : public State<Water>, public Singleton<WaterState_Normal>
{
	friend class Singleton<WaterState_Normal>;
	
public:
	virtual void Enter(Water* agent);
	virtual void Execute(Water* agent);
	
private:
	WaterState_Normal() {}
	WaterState_Normal(const WaterState_Normal&);
	virtual ~WaterState_Normal() {}
	WaterState_Normal& operator=(const WaterState_Normal&);
};

// -------------------------------------------------------------------------------------

#endif
