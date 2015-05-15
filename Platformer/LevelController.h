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

#ifndef LEVEL_H
#define LEVEL_H

#import "SceneControllerFSM.h"
#import "StdInclude.h"
#import "GameObjectManager.h"
#import "MessageDispatcher.h"
#import "GameObject.h"
#import "LevelType.h"

@class LevelScene;
class ContactListener;


class LevelController : public SceneControllerFSM<LevelController>
{
public:
	LevelController(int worldId, int levelId);
	virtual ~LevelController();
	
	bool IsBeingDestroyed() const { return mIsBeingDestroyed; }
	
	void SetPaused(bool paused) { mPaused = paused; }
	bool Paused() const { return mPaused; }
	
	// -----
	
	void ShowHUD();
	void HideHUD();
	void RefreshControlsInHUD();
	
	void HideGetReadyScreen();
	
	void ShowPauseScreen();
	void HidePauseScreen();
	void AnimatePauseScreen();
	
	void ShowLifeLostScreen();
	void AnimateLifeLostScreen();
	
	void ShowLevelCompleteScreen();
	void ShowWorldCompletedScreen();
	void ShowGameCompleteScreen();
	
	void ShowSettingsScreen();
	void HideSettingsScreen();
	void RefreshSettingsScreen();
	void AnimateSettingsScreen();
	
	void ShowControlsScreen();
	void HideControlsScreen();
	void ResetControls();
	void RefreshControlsScreen();
	void AnimateControlsScreen();
	
	// -----
	
	ccTime TimeElapsed() const { return mTimeElapsed; }
	ccTime TimeLeft() const { return mTimeLimit - mTimeElapsed; }
	
	void ResetReadyTimer() { mReadyTime = 0; }
	void UpdateReadyTimer() { mReadyTime += mDeltaTime; }
	ccTime ReadyTimerValue() const { return mReadyTime; }
	
	int NumCoinsCollected() const { return mNumCoinsCollected; }
	int NumCoinsToCollect() const { return mNumCoinsToCollect; }
	
	int NumLivesLeft();
	int NumLivesTotal();
	
	LevelType LvlType() const { return mLvlType; }
	
	int WorldId() const { return mWorldId; }
	int LevelId() const { return mLevelId; }
	
	int NextWorldId() const { return mNextWorldId; }
	int NextLevelId() const { return mNextLevelId; }
	
	GameObject* PlayerObj() { return mPlayer; }
	virtual CustomScene* Scene() { return (CustomScene*)mScene; }
	
	const GameObjectManager* GameObjMgr() const { return mGameObjManager; }
	const MessageDispatcher* MsgDispatcher() const { return mMsgDispatcher; }
	
	b2World* PhyWorld() { return mPhyWorld; }
	float PtmRatio() const { return mPtmRatio; }
	
	void AddGameObject(GameObject* gObj);
	
	void UpdateTimeElapsed();
	void UpdateAll();
	void UpdateStatusBar();
	
	void BreakUpdateLoop();
	
	void OnScoreChanged(int deltaScore);
	
	void CalculateNumStarsCollected();
	int NumStarsCollected() const { return mNumStarsCollected; }
	
	void PauseGameObjects();
	void ResumeGameObjects();
	void RefreshGameObjectTexts();
	
	void PostFacebookMessage();
	void PostTweet();
	
	void ShowLeaderboards();
	void ShowAchievements();
	
	virtual bool IsGCButtonPressed(GCButtonType gcButtonId, float value);
	
	virtual void OnSceneEntered();
	virtual void OnSceneExited();
	virtual void Update(ccTime dt);
	
	virtual void Pause();
	virtual void Resume();
	
	virtual int BackgroundMusicId() const { return 2; }
	
private:
	void calculateNextLevelAndWorldId();
	
	void initPhysics();
	void updateCamera(CGPoint targetPos, float lerpFactor = 0.1);
	void updatePhysics(ccTime dt);
	void updateGameObjects(ccTime dt);
	void removeDestroyedGameObjects();
	
	bool shouldCondenseTile(int type, int i, int j);
	void condenseTilesX();
	void condenseTilesXForType(int type);
	void condenseTilesY();
	void condenseTilesYForType(int type);
	void condenseOutline(const Point2iVector& outline, Point2iVector& condensedOutline);
	void removeOutlinedTiles(const Point2iVector& outline);
	void condenseRemainingTiles();
	
	void loadFrontTilesFromFile();
	void loadGameObjectsFromFile();
	void createGameObject(uint objType, CGPoint pos, NSDictionary* opt);
	
private:
	bool mIsBeingDestroyed;
	
	LevelType mLvlType;
	
	const int mWorldId;
	const int mLevelId;
	
	int mNextWorldId;
	int mNextLevelId;
	
	int mNumStarsCollected;
	
	LevelScene* mScene;
	
	// Tiles
	int mNumTilesX, mNumTilesY;			// dimensions of a level, i.e. width and height
	const int mNumVisibleTilesX;		// number of tiles in a viewport
	const int mNumVisibleTilesY;		// number of tiles in a viewport
	const int mTileSize;				// width and height of a tile (they're the same)
	TileList mTiles;
	IntVector mTileTypes;
	BoolVector mVisitedTiles;
	
	// Camera related
	bool mCameraFollowsPlayer;
	
	const CGFloat mMinDistanceX;		// min distance of player from left edge of the screen
	const CGFloat mMaxDistanceX;		// max distance of player from left edge of the screen
	const CGFloat mMinDistanceY;		// min distance of player from bottom edge of the screen
	const CGFloat mMaxDistanceY;		// max distance of player from bottom edge of the screen
	
	const CGFloat mLeftBoundary;		// leftmost allowed camera position
	CGFloat mRightBoundary;				// rightmost allowed camera position
	CGFloat mTopBoundary;				// topmost allowed camera position
	const CGFloat mBottomBoundary;		// bottommost allowed camera position
	
	// Game objects
	GameObject* mPlayer;
	GameObjList mGameObjsToAdd;
	GameObjectManager* mGameObjManager;
	MessageDispatcher* mMsgDispatcher;
	
	// Physics
	b2World* mPhyWorld;					// strong ref
	ContactListener* mContactListener;	// strong ref
	const float mPtmRatio;				// Needs to be declared AFTER mTileSize!
	ccTime mAccumulator;
	
	// Time
	ccTime mDeltaTime;					// Time passed since the last frame.
	ccTime mTimeElapsed;
	ccTime mTimeLimit;					// cached time limit from LevelData
	ccTime mReadyTime;					// time spent in GetReady state
	const ccTime mTimeStep;				// physics time step
	
	int mNumTickTocks;
	bool mTimeWarning;
	
	bool mPaused;
	bool mBreakUpdateLoop;
	
	// Coins
	int mNumCoinsCollected;
	int mNumCoinsToCollect;
};

#endif
