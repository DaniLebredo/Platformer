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

#import "LevelController.h"
#import "LevelStates.h"
#import "LevelScene.h"

#import "GameObject.h"
#import "Tile.h"
#import "PlayerNormal.h"
#import "PlayerGravity.h"
#import "EndOfLevel.h"
#import "Enemy.h"
#import "FatBoy.h"
#import "Coin.h"
#import "Platform.h"
#import "Cannon.h"
#import "Barrel.h"
#import "CrackedTile.h"
#import "Button.h"
#import "Bomber.h"
#import "Pendulum.h"
#import "Stomper.h"
#import "Sign.h"
#import "ConcreteSlab.h"
#import "RunningMan.h"
#import "Key.h"
#import "Door.h"
#import "Explosion.h"
#import "Flyer.h"
#import "Jumper.h"
#import "Fish.h"
#import "Spider.h"
#import "Boulder.h"
#import "Hedgehog.h"
#import "Water.h"

#import "Game.h"
#import "ContactListener.h"
#import "MarchingSquare.h"
#import "GCManager.h"


LevelController::LevelController(int worldId, int levelId) :
	mIsBeingDestroyed(false),
	mPaused(false),
	mBreakUpdateLoop(false),
	mWorldId(worldId),
	mLevelId(levelId),
	mNextWorldId(-1),
	mNextLevelId(-1),
	mNumStarsCollected(0),
	mTimeElapsed(0),
	mNumVisibleTilesX(23), // Maybe this number should be different for iPhone, iPhone 5 and iPad? But careful, it affects on/offscreen.
	mNumVisibleTilesY(16), // This number, too.
	mTileSize(PNGMakeFloat(26)),
	mCameraFollowsPlayer(true),
	mMinDistanceX(PNGMakeFloat(200)),
	mMaxDistanceX(PNGMakeFloat(235)),
	mMinDistanceY(PNGMakeFloat(150)),
	mMaxDistanceY(PNGMakeFloat(200)),
	mLeftBoundary(0),
	mBottomBoundary(0),
	mPtmRatio(mTileSize),
	mAccumulator(0),
	mTimeStep(1.0 / 60), // Physics runs at 60 Hz.
	mDeltaTime(0),
	mReadyTime(0),
	mNumTickTocks(8),
	mTimeWarning(false),
	mPlayer(NULL),
	mNumCoinsCollected(0),
	mNumCoinsToCollect(0)
{
	assert(mPtmRatio > 0 && "<LevelController::ctor>: Invalid PTM ratio.");
	
	CCLOG(@"LEVEL %d-%d", mWorldId + 1, mLevelId + 1);
	
	GameData& gameData = Game::Instance()->Data();
	WorldData& currWorld = gameData.World(mWorldId);
	LevelData& currLevel = currWorld.Level(mLevelId);
	
	mLvlType = currLevel.Type();
	mTimeLimit = currLevel.Time();
	
	mGameObjManager = new GameObjectManager(true);
	mMsgDispatcher = new MessageDispatcher(mGameObjManager);
	
	initPhysics();
	mScene = [[LevelScene alloc] initWithLevelController:this]; // Needs to be called after initPhysics!
	
	// Read data from TMX file
	loadFrontTilesFromFile();
	loadGameObjectsFromFile();
	
	assert(mPlayer != NULL && "<LevelController::ctor>: PLAYER not found on this map.");
	
	// Camera related
	mRightBoundary = -mTileSize * (mNumTilesX - mNumVisibleTilesX);
	mTopBoundary = -mTileSize * (mNumTilesY - mNumVisibleTilesY);
	
	updateCamera(mPlayer->Node().position, 1);
	
	calculateNextLevelAndWorldId();
	
	State<LevelController>* startState = LevelState_EnterTransition::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(LevelState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
	
	UpdateStatusBar();
}

LevelController::~LevelController()
{
	CCLOG(@"DEALLOC: LevelController");
	
	mIsBeingDestroyed = true;
	
	// Clean up tiles.
	for (TileList::iterator it = mTiles.begin(); it != mTiles.end(); ++it)
	{
		delete *it;
	}
	mTiles.clear();
	
	// Clean up game objects.
	for (GameObjList::iterator it = mGameObjsToAdd.begin(); it != mGameObjsToAdd.end(); ++it)
	{
		delete *it;
	}
	mGameObjsToAdd.clear();
	
	delete mMsgDispatcher;
	mMsgDispatcher = NULL;
	
	delete mGameObjManager;
	mGameObjManager = NULL;
	
	mPlayer = NULL; // Cleaned automatically by GameObjectManager.
	
	[mScene release]; // Needs to be called before physics gets destroyed, but after all the game objects have already been destroyed.
	
	// Clean up physics.
	delete mPhyWorld;
	mPhyWorld = NULL;
	
	delete mContactListener;
	mContactListener = NULL;
	
	CCLOG(@"END DEALLOC: LevelController");
}

void LevelController::initPhysics()
{
	float m = 32.0F / 26.0F;
	b2Vec2 gravity(0, -30);
	// b2Vec2 gravity = b2Vec2_zero;
	mPhyWorld = new b2World(m * gravity);
	
	mPhyWorld->SetAllowSleeping(true);
	mPhyWorld->SetContinuousPhysics(true);
	
	mContactListener = new ContactListener(this);
	mPhyWorld->SetContactListener(mContactListener);
}

void LevelController::AddGameObject(GameObject* gObj)
{
	mGameObjsToAdd.push_back(gObj);
	[mScene addGameObject:gObj];
}

void LevelController::removeDestroyedGameObjects()
{
	GameObjList gameObjsToRemove;
	
	for (GameObjList::const_iterator it = mGameObjManager->Begin(); it != mGameObjManager->End(); ++it)
	{
		GameObject* gObj = *it;
		
		if (gObj->Destroyed()) gameObjsToRemove.push_back(gObj);
	}
	
	mGameObjManager->RemoveGameObjectList(gameObjsToRemove);
}

void LevelController::updateCamera(CGPoint targetPos, float lerpFactor)
{
	CGFloat distanceX = mScene.actionLayer.position.x + targetPos.x;
	CGFloat distanceY = mScene.actionLayer.position.y + targetPos.y;
	
	if (distanceX < mMinDistanceX || distanceX > mMaxDistanceX)
	{
		distanceX = clampf(distanceX, mMinDistanceX, mMaxDistanceX);
		
		CGFloat newX = clampf(distanceX - targetPos.x, mRightBoundary, mLeftBoundary);
		CGFloat lerpNewX = roundf(Lerp(mScene.actionLayer.position.x, newX, lerpFactor));
		//CGFloat lerpNewX = Lerp(mScene.actionLayer.position.x, newX, lerpFactor);
		
		mScene.actionLayer.position = ccp(lerpNewX, mScene.actionLayer.position.y);
		mScene.scrollableLayer.position = ccp(ceilf(0.2 * mScene.actionLayer.position.x), mScene.scrollableLayer.position.y);
		[mScene.scrollableLayer refresh];
	}
	
	if (distanceY < mMinDistanceY || distanceY > mMaxDistanceY)
	{
		distanceY = clampf(distanceY, mMinDistanceY, mMaxDistanceY);
		
		CGFloat newY = clampf(distanceY - targetPos.y, mTopBoundary, mBottomBoundary);
		CGFloat lerpNewY = roundf(Lerp(mScene.actionLayer.position.y, newY, lerpFactor));
		//CGFloat lerpNewY = Lerp(mScene.actionLayer.position.y, newY, lerpFactor);
		
		mScene.actionLayer.position = ccp(mScene.actionLayer.position.x, lerpNewY);
		mScene.scrollableLayer.position = ccp(mScene.scrollableLayer.position.x, ceilf(0.1 * mScene.actionLayer.position.y));
	}
}

void LevelController::updatePhysics(ccTime dt)
{
	//CCLOG(@"dt = %f", dt);
	int32 velocityIterations = 8;
	int32 positionIterations = 3;
	
	mPhyWorld->Step(dt, velocityIterations, positionIterations);
}

void LevelController::updateGameObjects(ccTime dt)
{
	// Add new game objects.
	mGameObjManager->AddGameObjectList(mGameObjsToAdd);
	
	for (GameObjList::const_iterator it = mGameObjsToAdd.begin(); it != mGameObjsToAdd.end(); ++it)
	{
		mMsgDispatcher->DispatchMsg(ID_IRRELEVANT, (*it)->ID(), Msg_GameObjAddedToScene, NULL);
	}
	
	mGameObjsToAdd.clear();
	
	// Update game objects.
	for (GameObjList::const_iterator it = mGameObjManager->Begin(); it != mGameObjManager->End(); ++it)
	{
		GameObject* gObj = *it;
		
		gObj->Update(dt);
		
		CGFloat deltaX = gObj->Node().position.x + mScene.actionLayer.position.x;
		CGFloat deltaY = gObj->Node().position.y + mScene.actionLayer.position.y;
		
		// Vertically we give a bit more offscreen space to game objects than horizontally.
		int numMarginTilesX = 4;
		int numMarginTilesY = 5;
		
		// These GameObjects go offscreen sooner than others. That's because they move a lot and
		// interact with other surfaces. So, we put them to sleep first, and then we can deal with
		// other objects with which these ones interact.
		if (gObj->IsEnemy() || gObj->Class() == "Boulder")
		{
			numMarginTilesX -= 2;
			numMarginTilesY -= 2;
		}
		
		if (deltaX + gObj->Right()	< -numMarginTilesX * mTileSize ||
			deltaY + gObj->Top()	< -numMarginTilesY * mTileSize ||
			deltaX - gObj->Left()	> (numMarginTilesX + mNumVisibleTilesX) * mTileSize ||
			deltaY - gObj->Bottom()	> (numMarginTilesY + mNumVisibleTilesY) * mTileSize)
		{
			mMsgDispatcher->DispatchMsg(ID_IRRELEVANT, gObj->ID(), Msg_WentOffScreen, NULL);
		}
		else
		{
			mMsgDispatcher->DispatchMsg(ID_IRRELEVANT, gObj->ID(), Msg_WentOnScreen, NULL);
		}
	}
	
	updatePhysics(dt);
	removeDestroyedGameObjects();
}

void LevelController::RefreshSettingsScreen()
{
	[mScene refreshSettings];
}

void LevelController::RefreshControlsScreen()
{
	[mScene refreshControls];
}

void LevelController::RefreshGameObjectTexts()
{
	for (GameObjList::const_iterator it = mGameObjManager->Begin(); it != mGameObjManager->End(); ++it)
	{
		GameObject* gObj = *it;
		
		if (gObj->Class() == "Sign")
		{
			mMsgDispatcher->DispatchMsg(ID_IRRELEVANT, gObj->ID(), Msg_LanguageChanged, NULL);
		}
	}
}

void LevelController::UpdateStatusBar()
{
	[mScene updateStatusBar];
}

void LevelController::UpdateTimeElapsed()
{
	mTimeElapsed += mDeltaTime;
	
	if (TimeLeft() <= 0)
	{
		CCLOG(@">>>>>>>>>> TIME UP");
		SoundManager::Instance()->ScheduleEffect("Cuckoo.caf");
	}
	else if (ceilf(TimeLeft()) <= mNumTickTocks)
	{
		--mNumTickTocks;
		
		//SoundManager::Instance()->ScheduleEffect("Tick.caf");
		
		/*
		if (mNumTickTocks % 2 == 0)
			SoundManager::Instance()->ScheduleEffect("Tick.caf");
		else SoundManager::Instance()->ScheduleEffect("Tock.caf");
		 */
		
		if (!mTimeWarning)
		{
			mTimeWarning = true;
			SoundManager::Instance()->ScheduleEffect("TickTock.caf");
		}
	}
}

void LevelController::UpdateAll()
{
	mAccumulator += mDeltaTime;
	
	while (mAccumulator >= mTimeStep)
	{
		updateGameObjects(mTimeStep);
		mAccumulator -= mTimeStep;
		
		if (mBreakUpdateLoop)
		{
			CCLOG(@"Breaking update loop... Accumulator = %f", mAccumulator);
			mAccumulator = 0;
			break;
		}
	}
	
	// temp
	//mScene.position = ccp(150, 0);
	
	UpdateStatusBar(); // Should this be called each time step???
	
	if (mCameraFollowsPlayer)
		updateCamera(mPlayer->Node().position);
	
	// Redraw all the objects.
	float t = mAccumulator / mTimeStep;
	for (GameObjList::const_iterator it = mGameObjManager->Begin(); it != mGameObjManager->End(); ++it)
	{
		GameObject* gObj = *it;
		gObj->UpdateDraw(t);
	}
}

void LevelController::BreakUpdateLoop()
{
	mBreakUpdateLoop = true;
}

void LevelController::OnScoreChanged(int deltaScore)
{
	mNumCoinsCollected += deltaScore;
	UpdateStatusBar();
}

void LevelController::calculateNextLevelAndWorldId()
{
	GameData& gameData = Game::Instance()->Data();
	WorldData& currWorld = gameData.World(mWorldId);
	
	if (mLevelId + 1 < currWorld.NumLevels())
	{
		mNextWorldId = mWorldId;
		mNextLevelId = mLevelId + 1;
	}
	else if (mWorldId + 1 < gameData.NumWorlds())
	{
		mNextWorldId = mWorldId + 1;
		mNextLevelId = 0;
	}
	else
	{
		// Finished entire game!
		mNextWorldId = -1;
		mNextLevelId = -1;
	}
}

int LevelController::NumLivesLeft()
{
	int health = 0;
	
	switch (mLvlType)
	{
		case Level_Normal:
		{
			PlayerNormal* player = static_cast<PlayerNormal*>(PlayerObj());
			health = player->Health();
		}
			break;
			
		case Level_Gravity:
		{
			PlayerGravity* player = static_cast<PlayerGravity*>(PlayerObj());
			health = player->Health();
		}
			break;
			
		default:
			break;
	}
	
	return health;
}

int LevelController::NumLivesTotal()
{
	// This is a quick'n'dirty hack. It should probably be done like NumLivesLeft().
	return 3;
}

void LevelController::CalculateNumStarsCollected()
{
	bool maxHealth = false;
	
	switch (mLvlType)
	{
		case Level_Normal:
		{
			PlayerNormal* player = static_cast<PlayerNormal*>(PlayerObj());
			maxHealth = player->Health() == 3;
		}
			break;
			
		case Level_Gravity:
		{
			PlayerGravity* player = static_cast<PlayerGravity*>(PlayerObj());
			maxHealth = player->Health() == 1;
		}
			break;
			
		default:
			break;
	}
	
	mNumStarsCollected = 0;
	
	if (mNumCoinsCollected == mNumCoinsToCollect) ++mNumStarsCollected;
	if (TimeLeft() > 0) ++mNumStarsCollected;
	if (maxHealth) ++mNumStarsCollected;
}

bool LevelController::IsGCButtonPressed(GCButtonType gcButtonId, float value)
{
	if (this->FSM()->IsInState(LevelState_Normal::Instance()))
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
				return value > 0;
#else
				if (IsOS8Supported())
					return value > 0;
				else return value < 0;
#endif
			}
			
			default:
			{
				return value > 0;
			}
		}
	}
	else
	{
		return SceneController::IsGCButtonPressed(gcButtonId, value);
	}
}

