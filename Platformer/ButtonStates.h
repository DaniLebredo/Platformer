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

#ifndef BUTTONSTATES_H
#define BUTTONSTATES_H

#import "State.h"
#import "Singleton.h"
#import "CommonStates.h"

class Button;

// -------------------------------------------------------------------------------------

class ButtonState_Global : public State<Button>, public Singleton<ButtonState_Global>
{
	friend class Singleton<ButtonState_Global>;
	
public:
	virtual void Execute(Button* agent);
	
private:
	ButtonState_Global() {}
	ButtonState_Global(const ButtonState_Global&);
	virtual ~ButtonState_Global() {}
	ButtonState_Global& operator=(const ButtonState_Global&);
};

// -------------------------------------------------------------------------------------

class ButtonState_Normal : public State<Button>, public Singleton<ButtonState_Normal>
{
	friend class Singleton<ButtonState_Normal>;
	
public:
	virtual void Enter(Button* agent);
	virtual void Execute(Button* agent);
	virtual bool OnMessage(Button* agent, const Telegram& telegram);
	
private:
	ButtonState_Normal() {}
	ButtonState_Normal(const ButtonState_Normal&);
	virtual ~ButtonState_Normal() {}
	ButtonState_Normal& operator=(const ButtonState_Normal&);
};

// -------------------------------------------------------------------------------------

class ButtonState_Pushed : public State<Button>, public Singleton<ButtonState_Pushed>
{
	friend class Singleton<ButtonState_Pushed>;
	
public:
	virtual void Enter(Button* agent);
	virtual void Execute(Button* agent);
	
private:
	ButtonState_Pushed() {}
	ButtonState_Pushed(const ButtonState_Pushed&);
	virtual ~ButtonState_Pushed() {}
	ButtonState_Pushed& operator=(const ButtonState_Pushed&);
};

// -------------------------------------------------------------------------------------

#endif
