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

#import "Game.h"
#import "MainMenuController.h"
#import "LevelSelectionController.h"
#import "LevelController.h"
#import "LoadingController.h"
#import "JsonManager.h"
#import "zlib.h"


Game::Game() :
	mInitialized(false)
{
}

Game::~Game()
{
	delete mSceneController;
	mSceneController = NULL;
	
	deleteExitedScenes();
}

void Game::Initialize()
{
	if (mInitialized) return;
	
	mInitialized = true;
	
	srand((unsigned int) time(NULL));
	
	// Preload audio
	
	//[sae preloadBackgroundMusic:@"MusicMenu.m4a"];
	SoundManager::Instance()->PreloadEffect("Cuckoo.caf");
	SoundManager::Instance()->PreloadEffect("Explosion.caf");
	SoundManager::Instance()->PreloadEffect("TickTock.caf");
	SoundManager::Instance()->PreloadEffect("Door.caf");
	SoundManager::Instance()->PreloadEffect("Switch.caf");
	SoundManager::Instance()->PreloadEffect("PlayerHit.caf");
	SoundManager::Instance()->PreloadEffect("PlayerFire.caf");
	SoundManager::Instance()->PreloadEffect("PlayerJump.caf");
	SoundManager::Instance()->PreloadEffect("PlayerKilled.caf");
	SoundManager::Instance()->PreloadEffect("EnemyFire.caf");
	SoundManager::Instance()->PreloadEffect("EnemyJump.caf");
	SoundManager::Instance()->PreloadEffect("CannonFire.caf");
	SoundManager::Instance()->PreloadEffect("EndOfLevel.caf");
	SoundManager::Instance()->PreloadEffect("CrackedTile.caf");
	SoundManager::Instance()->PreloadEffect("ObstacleHit.caf");
	SoundManager::Instance()->PreloadEffect("EnemyKilled.caf");
	SoundManager::Instance()->PreloadEffect("WaterSplash.caf");
	SoundManager::Instance()->PreloadEffect("ButtonClicked.caf");
	SoundManager::Instance()->PreloadEffect("CoinCollected.caf");
	SoundManager::Instance()->PreloadEffect("KeyCollected.caf");
	SoundManager::Instance()->PreloadEffect("StarCollected.caf");
	SoundManager::Instance()->PreloadEffect("Medal.caf");
	
	mBackgroundMusicId = 0;
	
	// Options
	mDistributable = Distributable_AppStore;
	mDebugOn = false;
	mMusicOn = true;
	mSoundOn = true;
	
	// Stats
	mWorldIndex = 0;
	mLevelIndex = 0;
	
	CGSize winSize = [CCDirector sharedDirector].winSize;
	mUseGestures = false;
	mQuant = PNGMakeFloat(8);
	mControlButtonWidth = IsRunningOnPad() ? 8 * mQuant : 10 * mQuant;
	
	mOrigControlsPos["Left"] = mControlsPos["Left"] = ccp(0.5 * mControlButtonWidth, 0.5 * mControlButtonWidth);
	mOrigControlsPos["Right"] = mControlsPos["Right"] = ccpAdd(mControlsPos["Left"], ccp(mControlButtonWidth, 0));
	mOrigControlsPos["Jump"] = mControlsPos["Jump"] = ccp(winSize.width - 0.5 * mControlButtonWidth, mControlsPos["Left"].y);
	mOrigControlsPos["Fire"] = mControlsPos["Fire"] = ccpAdd(mControlsPos["Jump"], ccp(-mControlButtonWidth, 0));
	
	LoadConfigurationFromFile("Game");
	LoadStats();
	
	// Used when a new world has been added to the game.
	this->Data().UnlockAvailableWorlds();
	
	this->initCustomShaders();
	
	// Test purchases.
	StringVector productNames = Data().ProductRepo().ItemNames();
	for (int index = 0; index < productNames.size(); ++index)
	{
		ProductData& prodData = Data().ProductRepo().Item(productNames[index]);
		NSLog(@"PRODUCT %d: %s ==>> %s", index, prodData.Name().c_str(), prodData.Purchased() ? "YES" : "NO");
	}
	
	//mSceneController = new MainMenuController;
	mSceneController = new LoadingController(Scene_MainMenu, 0, 0, Loading_Logo, true);
}

