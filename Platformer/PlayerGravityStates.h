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

#ifndef PLAYERGRAVITYSTATES_H
#define PLAYERGRAVITYSTATES_H

#import "State.h"
#import "Singleton.h"

class PlayerGravity;

// -------------------------------------------------------------------------------------

class PlayerGravityState_Global : public State<PlayerGravity>, public Singleton<PlayerGravityState_Global>
{
	friend class Singleton<PlayerGravityState_Global>;
	
public:
	virtual void Execute(PlayerGravity* agent);
	virtual bool OnMessage(PlayerGravity* agent, const Telegram& telegram);
	
private:
	PlayerGravityState_Global() {}
	PlayerGravityState_Global(const PlayerGravityState_Global&);
	virtual ~PlayerGravityState_Global() {}
	PlayerGravityState_Global& operator=(const PlayerGravityState_Global&);
};

// -------------------------------------------------------------------------------------

class PlayerGravityState_OnTheFloor : public State<PlayerGravity>, public Singleton<PlayerGravityState_OnTheFloor>
{
	friend class Singleton<PlayerGravityState_OnTheFloor>;
	
public:
	virtual void Enter(PlayerGravity* agent);
	virtual void Execute(PlayerGravity* agent);
	virtual void Exit(PlayerGravity* agent);
	
private:
	PlayerGravityState_OnTheFloor() {}
	PlayerGravityState_OnTheFloor(const PlayerGravityState_OnTheFloor&);
	virtual ~PlayerGravityState_OnTheFloor() {}
	PlayerGravityState_OnTheFloor& operator=(const PlayerGravityState_OnTheFloor&);
};

// -------------------------------------------------------------------------------------

class PlayerGravityState_InTheAir : public State<PlayerGravity>, public Singleton<PlayerGravityState_InTheAir>
{
	friend class Singleton<PlayerGravityState_InTheAir>;
	
public:
	virtual void Enter(PlayerGravity* agent);
	virtual void Execute(PlayerGravity* agent);
	
private:
	PlayerGravityState_InTheAir() {}
	PlayerGravityState_InTheAir(const PlayerGravityState_InTheAir&);
	virtual ~PlayerGravityState_InTheAir() {}
	PlayerGravityState_InTheAir& operator=(const PlayerGravityState_InTheAir&);
};

// -------------------------------------------------------------------------------------

class PlayerGravityState_Dead : public State<PlayerGravity>, public Singleton<PlayerGravityState_Dead>
{
	friend class Singleton<PlayerGravityState_Dead>;
	
public:
	virtual void Enter(PlayerGravity* agent);
	virtual void Execute(PlayerGravity* agent);
	
private:
	PlayerGravityState_Dead() {}
	PlayerGravityState_Dead(const PlayerGravityState_Dead&);
	virtual ~PlayerGravityState_Dead() {}
	PlayerGravityState_Dead& operator=(const PlayerGravityState_Dead&);
};

// -------------------------------------------------------------------------------------

class PlayerGravityState_Done : public State<PlayerGravity>, public Singleton<PlayerGravityState_Done>
{
	friend class Singleton<PlayerGravityState_Done>;
	
public:
	virtual void Enter(PlayerGravity* agent);
	void Execute(PlayerGravity* agent);
	
private:
	PlayerGravityState_Done() {}
	PlayerGravityState_Done(const PlayerGravityState_Done&);
	virtual ~PlayerGravityState_Done() {}
	PlayerGravityState_Done& operator=(const PlayerGravityState_Done&);
};

// -------------------------------------------------------------------------------------

#endif