void LevelController::OnSceneEntered()
{
	[mScene.actionLayer.tileMap startAllLayers];
	
	Telegram telegram(ID_IRRELEVANT, ID_IRRELEVANT, Msg_SceneEntered, NULL);
	HandleMessage(telegram);
}

void LevelController::OnSceneExited()
{
}

void LevelController::Update(ccTime dt)
{
	mDeltaTime = dt;
	SceneControllerFSM::Update(dt);
}

void LevelController::Pause()
{
	mPaused = true;
	SceneControllerFSM::Pause();
}

void LevelController::Resume()
{
	mPaused = false;
	SceneControllerFSM::Resume();
}

void LevelController::PauseGameObjects()
{
	[mScene.actionLayer.tileMap pauseAllLayers];
	
	for (GameObjList::const_iterator it = mGameObjManager->Begin(); it != mGameObjManager->End(); ++it)
	{
		GameObject* gObj = *it;
		gObj->Pause();
	}
}

void LevelController::ResumeGameObjects()
{
	[mScene.actionLayer.tileMap resumeAllLayers];
	
	for (GameObjList::const_iterator it = mGameObjManager->Begin(); it != mGameObjManager->End(); ++it)
	{
		GameObject* gObj = *it;
		gObj->Resume();
	}
}

void LevelController::HideGetReadyScreen()
{
	[mScene hideGetReadyLayer];
}

