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

#ifndef SCENECONTROLLER_H
#define SCENECONTROLLER_H

#import "StdInclude.h"
#import "CustomScene.h"
#import "ButtonType.h"
#import "GCButtonType.h"
#import "Telegram.h"
#import "FocusDirection.h"
#import "Utility.h"

// SceneController is a representation of a scene in C++. It's purpose is to serve as a
// base class for all scene controllers.
//
// NOTE: Derived classes should contain all of the logic of a scene, and use a CustomScene
// object only as a proxy for things that have to be done in ObjC, e.g. composing a scene,
// scheduling a timer etc.


class SceneController
{
public:
	SceneController() {}
	virtual ~SceneController() {}
	
	virtual CustomScene* Scene() = 0;
	
	virtual void OnSceneEntered() = 0;
	virtual void OnSceneExited() = 0;

	virtual void OnButtonPressed(ButtonType buttonId, void* userData = NULL) {}
	virtual void OnButtonReleased(ButtonType buttonId, void* userData = NULL) {}
	virtual void OnButtonClicked(ButtonType buttonId, void* userData = NULL) {}
	
	virtual bool IsGCButtonPressed(GCButtonType gcButtonId, float value)
	{
		switch (gcButtonId)
		{
			case GCBtn_DPadLeft:
			case GCBtn_DPadDown:
			case GCBtn_LThumbLeft:
			case GCBtn_LThumbDown:
			case GCBtn_RThumbLeft:
			case GCBtn_RThumbDown:
			{
#ifdef ANDROID
				return value > 0.6;
#else
				if (IsOS8Supported())
					return value > 0.6;
				else return value < -0.6;
#endif
			}
				
			case GCBtn_DPadUp:
			case GCBtn_DPadRight:
			case GCBtn_LThumbUp:
			case GCBtn_LThumbRight:
			case GCBtn_RThumbUp:
			case GCBtn_RThumbRight:
			{
				return value > 0.6;
			}
				
			default:
			{
				return value > 0;
			}
		}
	}
	
	virtual ButtonType TranslateGCButtonToButton(GCButtonType gcButtonId)
	{
		switch (gcButtonId)
		{
			case GCBtn_DPadUp:
			case GCBtn_LThumbUp:
			case GCBtn_RThumbUp:
			{
				return Btn_Up;
			}
				
			case GCBtn_DPadDown:
			case GCBtn_LThumbDown:
			case GCBtn_RThumbDown:
			{
				return Btn_Down;
			}
				
			case GCBtn_DPadLeft:
			case GCBtn_LThumbLeft:
			case GCBtn_RThumbLeft:
			{
				return Btn_Left;
			}
				
			case GCBtn_DPadRight:
			case GCBtn_LThumbRight:
			case GCBtn_RThumbRight:
			{
				return Btn_Right;
			}
				
			case GCBtn_ButtonA:
			{
				return Btn_A;
			}
				
			case GCBtn_ButtonB:
			case GCBtn_ButtonX:
			{
				return Btn_B;
			}
				
			default:
			{
				return Btn_Invalid;
			}
		}
	}
	
	void MoveFocus(FocusDirection focusDirection)
	{
		[this->Scene() moveFocus:focusDirection];
	}
	
	void ApplyMoveFocus()
	{
		[this->Scene() applyMoveFocus];
	}
	
	void ClickFocusedButton()
	{
		[this->Scene() clickFocusedButton];
	}
	
	virtual void Update(ccTime dt) {}
	virtual void Pause() {};
	virtual void Resume() {};
	
	virtual bool HandleMessage(const Telegram& msg) { return false; }
	
	virtual void OnControllerStateChanged() {}
	
	virtual void OnProductValidationCompleted(bool success) {}
	virtual void OnRestoreTransactionsCompleted(bool success) {}
	virtual void OnTransactionCompleted(bool success) {}
	
	virtual int BackgroundMusicId() const { return 0; }
};

#endif
