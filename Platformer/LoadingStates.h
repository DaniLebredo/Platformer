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

#ifndef LOADINGSTATES_H
#define LOADINGSTATES_H

#import "State.h"
#import "Singleton.h"

class LoadingController;

// -------------------------------------------------------------------------------------

class LoadingState_Global : public State<LoadingController>, public Singleton<LoadingState_Global>
{
	friend class Singleton<LoadingState_Global>;
	
public:
	virtual void Execute(LoadingController* agent);
	virtual bool OnMessage(LoadingController* agent, const Telegram& telegram);
	
private:
	LoadingState_Global() {}
	LoadingState_Global(const LoadingState_Global&);
	virtual ~LoadingState_Global() {}
	LoadingState_Global& operator=(const LoadingState_Global&);
};

// -------------------------------------------------------------------------------------

class LoadingState_EnterTransition : public State<LoadingController>, public Singleton<LoadingState_EnterTransition>
{
	friend class Singleton<LoadingState_EnterTransition>;
	
public:
	virtual void Enter(LoadingController* agent);
	virtual bool OnMessage(LoadingController* agent, const Telegram& telegram);
	
private:
	LoadingState_EnterTransition() {}
	LoadingState_EnterTransition(const LoadingState_EnterTransition&);
	virtual ~LoadingState_EnterTransition() {}
	LoadingState_EnterTransition& operator=(const LoadingState_EnterTransition&);
};

// -------------------------------------------------------------------------------------

class LoadingState_LoadAssets : public State<LoadingController>, public Singleton<LoadingState_LoadAssets>
{
	friend class Singleton<LoadingState_LoadAssets>;
	
public:
	virtual void Enter(LoadingController* agent);
	virtual void Execute(LoadingController* agent);
	virtual void Exit(LoadingController* agent);
	virtual bool OnMessage(LoadingController* agent, const Telegram& telegram);
	
private:
	LoadingState_LoadAssets() {}
	LoadingState_LoadAssets(const LoadingState_LoadAssets&);
	virtual ~LoadingState_LoadAssets() {}
	LoadingState_LoadAssets& operator=(const LoadingState_LoadAssets&);
};

// -------------------------------------------------------------------------------------

class LoadingState_Wait : public State<LoadingController>, public Singleton<LoadingState_Wait>
{
	friend class Singleton<LoadingState_Wait>;
	
public:
	virtual void Enter(LoadingController* agent);
	virtual void Execute(LoadingController* agent);
	virtual void Exit(LoadingController* agent);
	virtual bool OnMessage(LoadingController* agent, const Telegram& telegram);
	
private:
	LoadingState_Wait() {}
	LoadingState_Wait(const LoadingState_Wait&);
	virtual ~LoadingState_Wait() {}
	LoadingState_Wait& operator=(const LoadingState_Wait&);
};

// -------------------------------------------------------------------------------------

class LoadingState_ChangeScene : public State<LoadingController>, public Singleton<LoadingState_ChangeScene>
{
	friend class Singleton<LoadingState_ChangeScene>;
	
public:
	virtual void Enter(LoadingController* agent);
	virtual void Exit(LoadingController* agent);
	virtual bool OnMessage(LoadingController* agent, const Telegram& telegram);
	
private:
	LoadingState_ChangeScene() {}
	LoadingState_ChangeScene(const LoadingState_ChangeScene&);
	virtual ~LoadingState_ChangeScene() {}
	LoadingState_ChangeScene& operator=(const LoadingState_ChangeScene&);
};

// -------------------------------------------------------------------------------------

#endif