void LevelController::ShowHUD()
{
	[mScene showHUDLayer];
}

void LevelController::HideHUD()
{
	[mScene hideHUDLayer];
}

void LevelController::RefreshControlsInHUD()
{
	[mScene refreshControlsInHUDLayer];
}

void LevelController::ShowPauseScreen()
{
	[mScene showPauseLayer];
}

void LevelController::HidePauseScreen()
{
	[mScene hidePauseLayer];
}

void LevelController::AnimatePauseScreen()
{
	[mScene animatePauseLayer];
}

void LevelController::ShowLifeLostScreen()
{
	mCameraFollowsPlayer = false;
	UpdateStatusBar();
	[mScene showLifeLostLayer];
}

void LevelController::AnimateLifeLostScreen()
{
	[mScene animateLifeLostLayer];
}

void LevelController::ShowSettingsScreen()
{
	[mScene showSettings];
}

void LevelController::HideSettingsScreen()
{
	[mScene hideSettings];
}

void LevelController::AnimateSettingsScreen()
{
	[mScene animateSettings];
}

void LevelController::ShowControlsScreen()
{
	[mScene showControls];
}

void LevelController::HideControlsScreen()
{
	[mScene hideControls];
}

void LevelController::ResetControls()
{
	[mScene resetControls];
}

