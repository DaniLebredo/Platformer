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

#ifndef LOADINGCONTROLLER_H
#define LOADINGCONTROLLER_H

#import "SceneControllerFSM.h"
#import "StdInclude.h"
#import "MessageDispatcher.h"
#import "SceneType.h"
#import "LoadingTypes.h"

@class LoadingScene;


class LoadingController : public SceneControllerFSM<LoadingController>
{
public:
	LoadingController(SceneType sceneType, int worldId, int levelId, LoadingMode mode, bool loadNewMusic);
	virtual ~LoadingController();
	
	LoadingMode Mode() const { return mMode; }
	
	void UpdateTimeElapsed() { mTimeElapsed += mDeltaTime; }
	ccTime TimeElapsed() const { return mTimeElapsed; }
	
	void LoadAssets();
	void ChangeScene();
	
	bool ShouldWaitUntilBackgroundMusicStops() const;
	
	virtual CustomScene* Scene() { return (CustomScene*)mScene; }
	
	virtual void OnSceneEntered();
	virtual void OnSceneExited() {}
	virtual void Update(ccTime dt);
	
	virtual int BackgroundMusicId() const { return 0; }
	
private:
	const SceneType mSceneType;
	
	const int mWorldId;
	const int mLevelId;
	
	const LoadingMode mMode;
	const bool mShouldStopMusic;
	
	ccTime mDeltaTime;
	ccTime mTimeElapsed;
	
	LoadingScene* mScene;
};

#endif
