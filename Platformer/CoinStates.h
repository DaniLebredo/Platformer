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

#ifndef COINSTATES_H
#define COINSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Coin;

// -------------------------------------------------------------------------------------

class CoinState_Global : public State<Coin>, public Singleton<CoinState_Global>
{
	friend class Singleton<CoinState_Global>;
	
public:
	virtual void Execute(Coin* agent);
	virtual bool OnMessage(Coin* agent, const Telegram& telegram);
	
private:
	CoinState_Global() {}
	CoinState_Global(const CoinState_Global&);
	virtual ~CoinState_Global() {}
	CoinState_Global& operator=(const CoinState_Global&);
};

// -------------------------------------------------------------------------------------

class CoinState_Normal : public State<Coin>, public Singleton<CoinState_Normal>
{
	friend class Singleton<CoinState_Normal>;
	
public:
	virtual void Enter(Coin* agent);
	virtual void Execute(Coin* agent);
	virtual void Exit(Coin* agent);
	virtual bool OnMessage(Coin* agent, const Telegram& telegram);
	
private:
	CoinState_Normal() {}
	CoinState_Normal(const CoinState_Normal&);
	virtual ~CoinState_Normal() {}
	CoinState_Normal& operator=(const CoinState_Normal&);
};

// -------------------------------------------------------------------------------------

class CoinState_Collected : public State<Coin>, public Singleton<CoinState_Collected>
{
	friend class Singleton<CoinState_Collected>;
	
public:
	virtual void Enter(Coin* agent);
	virtual void Execute(Coin* agent);
	
private:
	CoinState_Collected() {}
	CoinState_Collected(const CoinState_Collected&);
	virtual ~CoinState_Collected() {}
	CoinState_Collected& operator=(const CoinState_Collected&);
};

// -------------------------------------------------------------------------------------

#endif
