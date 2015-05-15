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

#ifndef JUMPERSTATES_H
#define JUMPERSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Jumper;

// -------------------------------------------------------------------------------------

class JumperState_Global : public State<Jumper>, public Singleton<JumperState_Global>
{
	friend class Singleton<JumperState_Global>;
	
public:
	virtual void Execute(Jumper* agent);
	virtual bool OnMessage(Jumper* agent, const Telegram& telegram);
	
private:
	JumperState_Global() {}
	JumperState_Global(const JumperState_Global&);
	virtual ~JumperState_Global() {}
	JumperState_Global& operator=(const JumperState_Global&);
};

// -------------------------------------------------------------------------------------

class JumperState_OnTheFloor : public State<Jumper>, public Singleton<JumperState_OnTheFloor>
{
	friend class Singleton<JumperState_OnTheFloor>;
	
public:
	virtual void Enter(Jumper* agent);
	virtual void Execute(Jumper* agent);
	virtual void Exit(Jumper* agent);
	
private:
	JumperState_OnTheFloor() {}
	JumperState_OnTheFloor(const JumperState_OnTheFloor&);
	virtual ~JumperState_OnTheFloor() {}
	JumperState_OnTheFloor& operator=(const JumperState_OnTheFloor&);
};

// -------------------------------------------------------------------------------------

class JumperState_Attack : public State<Jumper>, public Singleton<JumperState_Attack>
{
	friend class Singleton<JumperState_Attack>;
	
public:
	virtual void Enter(Jumper* agent);
	virtual void Execute(Jumper* agent);
	virtual void Exit(Jumper* agent);
	
private:
	JumperState_Attack() {}
	JumperState_Attack(const JumperState_Attack&);
	virtual ~JumperState_Attack() {}
	JumperState_Attack& operator=(const JumperState_Attack&);
};

// -------------------------------------------------------------------------------------

class JumperState_Jump : public State<Jumper>, public Singleton<JumperState_Jump>
{
	friend class Singleton<JumperState_Jump>;
	
public:
	virtual void Enter(Jumper* agent);
	virtual void Execute(Jumper* agent);
	
private:
	JumperState_Jump() {}
	JumperState_Jump(const JumperState_Jump&);
	virtual ~JumperState_Jump() {}
	JumperState_Jump& operator=(const JumperState_Jump&);
};

// -------------------------------------------------------------------------------------

class JumperState_Dead : public State<Jumper>, public Singleton<JumperState_Dead>
{
	friend class Singleton<JumperState_Dead>;
	
public:
	virtual void Enter(Jumper* agent);
	virtual void Execute(Jumper* agent);
	virtual bool OnMessage(Jumper* agent, const Telegram& telegram);
	
private:
	JumperState_Dead() {}
	JumperState_Dead(const JumperState_Dead&);
	virtual ~JumperState_Dead() {}
	JumperState_Dead& operator=(const JumperState_Dead&);
};

// -------------------------------------------------------------------------------------

class JumperState_Drowned : public State<Jumper>, public Singleton<JumperState_Drowned>
{
	friend class Singleton<JumperState_Drowned>;
	
public:
	virtual void Enter(Jumper* agent);
	virtual void Execute(Jumper* agent);
	virtual bool OnMessage(Jumper* agent, const Telegram& telegram);
	
private:
	JumperState_Drowned() {}
	JumperState_Drowned(const JumperState_Drowned&);
	virtual ~JumperState_Drowned() {}
	JumperState_Drowned& operator=(const JumperState_Drowned&);
};

// -------------------------------------------------------------------------------------

#endif