void LevelController::AnimateControlsScreen()
{
	[mScene animateControls];
}

void LevelController::ShowLevelCompleteScreen()
{
	[mScene showLevelCompletedLayer];
}

void LevelController::ShowWorldCompletedScreen()
{
	[mScene showWorldCompleted];
}

void LevelController::ShowGameCompleteScreen()
{
	[mScene showGameCompleted];
}

void LevelController::loadFrontTilesFromFile()
{
	mNumTilesX = mScene.actionLayer.tileMap.mapSize.width;
	mNumTilesY = mScene.actionLayer.tileMap.mapSize.height;
	
	mTileTypes.assign(mNumTilesX * mNumTilesY, 0);
	mVisitedTiles.assign(mNumTilesX * mNumTilesY, false);
	
	CCLOG(@"TILES: %d x %d", mNumTilesX, mNumTilesY);
	CCLOG(@"mTileTypes.size() = %ld", mTileTypes.size());
	
	HKTMXLayer* frontLayer = [mScene.actionLayer.tileMap layerNamed:@"Front"];
	
	for (float j = 0; j < mScene.actionLayer.tileMap.mapSize.height; ++j) {
		for (float i = 0; i < mScene.actionLayer.tileMap.mapSize.width; ++i) {
			int tileType = [frontLayer tileGIDAt:ccp(i, j)];
			if (tileType != 0)
			{
				mTileTypes[(mNumTilesY - j - 1) * mNumTilesX + i] = tileType;
			}
		}
	}
	
	condenseTilesXForType(Tile_ThinFloor1);
	condenseTilesYForType(Tile_ThinFloor1);
	
	//condenseTilesXForType(Tile_ThinFloor2);
	//condenseTilesYForType(Tile_ThinFloor2);
	
	condenseTilesXForType(Tile_SpikesUp);
	condenseTilesYForType(Tile_SpikesUp);
	
	condenseTilesXForType(Tile_SpikesDown1);
	condenseTilesYForType(Tile_SpikesDown1);
	
	condenseTilesXForType(Tile_SpikesDown2);
	condenseTilesYForType(Tile_SpikesDown2);
	
	condenseTilesYForType(Tile_SpikesLeft);
	condenseTilesYForType(Tile_SpikesRight);
	
	condenseTilesYForType(Tile_HalfFloorLeft);
	condenseTilesYForType(Tile_HalfFloorRight);
	condenseTilesYForType(Tile_HalfFloorMiddle2);
	condenseTilesXForType(Tile_HalfFloorMiddle1);
	condenseTilesYForType(Tile_HalfFloorMiddle1);
	
	for (int i = 0; i < mNumTilesX; ++i)
	{
		for (int j = 0; j < mNumTilesY; ++j)
		{
			int tp = mTileTypes[i + j * mNumTilesX];
			
			switch (tp)
			{
				case Tile_HalfFloorLeft:
				case Tile_HalfFloorRight:
				case Tile_HalfFloorMiddle1:
				case Tile_HalfFloorMiddle2:
				case Tile_ThinFloor1:
				//case Tile_ThinFloor2:
				case Tile_SpikesUp:
				case Tile_SpikesDown1:
				case Tile_SpikesDown2:
				case Tile_SpikesLeft:
				case Tile_SpikesRight:
					mTileTypes[i + j * mNumTilesX] = 0;
					break;
					
				default:
					break;
			}
		}
	}
	
	condenseRemainingTiles();
}

