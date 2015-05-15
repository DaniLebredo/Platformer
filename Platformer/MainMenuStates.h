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

#ifndef MAINMENUSTATES_H
#define MAINMENUSTATES_H

#import "State.h"
#import "Singleton.h"

class MainMenuController;

// -------------------------------------------------------------------------------------

class MainMenuState_Global : public State<MainMenuController>, public Singleton<MainMenuState_Global>
{
	friend class Singleton<MainMenuState_Global>;
	
public:
	virtual void Execute(MainMenuController* agent);
	virtual bool OnMessage(MainMenuController* agent, const Telegram& telegram);
	
private:
	MainMenuState_Global() {}
	MainMenuState_Global(const MainMenuState_Global&);
	virtual ~MainMenuState_Global() {}
	MainMenuState_Global& operator=(const MainMenuState_Global&);
};

// -------------------------------------------------------------------------------------

class MainMenuState_EnterTransition : public State<MainMenuController>, public Singleton<MainMenuState_EnterTransition>
{
	friend class Singleton<MainMenuState_EnterTransition>;
	
public:
	virtual void Enter(MainMenuController* agent);
	virtual bool OnMessage(MainMenuController* agent, const Telegram& telegram);
	
private:
	MainMenuState_EnterTransition() {}
	MainMenuState_EnterTransition(const MainMenuState_EnterTransition&);
	virtual ~MainMenuState_EnterTransition() {}
	MainMenuState_EnterTransition& operator=(const MainMenuState_EnterTransition&);
};

// -------------------------------------------------------------------------------------

class MainMenuState_Normal : public State<MainMenuController>, public Singleton<MainMenuState_Normal>
{
	friend class Singleton<MainMenuState_Normal>;
	
public:
	virtual void Enter(MainMenuController* agent);
	virtual void Exit(MainMenuController* agent);
	virtual bool OnMessage(MainMenuController* agent, const Telegram& telegram);
	
private:
	MainMenuState_Normal() {}
	MainMenuState_Normal(const MainMenuState_Normal&);
	virtual ~MainMenuState_Normal() {}
	MainMenuState_Normal& operator=(const MainMenuState_Normal&);
};

// -------------------------------------------------------------------------------------

class MainMenuState_Credits : public State<MainMenuController>, public Singleton<MainMenuState_Credits>
{
	friend class Singleton<MainMenuState_Credits>;
	
public:
	virtual void Enter(MainMenuController* agent);
	virtual void Exit(MainMenuController* agent);
	virtual bool OnMessage(MainMenuController* agent, const Telegram& telegram);
	
private:
	MainMenuState_Credits() {}
	MainMenuState_Credits(const MainMenuState_Credits&);
	virtual ~MainMenuState_Credits() {}
	MainMenuState_Credits& operator=(const MainMenuState_Credits&);
};

// -------------------------------------------------------------------------------------

class MainMenuState_Quit : public State<MainMenuController>, public Singleton<MainMenuState_Quit>
{
	friend class Singleton<MainMenuState_Quit>;
	
public:
	virtual void Enter(MainMenuController* agent);
	virtual void Exit(MainMenuController* agent);
	virtual bool OnMessage(MainMenuController* agent, const Telegram& telegram);
	
private:
	MainMenuState_Quit() {}
	MainMenuState_Quit(const MainMenuState_Quit&);
	virtual ~MainMenuState_Quit() {}
	MainMenuState_Quit& operator=(const MainMenuState_Quit&);
};

// -------------------------------------------------------------------------------------

class MainMenuState_Settings : public State<MainMenuController>, public Singleton<MainMenuState_Settings>
{
	friend class Singleton<MainMenuState_Settings>;
	
public:
	virtual void Enter(MainMenuController* agent);
	virtual void Exit(MainMenuController* agent);
	virtual bool OnMessage(MainMenuController* agent, const Telegram& telegram);
	
private:
	MainMenuState_Settings() {}
	MainMenuState_Settings(const MainMenuState_Settings&);
	virtual ~MainMenuState_Settings() {}
	MainMenuState_Settings& operator=(const MainMenuState_Settings&);
};

// -------------------------------------------------------------------------------------

class MainMenuState_Controls : public State<MainMenuController>, public Singleton<MainMenuState_Controls>
{
	friend class Singleton<MainMenuState_Controls>;
	
public:
	virtual void Enter(MainMenuController* agent);
	virtual void Exit(MainMenuController* agent);
	virtual bool OnMessage(MainMenuController* agent, const Telegram& telegram);
	
private:
	MainMenuState_Controls() {}
	MainMenuState_Controls(const MainMenuState_Controls&);
	virtual ~MainMenuState_Controls() {}
	MainMenuState_Controls& operator=(const MainMenuState_Controls&);
};

// -------------------------------------------------------------------------------------

#endif
