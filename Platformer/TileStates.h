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

#ifndef TILESTATES_H
#define TILESTATES_H

#import "State.h"
#import "Singleton.h"

class Tile;

// -------------------------------------------------------------------------------------

class TileState_Global : public State<Tile>, public Singleton<TileState_Global>
{
	friend class Singleton<TileState_Global>;
	
public:
	virtual void Execute(Tile* agent);
	virtual bool OnMessage(Tile* agent, const Telegram& telegram);
	
private:
	TileState_Global() {}
	TileState_Global(const TileState_Global&);
	virtual ~TileState_Global() {}
	TileState_Global& operator=(const TileState_Global&);
};

// -------------------------------------------------------------------------------------

class TileState_Normal : public State<Tile>, public Singleton<TileState_Normal>
{
	friend class Singleton<TileState_Normal>;
	
public:
	virtual void Enter(Tile* agent);
	virtual void Execute(Tile* agent);
	
private:
	TileState_Normal() {}
	TileState_Normal(const TileState_Normal&);
	virtual ~TileState_Normal() {}
	TileState_Normal& operator=(const TileState_Normal&);
};

// -------------------------------------------------------------------------------------

#endif
