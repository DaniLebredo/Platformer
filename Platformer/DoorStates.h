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

#ifndef DOORSTATES_H
#define DOORSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Door;

// -------------------------------------------------------------------------------------

class DoorState_Global : public State<Door>, public Singleton<DoorState_Global>
{
	friend class Singleton<DoorState_Global>;
	
public:
	virtual void Execute(Door* agent);
	virtual bool OnMessage(Door* agent, const Telegram& telegram);
	
private:
	DoorState_Global() {}
	DoorState_Global(const DoorState_Global&);
	virtual ~DoorState_Global() {}
	DoorState_Global& operator=(const DoorState_Global&);
};

// -------------------------------------------------------------------------------------

class DoorState_Normal : public State<Door>, public Singleton<DoorState_Normal>
{
	friend class Singleton<DoorState_Normal>;
	
public:
	virtual void Enter(Door* agent);
	virtual void Execute(Door* agent);
	virtual bool OnMessage(Door* agent, const Telegram& telegram);
	
private:
	DoorState_Normal() {}
	DoorState_Normal(const DoorState_Normal&);
	virtual ~DoorState_Normal() {}
	DoorState_Normal& operator=(const DoorState_Normal&);
};

// -------------------------------------------------------------------------------------

class DoorState_Opened : public State<Door>, public Singleton<DoorState_Opened>
{
	friend class Singleton<DoorState_Opened>;
	
public:
	virtual void Enter(Door* agent);
	virtual void Execute(Door* agent);
	
private:
	DoorState_Opened() {}
	DoorState_Opened(const DoorState_Opened&);
	virtual ~DoorState_Opened() {}
	DoorState_Opened& operator=(const DoorState_Opened&);
};

// -------------------------------------------------------------------------------------

#endif
