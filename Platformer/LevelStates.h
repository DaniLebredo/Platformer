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

#ifndef LEVELSTATES_H
#define LEVELSTATES_H

#import "State.h"
#import "Singleton.h"

class LevelController;

// -------------------------------------------------------------------------------------

class LevelState_Global : public State<LevelController>, public Singleton<LevelState_Global>
{
	friend class Singleton<LevelState_Global>;
	
public:
	virtual void Execute(LevelController* agent);
	virtual bool OnMessage(LevelController* agent, const Telegram& telegram);
	
private:
	LevelState_Global() {}
	LevelState_Global(const LevelState_Global&);
	virtual ~LevelState_Global() {}
	LevelState_Global& operator=(const LevelState_Global&);
};

// -------------------------------------------------------------------------------------

class LevelState_EnterTransition : public State<LevelController>, public Singleton<LevelState_EnterTransition>
{
	friend class Singleton<LevelState_EnterTransition>;
	
public:
	virtual void Enter(LevelController* agent);
	virtual bool OnMessage(LevelController* agent, const Telegram& telegram);
	
private:
	LevelState_EnterTransition() {}
	LevelState_EnterTransition(const LevelState_EnterTransition&);
	virtual ~LevelState_EnterTransition() {}
	LevelState_EnterTransition& operator=(const LevelState_EnterTransition&);
};

// -------------------------------------------------------------------------------------

class LevelState_GetReady : public State<LevelController>, public Singleton<LevelState_GetReady>
{
	friend class Singleton<LevelState_GetReady>;
	
public:
	virtual void Enter(LevelController* agent);
	virtual void Execute(LevelController* agent);
	virtual void Exit(LevelController* agent);
	bool OnMessage(LevelController* agent, const Telegram& telegram);
	
private:
	LevelState_GetReady() {}
	LevelState_GetReady(const LevelState_GetReady&);
	virtual ~LevelState_GetReady() {}
	LevelState_GetReady& operator=(const LevelState_GetReady&);
};

// -------------------------------------------------------------------------------------

class LevelState_Normal : public State<LevelController>, public Singleton<LevelState_Normal>
{
	friend class Singleton<LevelState_Normal>;
	
public:
	virtual void Enter(LevelController* agent);
	virtual void Execute(LevelController* agent);
	virtual void Exit(LevelController* agent);
	virtual bool OnMessage(LevelController* agent, const Telegram& telegram);
	
private:
	LevelState_Normal() {}
	LevelState_Normal(const LevelState_Normal&);
	virtual ~LevelState_Normal() {}
	LevelState_Normal& operator=(const LevelState_Normal&);
};

// -------------------------------------------------------------------------------------

class LevelState_Paused : public State<LevelController>, public Singleton<LevelState_Paused>
{
	friend class Singleton<LevelState_Paused>;
	
public:
	virtual void Enter(LevelController* agent);
	virtual void Exit(LevelController* agent);
	virtual bool OnMessage(LevelController* agent, const Telegram& telegram);
	
private:
	LevelState_Paused() {}
	LevelState_Paused(const LevelState_Paused&);
	virtual ~LevelState_Paused() {}
	LevelState_Paused& operator=(const LevelState_Paused&);
};

// -------------------------------------------------------------------------------------

class LevelState_Settings : public State<LevelController>, public Singleton<LevelState_Settings>
{
	friend class Singleton<LevelState_Settings>;
	
public:
	virtual void Enter(LevelController* agent);
	virtual void Exit(LevelController* agent);
	virtual bool OnMessage(LevelController* agent, const Telegram& telegram);
	
private:
	LevelState_Settings() {}
	LevelState_Settings(const LevelState_Settings&);
	virtual ~LevelState_Settings() {}
	LevelState_Settings& operator=(const LevelState_Settings&);
};

// -------------------------------------------------------------------------------------

class LevelState_Controls : public State<LevelController>, public Singleton<LevelState_Controls>
{
	friend class Singleton<LevelState_Controls>;
	
public:
	virtual void Enter(LevelController* agent);
	virtual void Exit(LevelController* agent);
	virtual bool OnMessage(LevelController* agent, const Telegram& telegram);
	
private:
	LevelState_Controls() {}
	LevelState_Controls(const LevelState_Controls&);
	virtual ~LevelState_Controls() {}
	LevelState_Controls& operator=(const LevelState_Controls&);
};

// -------------------------------------------------------------------------------------

class LevelState_LifeLost : public State<LevelController>, public Singleton<LevelState_LifeLost>
{
	friend class Singleton<LevelState_LifeLost>;
	
public:
	virtual void Enter(LevelController* agent);
	virtual void Execute(LevelController* agent);
	virtual void Exit(LevelController* agent);
	virtual bool OnMessage(LevelController* agent, const Telegram& telegram);
	
private:
	LevelState_LifeLost() {}
	LevelState_LifeLost(const LevelState_LifeLost&);
	virtual ~LevelState_LifeLost() {}
	LevelState_LifeLost& operator=(const LevelState_LifeLost&);
};

// -------------------------------------------------------------------------------------

class LevelState_LevelComplete : public State<LevelController>, public Singleton<LevelState_LevelComplete>
{
	friend class Singleton<LevelState_LevelComplete>;
	
public:
	virtual void Enter(LevelController* agent);
	virtual void Exit(LevelController* agent);
	virtual bool OnMessage(LevelController* agent, const Telegram& telegram);
	
private:
	LevelState_LevelComplete() {}
	LevelState_LevelComplete(const LevelState_LevelComplete&);
	virtual ~LevelState_LevelComplete() {}
	LevelState_LevelComplete& operator=(const LevelState_LevelComplete&);
};

// -------------------------------------------------------------------------------------

#endif
