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

#ifndef CRACKEDTILESTATES_H
#define CRACKEDTILESTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class CrackedTile;

// -------------------------------------------------------------------------------------

class CrackedTileState_Global : public State<CrackedTile>, public Singleton<CrackedTileState_Global>
{
	friend class Singleton<CrackedTileState_Global>;
	
public:
	virtual void Execute(CrackedTile* agent);
	virtual bool OnMessage(CrackedTile* agent, const Telegram& telegram);
	
private:
	CrackedTileState_Global() {}
	CrackedTileState_Global(const CrackedTileState_Global&);
	virtual ~CrackedTileState_Global() {}
	CrackedTileState_Global& operator=(const CrackedTileState_Global&);
};

// -------------------------------------------------------------------------------------

class CrackedTileState_Normal : public State<CrackedTile>, public Singleton<CrackedTileState_Normal>
{
	friend class Singleton<CrackedTileState_Normal>;
	
public:
	virtual void Enter(CrackedTile* agent);
	virtual void Execute(CrackedTile* agent);
	virtual bool OnMessage(CrackedTile* agent, const Telegram& telegram);
	
private:
	CrackedTileState_Normal() {}
	CrackedTileState_Normal(const CrackedTileState_Normal&);
	virtual ~CrackedTileState_Normal() {}
	CrackedTileState_Normal& operator=(const CrackedTileState_Normal&);
};

// -------------------------------------------------------------------------------------

class CrackedTileState_Destroyed : public State<CrackedTile>, public Singleton<CrackedTileState_Destroyed>
{
	friend class Singleton<CrackedTileState_Destroyed>;
	
public:
	virtual void Enter(CrackedTile* agent);
	virtual void Execute(CrackedTile* agent);
	
private:
	CrackedTileState_Destroyed() {}
	CrackedTileState_Destroyed(const CrackedTileState_Destroyed&);
	virtual ~CrackedTileState_Destroyed() {}
	CrackedTileState_Destroyed& operator=(const CrackedTileState_Destroyed&);
};

// -------------------------------------------------------------------------------------

#endif
