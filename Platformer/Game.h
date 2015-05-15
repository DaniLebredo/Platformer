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

#ifndef GAME_H
#define GAME_H

#import "StdInclude.h"
#import "SoundManager.h"
#import "Utility.h"
#import "Singleton.h"
#import "SceneController.h"
#import "GameData.h"
#import "Repository.h"
#import "PhyBodyTemplate.h"
#import "FrameAnimData.h"
#import "SceneType.h"
#import "LoadingTypes.h"


enum DistributableType
{
	Distributable_None = 0,
	Distributable_AdHoc,
	Distributable_AppStore
};

class Game : public Singleton<Game>
{
	friend class Singleton<Game>;
	
public:
	void Initialize();
	void OnUpdate(ccTime dt);
	void OnPostUpdate();
	
	DistributableType Distributable() const { return mDistributable; }
	bool DebugOn() const { return mDebugOn; }
	
	void SetMusicOn(bool musicOn);
	bool MusicOn() const { return mMusicOn; }
	
	void SetSoundOn(bool soundOn) { mSoundOn = soundOn; }
	bool SoundOn() const { return mSoundOn; }
	
	void SetWorldId(int worldId) { mWorldIndex = worldId; } // This is temporary! Maybe should be renamed to SetLastSelectedWorld.
	int WorldId() const { return mWorldIndex; }
	int LevelId() const { return mLevelIndex; }
	
	// Scene selection.
	void GoToMenu();
	void GoToLevelSelect(int centeredWorldId, int levelId = -1);
	void GoToLevel(int worldId, int levelId);
	void GoToLoading(SceneType sceneType, int worldId, int levelId, LoadingMode mode = Loading_TextMessage, bool stopMusic = true);
	
	SceneController* ActiveSceneController() { return mSceneController; }
	
	void OnSceneEntered(SceneController* scene);
	void OnSceneExited(SceneController* scene);
	
	void OnControllerStateChanged();
	
	void OnProductValidationCompleted(bool success);
	void OnRestoreTransactionsCompleted(bool success);
	void OnTransactionCompleted(bool success);
	
	void Pause();
	void Resume();
	
	// Music
	void PlayBackgroundMusic();
	void StopBackgroundMusic();
	void PreloadBackgroundMusic();
	
	void LoadStats();
	void SaveStats();
	
	// Loading configuration from JSON files.
	void LoadConfigurationFromFile(const std::string& filename);
	
	// Game data
	GameData& Data() { return mGameData; }
	
	// Controls
	void SetUseGestures(bool useGestures) { mUseGestures = useGestures; }
	bool UseGestures() const { return mUseGestures; }
	CGFloat Quant() const { return mQuant; }
	CGFloat ControlButtonWidth() const { return mControlButtonWidth; }
	void SetControlPosition(const std::string& name, const CGPoint& pos) { mControlsPos[name] = pos; }
	CGPoint ControlPosition(const std::string& name) { return mControlsPos[name]; }
	CGPoint OrigControlPosition(const std::string& name) { return mOrigControlsPos[name]; }
	
private:
	Game();
	Game(const Game&);
	~Game();
	Game& operator=(const Game&);
	
	void initCustomShaders();
	
	void deleteExitedScenes();
	void setActiveScene(SceneController* sceneController, float transitionDuration = 0.4);
	
	void parseControl(const Json::Value& controlObject, CGPoint& p);
	void parseStats(const Json::Value& stats);
	
	int mBackgroundMusicId;
	
	SceneController* mSceneController;
	SceneList mExitedScenes;
	
	// Options
	DistributableType mDistributable;
	bool mDebugOn;
	bool mMusicOn;
	bool mSoundOn;
	
	// Stats
	int mWorldIndex;
	int mLevelIndex;
	
	GameData mGameData;
	
	bool mUseGestures;
	CGFloat mQuant;
	CGFloat mControlButtonWidth;
	std::map<std::string, CGPoint> mControlsPos;
	std::map<std::string, CGPoint> mOrigControlsPos;
	
	bool mInitialized;
};

#endif