void Game::OnUpdate(ccTime dt)
{
	deleteExitedScenes();
}

void Game::OnPostUpdate()
{
	SoundManager::Instance()->PlayScheduledEffects();
}

void Game::Pause()
{
	CCLOG(@"GAME PAUSED");
	mSceneController->Pause();
}

void Game::Resume()
{
	CCLOG(@"GAME RESUMED");
	mSceneController->Resume();
}

void Game::OnControllerStateChanged()
{
	mSceneController->OnControllerStateChanged();
}

void Game::OnProductValidationCompleted(bool success)
{
	mSceneController->OnProductValidationCompleted(success);
}

void Game::OnRestoreTransactionsCompleted(bool success)
{
	mSceneController->OnRestoreTransactionsCompleted(success);
}

void Game::OnTransactionCompleted(bool success)
{
	mSceneController->OnTransactionCompleted(success);
}

void Game::OnSceneEntered(SceneController* scene)
{
	CCLOG(@"ON SCENE ENTERED");
	if (mMusicOn) PlayBackgroundMusic();
}

void Game::OnSceneExited(SceneController* scene)
{
	CCLOG(@"ON SCENE EXITED");
	mExitedScenes.push_back(scene);
}

void Game::initCustomShaders()
{
	const GLchar* fragmentSource = (GLchar*) [[NSString stringWithContentsOfFile:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"ColorBlend.fsh"] encoding:NSUTF8StringEncoding error:nil] UTF8String];
	CCGLProgram* program = [[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureA8Color_vert fragmentShaderByteArray:fragmentSource];
	
	[program addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
	[program addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
	[program addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
	
	[program link];
	[program updateUniforms];
	
	[[CCShaderCache sharedShaderCache] addProgram:program forKey:@"ColorBlend"];
	[program release];
	
	// ---
	
	const GLchar* fragmentSource2 = (GLchar*) [[NSString stringWithContentsOfFile:[[CCFileUtils sharedFileUtils] fullPathFromRelativePath:@"Grayscale.fsh"] encoding:NSUTF8StringEncoding error:nil] UTF8String];
	CCGLProgram* program2 = [[CCGLProgram alloc] initWithVertexShaderByteArray:ccPositionTextureA8Color_vert fragmentShaderByteArray:fragmentSource2];
	
	[program2 addAttribute:kCCAttributeNamePosition index:kCCVertexAttrib_Position];
	[program2 addAttribute:kCCAttributeNameTexCoord index:kCCVertexAttrib_TexCoords];
	[program2 addAttribute:kCCAttributeNameColor index:kCCVertexAttrib_Color];
	
	[program2 link];
	[program2 updateUniforms];
	
	[[CCShaderCache sharedShaderCache] addProgram:program2 forKey:@"Grayscale"];
	[program2 release];
}

void Game::deleteExitedScenes()
{
	for (SceneList::const_iterator it = mExitedScenes.begin(); it != mExitedScenes.end(); ++it)
	{
		SceneController* scene = *it;
		delete scene;
	}
	mExitedScenes.clear();
}

void Game::setActiveScene(SceneController* sceneController, float transitionDuration)
{
	mSceneController = sceneController;
	
	[[CCDirector sharedDirector] replaceScene:
	 [CCTransitionFade transitionWithDuration:transitionDuration
										scene:mSceneController->Scene()
									withColor:ccc3(0, 0, 0)]];
}

void Game::PlayBackgroundMusic()
{
	CCLOG(@"BACK: %d, NEXT: %d", mBackgroundMusicId, mSceneController->BackgroundMusicId());
	
	if (mSceneController->BackgroundMusicId() == 0 ||
		mSceneController->BackgroundMusicId() == mBackgroundMusicId) return;
	
	mBackgroundMusicId = mSceneController->BackgroundMusicId();
	
	CCLOG(@"PLAY BACKGROUND MUSIC");
	
	SoundManager::Instance()->StopBackgroundMusic();
	SoundManager::Instance()->SetBackgroundMusicVolume(BkgMusic_Loud);
	
	switch (mSceneController->BackgroundMusicId())
	{
		case 1:
			SoundManager::Instance()->PlayBackgroundMusic("MusicMenu.m4a", true);
			break;
			
		case 2:
			SoundManager::Instance()->PlayBackgroundMusic(Data().World(mWorldIndex).Music(), true);
			break;
	}
	
	CCLOG(@"IS PLAYING: %d", SoundManager::Instance()->IsBackgroundMusicPlaying());
}

void Game::StopBackgroundMusic()
{
	CCLOG(@"STOP BACKGROUND MUSIC!");
	
	if (SoundManager::Instance()->IsBackgroundMusicPlaying())
	{
		mBackgroundMusicId = 0;
		
		SoundManager::Instance()->FadeOutBackgroundMusic(0.5, true);
	}
}

void Game::PreloadBackgroundMusic()
{
	CCLOG(@"PRELOAD BACKGROUND MUSIC!");
	
	if (mSceneController->BackgroundMusicId() != mBackgroundMusicId)
	{
		mBackgroundMusicId = 0;
		
		SoundManager::Instance()->StopBackgroundMusic();
		
		switch (mSceneController->BackgroundMusicId())
		{
			case 1:
				SoundManager::Instance()->PreloadBackgroundMusic("MusicMenu.m4a");
				break;
				
			case 2:
				SoundManager::Instance()->PreloadBackgroundMusic(Data().World(mWorldIndex).Music());
				break;
		}
	}
}

void Game::GoToLoading(SceneType sceneType, int worldId, int levelId, LoadingMode mode, bool stopMusic)
{
	CCLOG(@"GoToLoading");
	
	if (stopMusic) StopBackgroundMusic();
	
	SceneController* scene = new LoadingController(sceneType, worldId, levelId, mode, stopMusic);
	setActiveScene(scene);
}

void Game::GoToLevelSelect(int centeredWorldId, int levelId)
{
	CCLOG(@"GoToLevelSelect");
	
	SceneController* scene = new LevelSelectionController(centeredWorldId, levelId);
	setActiveScene(scene);
}

void Game::GoToLevel(int worldId, int levelId)
{
	CCLOG(@"GoToLevel: %d-%d", worldId, levelId);
	
	mWorldIndex = worldId;
	mLevelIndex = levelId;
	
	SceneController* scene = new LevelController(worldId, levelId);
	setActiveScene(scene);
}

void Game::GoToMenu()
{
	CCLOG(@"GoToMenu");
	
	SceneController* scene = new MainMenuController;
	setActiveScene(scene);
}

void Game::SetMusicOn(bool musicOn)
{
	if (mMusicOn != musicOn)
	{
		mMusicOn = musicOn;
		
		if (mMusicOn)
		{
			PlayBackgroundMusic();
		}
		else
		{
			StopBackgroundMusic();
		}
	}
}

// ***

void Game::parseControl(const Json::Value& controlObject, CGPoint& p)
{
	const Json::Value& x = controlObject["x"];
	const Json::Value& y = controlObject["y"];
	
	if (!x.isNull() && !y.isNull())
	{
		p.x = x.asFloat();
		p.y = y.asFloat();
	}
}

void Game::parseStats(const Json::Value& stats)
{
	const Json::Value& language = stats["language"];
	
	if (!language.isNull())
	{
		Data().SetLanguage(language.asString());
	}
	
	// -----
	
	const Json::Value& musicOn = stats["musicOn"];
	if (!musicOn.isNull())
	{
		mMusicOn = musicOn.asBool();
	}
	
	const Json::Value& soundOn = stats["soundOn"];
	if (!soundOn.isNull())
	{
		mSoundOn = soundOn.asBool();
	}
	
	// -----
	
	const Json::Value& controlsObject = stats["controls"];
	
	if (!controlsObject.isNull())
	{
		const Json::Value& useGestures = controlsObject["useGestures"];
		if (!useGestures.isNull()) mUseGestures = useGestures.asBool();
		
		const Json::Value& leftObject = controlsObject["left"];
		if (!leftObject.isNull()) parseControl(leftObject, mControlsPos["Left"]);
		
		const Json::Value& rightObject = controlsObject["right"];
		if (!rightObject.isNull()) parseControl(rightObject, mControlsPos["Right"]);
		
		const Json::Value& fireObject = controlsObject["fire"];
		if (!fireObject.isNull()) parseControl(fireObject, mControlsPos["Fire"]);
		
		const Json::Value& jumpObject = controlsObject["jump"];
		if (!jumpObject.isNull()) parseControl(jumpObject, mControlsPos["Jump"]);
	}
	
	// -----
	
	const Json::Value& productsArray = stats["products"];
	
	if (!productsArray.isNull())
	{
		for (int index = 0; index < productsArray.size(); ++index)
		{
			const Json::Value& productObject = productsArray[index];
			
			const Json::Value& name = productObject["name"];
			
			if (!name.isNull())
			{
				std::string productName = name.asString();
				
				if (Data().ProductRepo().ItemExists(productName))
				{
					ProductData& prodData = Data().ProductRepo().Item(productName);
					
					const Json::Value& purchased = productObject["purchased"];
					if (!purchased.isNull())
						prodData.SetPurchased(purchased.asBool());
				}
			}
		}
	}
	
	// -----
	
	const Json::Value& worldsArray = stats["worlds"];
	
	if (!worldsArray.isNull())
	{
		for (int worldId = 0; worldId < worldsArray.size() && worldId < Data().NumWorlds(); ++worldId)
		{
			WorldData& wd = Data().World(worldId);
			
			const Json::Value& worldObject = worldsArray[worldId];
			
			const Json::Value& wldLocked = worldObject["locked"];
			if (!wldLocked.isNull())
				wd.SetLocked(wldLocked.asBool());
			
			const Json::Value& levelsArray = worldObject["levels"];
			
			if (!levelsArray.isNull())
			{
				for (int levelId = 0; levelId < levelsArray.size() && levelId < wd.NumLevels(); ++levelId)
				{
					LevelData& ld = wd.Level(levelId);
					
					const Json::Value& levelObject = levelsArray[levelId];
					
					const Json::Value& lvlCompleted = levelObject["completed"];
					if (!lvlCompleted.isNull())
						ld.SetCompleted(lvlCompleted.asBool());
					
					const Json::Value& lvlLocked = levelObject["locked"];
					if (!lvlLocked.isNull())
						ld.SetLocked(lvlLocked.asBool());
					
					const Json::Value& numStars = levelObject["numStars"];
					if (!numStars.isNull())
					{
						ld.SetNumStarsCollected(numStars.asInt());
					}
				}
			}
		}
	}
}

void Game::LoadStats()
{
	// Old-style plain text file.
	NSString* oldFilename = @"Stats.json";
	NSString* oldPath = PathForFile(oldFilename);
	
	// New style compressed file.
	NSString* newFilename = @"Stats.dat";
	NSString* newPath = PathForFile(newFilename);
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:oldPath])
	{
		NSError* error;
		NSString* fileData = [NSString stringWithContentsOfFile:oldPath encoding:NSUTF8StringEncoding error:&error];
		
		if (!fileData)
		{
			CCLOG(@"Error reading file: %@", oldFilename);
			CCLOG(@"%@", [error description]);
		}
		else
		{
			Json::Value root;
			
			if (JsonManager::Instance()->ParseJsonFromString(fileData.UTF8String, root))
			{
				parseStats(root);
			}
			
			// Immediately save stats into a new-style compressed file.
			SaveStats();
		}
		
		// Delete old-style plain text file so it's not used again.
		[[NSFileManager defaultManager] removeItemAtPath:oldPath error:nil];
	}
	else if ([[NSFileManager defaultManager] fileExistsAtPath:newPath])
	{
		NSError* error;
		NSData* fileData = [NSData dataWithContentsOfFile:newPath options:NSDataReadingUncached error:&error];
		
		if (!fileData)
		{
			CCLOG(@"Error reading file: %@", newFilename);
			CCLOG(@"%@", [error description]);
		}
		else
		{
			// Uncompress file data.
			Bytef uncompressedData[16384];
			uLongf uncompressedDataLen = sizeof(uncompressedData);
			
			if (uncompress(uncompressedData, &uncompressedDataLen, (const Bytef*)fileData.bytes, fileData.length) == Z_OK)
			{
				std::string data((const char*)uncompressedData, uncompressedDataLen);
				
				Json::Value root;
				
				if (JsonManager::Instance()->ParseJsonFromString(data, root))
				{
					parseStats(root);
				}
			}
		}
	}
	else
	{
		CCLOG(@"STATS FILE NOT FOUND!");
	}
}

void Game::SaveStats()
{
	Json::Value root;
	
	// -----
	
	root["language"] = Data().Language();
	
	// -----
	
	root["musicOn"] = mMusicOn;
	root["soundOn"] = mSoundOn;
	
	// -----
	
	Json::Value controlsObject;
	
	Json::Value useGestures;
	controlsObject["useGestures"] = mUseGestures;
	
	Json::Value leftObject;
	leftObject["x"] = mControlsPos["Left"].x;
	leftObject["y"] = mControlsPos["Left"].y;
	controlsObject["left"] = leftObject;
	
	Json::Value rightObject;
	rightObject["x"] = mControlsPos["Right"].x;
	rightObject["y"] = mControlsPos["Right"].y;
	controlsObject["right"] = rightObject;
	
	Json::Value fireObject;
	fireObject["x"] = mControlsPos["Fire"].x;
	fireObject["y"] = mControlsPos["Fire"].y;
	controlsObject["fire"] = fireObject;
	
	Json::Value jumpObject;
	jumpObject["x"] = mControlsPos["Jump"].x;
	jumpObject["y"] = mControlsPos["Jump"].y;
	controlsObject["jump"] = jumpObject;
	
	root["controls"] = controlsObject;
	
	// -----
	
	Json::Value productsArray(Json::arrayValue);
	
	StringVector productNames = Data().ProductRepo().ItemNames();
	
	for (int index = 0; index < productNames.size(); ++index)
	{
		ProductData& prodData = Data().ProductRepo().Item(productNames[index]);
		
		Json::Value productObject;
		productObject["name"] = prodData.Name();
		productObject["purchased"] = prodData.Purchased();
		productsArray.append(productObject);
	}
	
	root["products"] = productsArray;
	
	// -----
	
	Json::Value worldsArray;
	
	for (int worldId = 0; worldId < Data().NumWorlds(); ++worldId)
	{
		WorldData& wd = Data().World(worldId);
		
		Json::Value worldObject;
		Json::Value levelsArray;
		
		for (int levelId = 0; levelId < wd.NumLevels(); ++levelId)
		{
			LevelData& ld = wd.Level(levelId);
			
			Json::Value levelObject;
			levelObject["completed"] = ld.Completed();
			levelObject["locked"] = ld.Locked();
			levelObject["numStars"] = ld.NumStarsCollected();
			levelsArray.append(levelObject);
		}
		
		worldObject["locked"] = wd.Locked();
		worldObject["levels"] = levelsArray;
		worldsArray.append(worldObject);
	}
	
	root["worlds"] = worldsArray;
	
	// -----
	
	Json::FastWriter writer;
	std::string output = writer.write(root);
	
	// Compress the output.
	Bytef compressedOutput[8192];
	uLongf compressedOutputLen = sizeof(compressedOutput);
	
	if (compress(compressedOutput, &compressedOutputLen, (const Bytef*)output.data(), output.length()) == Z_OK)
	{
		NSError* error;
		NSString* filename = @"Stats.dat";
		NSString* path = PathForFile(filename);
		NSData* data = [NSData dataWithBytes:compressedOutput length:compressedOutputLen];
		[data writeToFile:path options:NSDataWritingAtomic error:&error];
	}
	
	if (mDistributable != Distributable_AppStore)
	{
		NSError* error2;
		NSString* filename2 = @"StatsOrig.json";
		NSString* path2 = PathForFile(filename2);
		NSData* data2 = [NSData dataWithBytes:output.data() length:output.length()];
		[data2 writeToFile:path2 options:NSDataWritingAtomic error:&error2];
	}
}

// ***

void Game::LoadConfigurationFromFile(const std::string& filename)
{
	Json::Value root;
	if (JsonManager::Instance()->LoadJsonFromFile(filename, "cfg", root))
	{
		mGameData.PopulateFromJson(root);
	}
	else
	{
		throw "<Game::LoadConfigurationFromFile> Error reading configuration file.";
	}
}
