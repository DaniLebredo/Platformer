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

#ifndef ENDOFLEVELSTATES_H
#define ENDOFLEVELSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class EndOfLevel;

// -------------------------------------------------------------------------------------

class EndOfLevelState_Global : public State<EndOfLevel>, public Singleton<EndOfLevelState_Global>
{
	friend class Singleton<EndOfLevelState_Global>;
	
public:
	virtual void Execute(EndOfLevel* agent);
	virtual bool OnMessage(EndOfLevel* agent, const Telegram& telegram);
	
private:
	EndOfLevelState_Global() {}
	EndOfLevelState_Global(const EndOfLevelState_Global&);
	virtual ~EndOfLevelState_Global() {}
	EndOfLevelState_Global& operator=(const EndOfLevelState_Global&);
};

// -------------------------------------------------------------------------------------

class EndOfLevelState_PlayerFar : public State<EndOfLevel>, public Singleton<EndOfLevelState_PlayerFar>
{
	friend class Singleton<EndOfLevelState_PlayerFar>;
	
public:
	virtual void Enter(EndOfLevel* agent);
	virtual void Execute(EndOfLevel* agent);
	virtual void Exit(EndOfLevel* agent);
	virtual bool OnMessage(EndOfLevel* agent, const Telegram& telegram);
	
private:
	EndOfLevelState_PlayerFar() {}
	EndOfLevelState_PlayerFar(const EndOfLevelState_PlayerFar&);
	virtual ~EndOfLevelState_PlayerFar() {}
	EndOfLevelState_PlayerFar& operator=(const EndOfLevelState_PlayerFar&);
};

// -------------------------------------------------------------------------------------

class EndOfLevelState_PlayerClose : public State<EndOfLevel>, public Singleton<EndOfLevelState_PlayerClose>
{
	friend class Singleton<EndOfLevelState_PlayerClose>;
	
public:
	virtual void Enter(EndOfLevel* agent);
	virtual void Execute(EndOfLevel* agent);
	virtual void Exit(EndOfLevel* agent);
	virtual bool OnMessage(EndOfLevel* agent, const Telegram& telegram);
	
private:
	EndOfLevelState_PlayerClose() {}
	EndOfLevelState_PlayerClose(const EndOfLevelState_PlayerClose&);
	virtual ~EndOfLevelState_PlayerClose() {}
	EndOfLevelState_PlayerClose& operator=(const EndOfLevelState_PlayerClose&);
};

// -------------------------------------------------------------------------------------

class EndOfLevelState_Found : public State<EndOfLevel>, public Singleton<EndOfLevelState_Found>
{
	friend class Singleton<EndOfLevelState_Found>;
	
public:
	virtual void Enter(EndOfLevel* agent);
	virtual void Execute(EndOfLevel* agent);
	
private:
	EndOfLevelState_Found() {}
	EndOfLevelState_Found(const EndOfLevelState_Found&);
	virtual ~EndOfLevelState_Found() {}
	EndOfLevelState_Found& operator=(const EndOfLevelState_Found&);
};

// -------------------------------------------------------------------------------------

#endif