void LevelController::condenseRemainingTiles()
{
	// This was the old way of doing it.
	//condenseTilesX();
	//condenseTilesY();
	
	// This is the new way.
	while (true)
	{
		Point2iVector outline;
		MarchingSquare::Instance()->DoMarch(mTileTypes, mNumTilesX, mNumTilesY, outline);
		
		CCLOG(@"OUTLINE SIZE: %lu", outline.size());
		
		if (outline.size() > 0)
		{
			//Tile* tile = new Tile(this, PNGMakePoint(0, 0), 0, outline);
			
			Point2iVector condensedOutline;
			condenseOutline(outline, condensedOutline);
			
			Tile* tile = new Tile(this, PNGMakePoint(0, 0), 0, condensedOutline);
			//mTiles.push_back(tile);
			mGameObjsToAdd.push_back(tile);
			
			removeOutlinedTiles(outline);
			//break;
		}
		else
		{
			break;
		}
	}
}

void LevelController::condenseOutline(const Point2iVector& outline, Point2iVector& condensedOutline)
{
	int maxLinkSize = 30;
	
	for (int curr = 0; curr < outline.size();)
	{
		int next = curr + 1;
		
		// Determine direction (horizontal or vertical).
		bool vertical = outline[next % outline.size()].x == outline[curr].x;
		
		if (vertical)
		{
			while ((next - curr <= maxLinkSize) && (outline[next % outline.size()].x == outline[curr].x))
			{
				++next;
			}
		}
		else
		{
			while ((next - curr <= maxLinkSize) && (outline[next % outline.size()].y == outline[curr].y))
			{
				++next;
			}
		}
		
		// Check if condensation took place.
		if (next - curr == 1)
		{
			condensedOutline.push_back(outline[next % outline.size()]);
			++curr;
		}
		else
		{
			condensedOutline.push_back(outline[(next - 1) % outline.size()]);
			curr = next - 1;
		}
	}
}

