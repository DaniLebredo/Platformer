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

#ifndef PLAYERSTATES_H
#define PLAYERSTATES_H

#import "State.h"
#import "Singleton.h"

class PlayerNormal;

// -------------------------------------------------------------------------------------

class PlayerNormalState_Global : public State<PlayerNormal>, public Singleton<PlayerNormalState_Global>
{
	friend class Singleton<PlayerNormalState_Global>;
	
public:
	virtual void Execute(PlayerNormal* agent);
	virtual bool OnMessage(PlayerNormal* agent, const Telegram& telegram);
	
private:
	PlayerNormalState_Global() {}
	PlayerNormalState_Global(const PlayerNormalState_Global&);
	virtual ~PlayerNormalState_Global() {}
	PlayerNormalState_Global& operator=(const PlayerNormalState_Global&);
};

// -------------------------------------------------------------------------------------

class PlayerNormalState_OnTheFloor : public State<PlayerNormal>, public Singleton<PlayerNormalState_OnTheFloor>
{
	friend class Singleton<PlayerNormalState_OnTheFloor>;
	
public:
	virtual void Enter(PlayerNormal* agent);
	virtual void Execute(PlayerNormal* agent);
	virtual void Exit(PlayerNormal* agent);
	
private:
	PlayerNormalState_OnTheFloor() {}
	PlayerNormalState_OnTheFloor(const PlayerNormalState_OnTheFloor&);
	virtual ~PlayerNormalState_OnTheFloor() {}
	PlayerNormalState_OnTheFloor& operator=(const PlayerNormalState_OnTheFloor&);
};

// -------------------------------------------------------------------------------------

class PlayerNormalState_Jump : public State<PlayerNormal>, public Singleton<PlayerNormalState_Jump>
{
	friend class Singleton<PlayerNormalState_Jump>;
	
public:
	virtual void Enter(PlayerNormal* agent);
	virtual void Execute(PlayerNormal* agent);
	
private:
	PlayerNormalState_Jump() {}
	PlayerNormalState_Jump(const PlayerNormalState_Jump&);
	virtual ~PlayerNormalState_Jump() {}
	PlayerNormalState_Jump& operator=(const PlayerNormalState_Jump&);
};

// -------------------------------------------------------------------------------------

class PlayerNormalState_Bounce : public State<PlayerNormal>, public Singleton<PlayerNormalState_Bounce>
{
	friend class Singleton<PlayerNormalState_Bounce>;
	
public:
	virtual void Enter(PlayerNormal* agent);
	virtual void Execute(PlayerNormal* agent);
	
private:
	PlayerNormalState_Bounce() {}
	PlayerNormalState_Bounce(const PlayerNormalState_Bounce&);
	virtual ~PlayerNormalState_Bounce() {}
	PlayerNormalState_Bounce& operator=(const PlayerNormalState_Bounce&);
};

// -------------------------------------------------------------------------------------

class PlayerNormalState_RisingUp : public State<PlayerNormal>, public Singleton<PlayerNormalState_RisingUp>
{
	friend class Singleton<PlayerNormalState_RisingUp>;
	
public:
	virtual void Enter(PlayerNormal* agent);
	virtual void Execute(PlayerNormal* agent);
	
private:
	PlayerNormalState_RisingUp() {}
	PlayerNormalState_RisingUp(const PlayerNormalState_RisingUp&);
	virtual ~PlayerNormalState_RisingUp() {}
	PlayerNormalState_RisingUp& operator=(const PlayerNormalState_RisingUp&);
};

// -------------------------------------------------------------------------------------

class PlayerNormalState_AttenuateJump : public State<PlayerNormal>, public Singleton<PlayerNormalState_AttenuateJump>
{
	friend class Singleton<PlayerNormalState_AttenuateJump>;
	
public:
	virtual void Enter(PlayerNormal* agent);
	virtual void Execute(PlayerNormal* agent);
	
private:
	PlayerNormalState_AttenuateJump() {}
	PlayerNormalState_AttenuateJump(const PlayerNormalState_AttenuateJump&);
	virtual ~PlayerNormalState_AttenuateJump() {}
	PlayerNormalState_AttenuateJump& operator=(const PlayerNormalState_AttenuateJump&);
};

// -------------------------------------------------------------------------------------

class PlayerNormalState_FallingDown : public State<PlayerNormal>, public Singleton<PlayerNormalState_FallingDown>
{
	friend class Singleton<PlayerNormalState_FallingDown>;
	
public:
	virtual void Enter(PlayerNormal* agent);
	virtual void Execute(PlayerNormal* agent);
	
private:
	PlayerNormalState_FallingDown() {}
	PlayerNormalState_FallingDown(const PlayerNormalState_FallingDown&);
	virtual ~PlayerNormalState_FallingDown() {}
	PlayerNormalState_FallingDown& operator=(const PlayerNormalState_FallingDown&);
};

// -------------------------------------------------------------------------------------

class PlayerNormalState_Dead : public State<PlayerNormal>, public Singleton<PlayerNormalState_Dead>
{
	friend class Singleton<PlayerNormalState_Dead>;
	
public:
	virtual void Enter(PlayerNormal* agent);
	virtual void Execute(PlayerNormal* agent);
	
private:
	PlayerNormalState_Dead() {}
	PlayerNormalState_Dead(const PlayerNormalState_Dead&);
	virtual ~PlayerNormalState_Dead() {}
	PlayerNormalState_Dead& operator=(const PlayerNormalState_Dead&);
};

// -------------------------------------------------------------------------------------

class PlayerNormalState_Done : public State<PlayerNormal>, public Singleton<PlayerNormalState_Done>
{
	friend class Singleton<PlayerNormalState_Done>;
	
public:
	virtual void Enter(PlayerNormal* agent);
	void Execute(PlayerNormal* agent);
	
private:
	PlayerNormalState_Done() {}
	PlayerNormalState_Done(const PlayerNormalState_Done&);
	virtual ~PlayerNormalState_Done() {}
	PlayerNormalState_Done& operator=(const PlayerNormalState_Done&);
};

// -------------------------------------------------------------------------------------

#endif
