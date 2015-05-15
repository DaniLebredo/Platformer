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

#ifndef ENEMYSTATES_H
#define ENEMYSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Enemy;

// -------------------------------------------------------------------------------------

class EnemyState_Global : public State<Enemy>, public Singleton<EnemyState_Global>
{
	friend class Singleton<EnemyState_Global>;
	
public:
	virtual void Execute(Enemy* agent);
	virtual bool OnMessage(Enemy* agent, const Telegram& telegram);
	
private:
	EnemyState_Global() {}
	EnemyState_Global(const EnemyState_Global&);
	virtual ~EnemyState_Global() {}
	EnemyState_Global& operator=(const EnemyState_Global&);
};

// -------------------------------------------------------------------------------------
class EnemyState_Walk : public State<Enemy>, public Singleton<EnemyState_Walk>
{
	friend class Singleton<EnemyState_Walk>;
	
public:
	virtual void Enter(Enemy* agent);
	virtual void Execute(Enemy* agent);
	virtual void Exit(Enemy* agent);
	
private:
	EnemyState_Walk() {}
	EnemyState_Walk(const EnemyState_Walk&);
	virtual ~EnemyState_Walk() {}
	EnemyState_Walk& operator=(const EnemyState_Walk&);
};

// -------------------------------------------------------------------------------------

class EnemyState_Fire : public State<Enemy>, public Singleton<EnemyState_Fire>
{
	friend class Singleton<EnemyState_Fire>;
	
public:
	virtual void Enter(Enemy* agent);
	virtual void Execute(Enemy* agent);
	
private:
	EnemyState_Fire() {}
	EnemyState_Fire(const EnemyState_Fire&);
	virtual ~EnemyState_Fire() {}
	EnemyState_Fire& operator=(const EnemyState_Fire&);
};

// -------------------------------------------------------------------------------------

class EnemyState_Dead : public State<Enemy>, public Singleton<EnemyState_Dead>
{
	friend class Singleton<EnemyState_Dead>;
	
public:
	virtual void Enter(Enemy* agent);
	virtual void Execute(Enemy* agent);
	virtual bool OnMessage(Enemy* agent, const Telegram& telegram);
	
private:
	EnemyState_Dead() {}
	EnemyState_Dead(const EnemyState_Dead&);
	virtual ~EnemyState_Dead() {}
	EnemyState_Dead& operator=(const EnemyState_Dead&);
};

// -------------------------------------------------------------------------------------

class EnemyState_Drowned : public State<Enemy>, public Singleton<EnemyState_Drowned>
{
	friend class Singleton<EnemyState_Drowned>;
	
public:
	virtual void Enter(Enemy* agent);
	virtual void Execute(Enemy* agent);
	virtual bool OnMessage(Enemy* agent, const Telegram& telegram);
	
private:
	EnemyState_Drowned() {}
	EnemyState_Drowned(const EnemyState_Drowned&);
	virtual ~EnemyState_Drowned() {}
	EnemyState_Drowned& operator=(const EnemyState_Drowned&);
};

// -------------------------------------------------------------------------------------

#endif