void LevelController::removeOutlinedTiles(const Point2iVector& outline)
{
	BoolVector grid;
	grid.assign(mNumTilesX * (mNumTilesY + 1), false);
	
	for (int index = 0; index < outline.size(); ++index)
	{
		int nextIndex = (index + 1) % outline.size();
		
		int x = outline[index].x;
		int y = outline[index].y;
		int nextX = outline[nextIndex].x;
		int nextY = outline[nextIndex].y;
		
		if (y == nextY && abs(nextX - x) == 1)
		{
			grid[std::min(x, nextX) + y * mNumTilesX] = true;
		}
	}
	
	// Check if a tile is inside or outside of a contour.
	for (int j = 0; j < mNumTilesY; ++j)
	{
		for (int i = 0; i < mNumTilesX; ++i)
		{
			int yPos = j;
			int numCuts = 0;
			
			while (yPos >= 0)
			{
				if (grid[i + yPos * mNumTilesX])
				{
					++numCuts;
				}
				--yPos;
			}
			
			if (numCuts % 2 != 0)
			{
				mTileTypes[i + j * mNumTilesX] = 0;
			}
		}
	}
}

bool LevelController::shouldCondenseTile(int type, int i, int j)
{
	//int typeToIgnore = 21;
	//int typeToIgnore = 234;
	int typeToIgnore = 20;
	
	int tileType = mTileTypes[j * mNumTilesX + i];
	bool visited = mVisitedTiles[j * mNumTilesX + i];
	
	if (visited) return false;
	else if (tileType == Tile_Empty || tileType == typeToIgnore) return false;
	else if (type != Tile_Empty && tileType != type) return false;
	
	return true;
}

