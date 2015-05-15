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

#ifndef LEVELSELECTIONSTATES_H
#define LEVELSELECTIONSTATES_H

#import "State.h"
#import "Singleton.h"

class LevelSelectionController;

// -------------------------------------------------------------------------------------

class LevelSelectionState_Global : public State<LevelSelectionController>, public Singleton<LevelSelectionState_Global>
{
	friend class Singleton<LevelSelectionState_Global>;
	
public:
	virtual void Execute(LevelSelectionController* agent);
	virtual bool OnMessage(LevelSelectionController* agent, const Telegram& telegram);
	
private:
	LevelSelectionState_Global() {}
	LevelSelectionState_Global(const LevelSelectionState_Global&);
	virtual ~LevelSelectionState_Global() {}
	LevelSelectionState_Global& operator=(const LevelSelectionState_Global&);
};

// -------------------------------------------------------------------------------------

class LevelSelectionState_EnterTransition : public State<LevelSelectionController>, public Singleton<LevelSelectionState_EnterTransition>
{
	friend class Singleton<LevelSelectionState_EnterTransition>;
	
public:
	virtual void Enter(LevelSelectionController* agent);
	virtual bool OnMessage(LevelSelectionController* agent, const Telegram& telegram);
	
private:
	LevelSelectionState_EnterTransition() {}
	LevelSelectionState_EnterTransition(const LevelSelectionState_EnterTransition&);
	virtual ~LevelSelectionState_EnterTransition() {}
	LevelSelectionState_EnterTransition& operator=(const LevelSelectionState_EnterTransition&);
};

// -------------------------------------------------------------------------------------

class LevelSelectionState_Worlds : public State<LevelSelectionController>, public Singleton<LevelSelectionState_Worlds>
{
	friend class Singleton<LevelSelectionState_Worlds>;
	
public:
	virtual void Enter(LevelSelectionController* agent);
	virtual void Exit(LevelSelectionController* agent);
	virtual bool OnMessage(LevelSelectionController* agent, const Telegram& telegram);
	
private:
	LevelSelectionState_Worlds() {}
	LevelSelectionState_Worlds(const LevelSelectionState_Worlds&);
	virtual ~LevelSelectionState_Worlds() {}
	LevelSelectionState_Worlds& operator=(const LevelSelectionState_Worlds&);
};

// -------------------------------------------------------------------------------------

class LevelSelectionState_Levels : public State<LevelSelectionController>, public Singleton<LevelSelectionState_Levels>
{
	friend class Singleton<LevelSelectionState_Levels>;
	
public:
	virtual void Enter(LevelSelectionController* agent);
	virtual void Exit(LevelSelectionController* agent);
	virtual bool OnMessage(LevelSelectionController* agent, const Telegram& telegram);
	
private:
	LevelSelectionState_Levels() {}
	LevelSelectionState_Levels(const LevelSelectionState_Levels&);
	virtual ~LevelSelectionState_Levels() {}
	LevelSelectionState_Levels& operator=(const LevelSelectionState_Levels&);
};

// -------------------------------------------------------------------------------------

class LevelSelectionState_Store : public State<LevelSelectionController>, public Singleton<LevelSelectionState_Store>
{
	friend class Singleton<LevelSelectionState_Store>;
	
public:
	virtual void Enter(LevelSelectionController* agent);
	virtual void Exit(LevelSelectionController* agent);
	virtual bool OnMessage(LevelSelectionController* agent, const Telegram& telegram);
	
private:
	LevelSelectionState_Store() {}
	LevelSelectionState_Store(const LevelSelectionState_Store&);
	virtual ~LevelSelectionState_Store() {}
	LevelSelectionState_Store& operator=(const LevelSelectionState_Store&);
};

// -------------------------------------------------------------------------------------

#endif
