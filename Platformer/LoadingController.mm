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

#import "LoadingController.h"
#import "LoadingStates.h"
#import "LoadingScene.h"
#import "Game.h"


LoadingController::LoadingController(SceneType sceneType, int worldId, int levelId, LoadingMode mode, bool shouldStopMusic) :
	mSceneType(sceneType),
	mWorldId(worldId),
	mLevelId(levelId),
	mMode(mode),
	mShouldStopMusic(shouldStopMusic),
	mDeltaTime(0),
	mTimeElapsed(0)
{
	mScene = [[LoadingScene alloc] initWithLoadingController:this mode:mode];
	
	State<LoadingController>* startState = LoadingState_EnterTransition::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(LoadingState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

LoadingController::~LoadingController()
{
	CCLOG(@"DEALLOC: LoadingController");
	
	[mScene release];
	
	CCLOG(@"END DEALLOC: LoadingController");
}

void LoadingController::OnSceneEntered()
{
	Telegram telegram(ID_IRRELEVANT, ID_IRRELEVANT, Msg_SceneEntered, NULL);
	HandleMessage(telegram);
}

void LoadingController::Update(ccTime dt)
{
	mDeltaTime = dt;
	SceneControllerFSM::Update(dt);
}

bool LoadingController::ShouldWaitUntilBackgroundMusicStops() const
{
	return mShouldStopMusic && SoundManager::Instance()->IsBackgroundMusicPlaying();
}

void LoadingController::ChangeScene()
{
	// Preload new background music if the old one has stopped playing.
	
	if (mShouldStopMusic) Game::Instance()->PreloadBackgroundMusic();
	
	switch (mSceneType)
	{
		case Scene_MainMenu:
		{
			Game::Instance()->GoToMenu();
			break;
		}
			
		case Scene_LevelSelection:
		{
			Game::Instance()->GoToLevelSelect(mWorldId, mLevelId);
			break;
		}
			
		case Scene_Level:
		{
			Game::Instance()->GoToLevel(mWorldId, mLevelId);
			break;
		}
			
		default:
			break;
	}
}

void LoadingController::LoadAssets()
{
	// Preload audio
	//SimpleAudioEngine* sae = [SimpleAudioEngine sharedEngine];
	
	/*
	if (sae != nil)
	{
		//[sae preloadBackgroundMusic:@"sn-game.m4a"];
		[sae preloadEffect:@"Cuckoo.caf"];
		[sae preloadEffect:@"Explosion.caf"];
		[sae preloadEffect:@"TickTock.caf"];
		[sae preloadEffect:@"Door.caf"];
		[sae preloadEffect:@"Switch.caf"];
		[sae preloadEffect:@"PlayerHit.caf"];
		[sae preloadEffect:@"PlayerFire.caf"];
		[sae preloadEffect:@"PlayerJump.caf"];
		[sae preloadEffect:@"PlayerKilled.caf"];
		[sae preloadEffect:@"EnemyFire.caf"];
		[sae preloadEffect:@"EnemyJump.caf"];
		[sae preloadEffect:@"CannonFire.caf"];
		[sae preloadEffect:@"EndOfLevel.caf"];
		[sae preloadEffect:@"CrackedTile.caf"];
		[sae preloadEffect:@"ObstacleHit.caf"];
		[sae preloadEffect:@"EnemyKilled.caf"];
		[sae preloadEffect:@"WaterSplash.caf"];
		[sae preloadEffect:@"ButtonClicked.caf"];
		[sae preloadEffect:@"CoinCollected.caf"];
	}
	*/
	
	
	// Preload textures
	CCTextureCache* tc = [CCTextureCache sharedTextureCache];
	CCSpriteFrameCache* sfc = [CCSpriteFrameCache sharedSpriteFrameCache];
	
	CCLOG(@"===");
	//[tc dumpCachedTextureInfo];
	CCLOG(@"---");
	
	[sfc removeSpriteFrames];
	[[CCDirector sharedDirector] purgeCachedData];
	
	//[tc dumpCachedTextureInfo];
	CCLOG(@"---");
	
	// Load common textures and frame anims.
	LoadSpriteFramesFromRepository(Game::Instance()->Data().FrameAnimRepo("Common"));
	LoadTexturesFromRepository(Game::Instance()->Data().TextureRepo("Common"));
	
	switch (mSceneType)
	{
		case Scene_MainMenu:
		{
			LoadSpriteFramesFromRepository(Game::Instance()->Data().FrameAnimRepo("MainMenu"));
			LoadTexturesFromRepository(Game::Instance()->Data().TextureRepo("MainMenu"));
			break;
		}
		
		case Scene_LevelSelection:
		{
			LoadSpriteFramesFromRepository(Game::Instance()->Data().FrameAnimRepo("LevelSelection"));
			LoadTexturesFromRepository(Game::Instance()->Data().TextureRepo("LevelSelection"));
			break;
		}
			
		case Scene_Level:
		{
			WorldData& wd = Game::Instance()->Data().World(mWorldId);
			
			// Load static background for selected world.
			NSString* bkgTextureName = [[NSString alloc] initWithFormat:@"%s", wd.StaticBackground().c_str()];
			
			CCTexture2DPixelFormat currentFormat = [CCTexture2D defaultAlphaPixelFormat];
			//[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
			[tc addImage:bkgTextureName];
			[CCTexture2D setDefaultAlphaPixelFormat:currentFormat];
			
			[bkgTextureName release];
			
			// Load sprite frames and their textures.
			LoadSpriteFramesFromRepository(wd.FrameAnimRepo());
			LoadSpriteFramesFromRepository(Game::Instance()->Data().FrameAnimRepo("Level"));
			
			// Load remaining textures for selected world.
			LoadTexturesFromRepository(wd.TextureRepo());
			LoadTexturesFromRepository(Game::Instance()->Data().TextureRepo("Level"));
			break;
		}
			
		default:
			break;
	}
	
	//[tc dumpCachedTextureInfo];
	
	CCLOG(@"ASSETS LOADED");
}