void LevelController::condenseTilesX()
{
	condenseTilesXForType(0);
}

void LevelController::condenseTilesXForType(int type)
{
	int maxBlockSize = 30;
	
	for (int j = 0; j < mNumTilesY; ++j)
	{
		for (int i = 0; i < mNumTilesX; ++i)
		{
			if (!shouldCondenseTile(type, i, j)) continue;
			
			int start = i;
			int length = 0;
			
			while (i < mNumTilesX && length <= maxBlockSize)
			{
				if (!shouldCondenseTile(type, i, j)) break;
				
				++i;
				++length;
			}
			
			--i;
			
			if (length > maxBlockSize)
			{
				--i;
				--length;
			}
			
			// CCLOG(@"X -- Start: %d, Length: %d", start, length);
			
			// If a block is wider than 1 tile, create it.
			if (length > 1)
			{
				Tile* tile = new Tile(this, PNGMakePoint(26 * (0.5 * length + start), 13 + 26 * j), type, length, 1);
				//mTiles.push_back(tile);
				mGameObjsToAdd.push_back(tile);
				
				while (length > 0)
				{
					mVisitedTiles[j * mNumTilesX + start + length - 1] = true;
					--length;
				}
			}
		}
	}
}

void LevelController::condenseTilesY()
{
	condenseTilesYForType(0);
}

void LevelController::condenseTilesYForType(int type)
{
	int maxBlockSize = 30;
	
	for (int i = 0; i < mNumTilesX; ++i)
	{
		for (int j = 0; j < mNumTilesY; ++j)
		{
			if (!shouldCondenseTile(type, i, j)) continue;
			
			int start = j;
			int length = 0;
			
			while (j < mNumTilesY && length <= maxBlockSize)
			{
				if (!shouldCondenseTile(type, i, j)) break;
				
				++j;
				++length;
			}
			
			--j;
			
			if (length > maxBlockSize)
			{
				--j;
				--length;
			}
			
			// CCLOG(@"Y -- Start: %d, Length: %d", start, length);
			
			Tile* tile = new Tile(this, PNGMakePoint(13 + 26 * i, 26 * (0.5 * length + start)), type, 1, length);
			//mTiles.push_back(tile);
			mGameObjsToAdd.push_back(tile);
			
			while (length > 0)
			{
				mVisitedTiles[(start + length - 1) * mNumTilesX + i] = true;
				--length;
			}
		}
	}
}

void LevelController::loadGameObjectsFromFile()
{
	CCTMXObjectGroup* objGroup = [mScene.actionLayer.tileMap objectGroupNamed:@"Objects"];
	
	// Because 26 is the value used when designing levels in Tiled Map Editor.
	float factor = mScene.actionLayer.tileMap.tileSize.width / 26;
	
	for (NSDictionary* obj in objGroup.objects)
	{
		int gid = 0;
		
		if ([obj valueForKey:@"gid"])
		{
			gid = [[obj valueForKey:@"gid"] intValue];
		}
		else if ([obj valueForKey:@"type"])
		{
			std::string type([[obj valueForKey:@"type"] UTF8String]);
			
			if (type == "Water") gid = 30;
		}
		
		float x = [[obj valueForKey:@"x"] floatValue] / mScene.actionLayer.tileMap.tileSize.width;
		float y = [[obj valueForKey:@"y"] floatValue] / mScene.actionLayer.tileMap.tileSize.height;
		
		x = factor * x;
		y = mNumTilesY - factor * (mNumTilesY - y);
		
		CGPoint objPos = ccp((0.5 + x) * mTileSize, (0.5 + y) * mTileSize);
		
		//CCLOG(@"X = %f, Y = %f", x, y);
		createGameObject(gid, objPos, obj);
	}
}

