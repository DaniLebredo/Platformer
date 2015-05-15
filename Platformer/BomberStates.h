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

#ifndef BOMBERSTATES_H
#define BOMBERSTATES_H

#import "State.h"
#import "Singleton.h"

class Bomber;

// -------------------------------------------------------------------------------------

class BomberState_Global : public State<Bomber>, public Singleton<BomberState_Global>
{
	friend class Singleton<BomberState_Global>;
	
public:
	virtual void Execute(Bomber* agent);
	virtual bool OnMessage(Bomber* agent, const Telegram& telegram);
	
private:
	BomberState_Global() {}
	BomberState_Global(const BomberState_Global&);
	virtual ~BomberState_Global() {}
	BomberState_Global& operator=(const BomberState_Global&);
};

// -------------------------------------------------------------------------------------

class BomberState_FollowPlayer : public State<Bomber>, public Singleton<BomberState_FollowPlayer>
{
	friend class Singleton<BomberState_FollowPlayer>;
	
public:
	virtual void Enter(Bomber* agent);
	virtual void Execute(Bomber* agent);
	
private:
	BomberState_FollowPlayer() {}
	BomberState_FollowPlayer(const BomberState_FollowPlayer&);
	virtual ~BomberState_FollowPlayer() {}
	BomberState_FollowPlayer& operator=(const BomberState_FollowPlayer&);
};

// -------------------------------------------------------------------------------------

class BomberState_Fire : public State<Bomber>, public Singleton<BomberState_Fire>
{
	friend class Singleton<BomberState_Fire>;
	
public:
	virtual void Enter(Bomber* agent);
	virtual void Execute(Bomber* agent);
	
private:
	BomberState_Fire() {}
	BomberState_Fire(const BomberState_Fire&);
	virtual ~BomberState_Fire() {}
	BomberState_Fire& operator=(const BomberState_Fire&);
};

// -------------------------------------------------------------------------------------

class BomberState_Dead : public State<Bomber>, public Singleton<BomberState_Dead>
{
	friend class Singleton<BomberState_Dead>;
	
public:
	virtual void Enter(Bomber* agent);
	virtual void Execute(Bomber* agent);
	
private:
	BomberState_Dead() {}
	BomberState_Dead(const BomberState_Dead&);
	virtual ~BomberState_Dead() {}
	BomberState_Dead& operator=(const BomberState_Dead&);
};

// -------------------------------------------------------------------------------------

#endif
