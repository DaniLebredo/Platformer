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

#ifndef MAINMENUCONTROLLER_H
#define MAINMENUCONTROLLER_H

#import "SceneControllerFSM.h"
#import "StdInclude.h"
#import "MessageDispatcher.h"

@class MainMenuScene;


class MainMenuController : public SceneControllerFSM<MainMenuController>
{
public:
	MainMenuController();
	virtual ~MainMenuController();
	
	void ShowSplashScreen();
	void HideSplashScreen();
	
	void ShowCreditsScreen();
	void HideCreditsScreen();
	void AnimateCreditsScreen();
	
	void ShowQuitScreen();
	void HideQuitScreen();
	void AnimateQuitScreen();
	
	void ShowSettingsScreen();
	void HideSettingsScreen();
	void RefreshSettingsScreen();
	void AnimateSettingsScreen();
	
	void ShowControlsScreen();
	void HideControlsScreen();
	void ResetControls();
	void RefreshControlsScreen();
	void AnimateControlsScreen();
	
	void ShowLeaderboards();
	void ShowAchievements();
	
	virtual CustomScene* Scene() { return (CustomScene*)mScene; }
	
	virtual void OnSceneEntered();
	virtual void OnSceneExited() {}
	
	virtual int BackgroundMusicId() const { return 1; }
	
private:
	MainMenuScene* mScene;
};

#endif