void LevelController::createGameObject(uint objType, CGPoint pos, NSDictionary* opt)
{
	GameObject* gObj = NULL;
	
	switch (objType)
	{
		case 1:
			gObj = new Enemy(this, pos, opt);
			break;
			
		case 2:
			gObj = new FatBoy(this, pos, opt);
			break;
			
		case 3:
			gObj = new Barrel(this, pos, opt);
			break;
			
		case 4:
			gObj = new Platform(this, pos, opt);
			break;
			
		case 5:
			gObj = new Coin(this, pos);
			++mNumCoinsToCollect;
			break;
			
		case 6:
			gObj = new Cannon(this, pos, opt);
			break;
			
		case 7:
			gObj = new Button(this, pos, opt);
			break;
			
		case 8:
			gObj = new EndOfLevel(this, pos);
			break;
			
		case 9:
			gObj = new Pendulum(this, pos, opt);
			break;
			
		case 10:
			gObj = new CrackedTile(this, pos, opt);
			break;
			
		case 11:
			gObj = new Stomper(this, pos, opt);
			break;
			
		case 12:
			gObj = new Sign(this, pos, opt);
			break;
			
		case 13:
			if (mPlayer != NULL)
			{
				CCLOG(@"PLAYER already exists.");
			}
			else
			{
				switch (mLvlType)
				{
					case Level_Normal:
						CCLOG(@"PLAYER is NORMAL");
						gObj = new PlayerNormal(this, pos);
						break;
						
					case Level_Gravity:
						CCLOG(@"PLAYER is GRAVITY");
						gObj = new PlayerGravity(this, pos);
						break;
						
					case Level_Jetpack:
						CCLOG(@"PLAYER is JETPACK");
						//gObj = new PlayerJetpack(this, pos);
						break;
						
					default:
						break;
				}
				
				mPlayer = gObj;
			}
			break;
			
		case 14:
			gObj = new ConcreteSlab(this, pos, opt);
			break;
			
		case 15:
			gObj = new RunningMan(this, pos, opt);
			break;
			
		case 16:
			gObj = new Key(this, pos, opt);
			break;
			
		case 17:
			gObj = new Door(this, pos, opt);
			break;
			
		case 18:
			gObj = new Flyer(this, pos, opt);
			break;
			
		case 19:
			gObj = new Jumper(this, pos, opt);
			break;
			
		case 20:
			gObj = new Fish(this, pos, opt);
			break;
			
		case 21:
			gObj = new Spider(this, pos, opt);
			break;
			
		case 22:
			gObj = new Boulder(this, pos, opt);
			break;
		
		case 23:
			gObj = new Hedgehog(this, pos, opt);
			break;
			
		case 24:
			gObj = new Bomber(this, pos, opt);
			break;
			
		case 30:
			gObj = new Water(this, pos, opt);
			break;
			
		default:
			break;
	}
	
	if (gObj != NULL)
	{
		AddGameObject(gObj);
	}
}

void LevelController::PostFacebookMessage()
{
	[mScene postFacebookMessage];
}

void LevelController::PostTweet()
{
	[mScene postTweet];
}

void LevelController::ShowLeaderboards()
{
	if (GCManager::Instance()->PlayerAuthenticated())
	{
		[mScene showLeaderboards];
	}
}

void LevelController::ShowAchievements()
{
	if (GCManager::Instance()->PlayerAuthenticated())
	{
		[mScene showAchievements];
	}
}
