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

#import "GameData.h"
#import "Game.h"
#import "JsonManager.h"


GameData::GameData() :
	mActiveLanguageIndex(0)
{
	mLanguages.push_back("en");
	mLanguages.push_back("fr");
	mLanguages.push_back("de");
	mLanguages.push_back("es");
	mLanguages.push_back("it");
	mLanguages.push_back("nl");
	mLanguages.push_back("pt");
	mLanguages.push_back("br");
	mLanguages.push_back("ru");
	mLanguages.push_back("tu");
	
	// Physics resources
	mCategories["CATEGORY_PLAYER"]			= 1 << 0;
	mCategories["CATEGORY_ENEMY"]			= 1 << 1;
	mCategories["CATEGORY_FRIENDLY_FIRE"]	= 1 << 2;
	mCategories["CATEGORY_HOSTILE_FIRE"]	= 1 << 3;
	mCategories["CATEGORY_GROUND"]			= 1 << 4;
	mCategories["CATEGORY_POWERUP"]			= 1 << 5;
	mCategories["CATEGORY_HAZARD"]			= 1 << 6;
	mCategories["CATEGORY_WATER"]			= 1 << 7;
	
	mMasks["MASK_ALL"]				= 0xFFFF;
	mMasks["MASK_PLAYER"]			= ~mCategories["CATEGORY_PLAYER"] & ~mCategories["CATEGORY_FRIENDLY_FIRE"];
	mMasks["MASK_ENEMY"]			= ~mCategories["CATEGORY_ENEMY"] /*& ~mCategories["CATEGORY_HOSTILE_FIRE"]*/;
	mMasks["MASK_FLYING_ENEMY"]		= mMasks["MASK_ENEMY"] & ~mCategories["CATEGORY_GROUND"];
	mMasks["MASK_FRIENDLY_FIRE"]	= ~mCategories["CATEGORY_HOSTILE_FIRE"];
	mMasks["MASK_HOSTILE_FIRE"]		= ~mCategories["CATEGORY_FRIENDLY_FIRE"];
	mMasks["MASK_POWERUP"]			= mCategories["CATEGORY_PLAYER"];
	mMasks["MASK_GROUND_SENSOR"]	= mCategories["CATEGORY_GROUND"];
	
	mGroups["GROUP_ENEMY"]			= -1;
	mGroups["GROUP_FRIENDLY_FIRE"]	= -2;
	mGroups["GROUP_HOSTILE_FIRE"]	= -3;
	mGroups["GROUP_POWERUP"]		= -4;
	mGroups["GROUP_HAZARD"]			= -5;
	
	// Buttons
	mButtonFrameNames = [[NSMutableDictionary alloc] init];
}

GameData::~GameData()
{
	for (int i = 0; i < mWorlds.size(); ++i)
	{
		delete mWorlds[i];
	}
	mWorlds.clear();
	
	[mButtonFrameNames release];
}

void GameData::AddWorld(const Json::Value& world)
{
	WorldData* wd = WorldData::FromJson(world);
	
	if (wd != NULL)
	{
		mWorlds.push_back(wd);
	}
}

void GameData::SetLanguage(const std::string& language)
{
	for (int index = 0; index < mLanguages.size(); ++index)
	{
		if (mLanguages[index] == language)
		{
			mActiveLanguageIndex = index;
			return;
		}
	}
	
	// If not found, set to default language.
	mActiveLanguageIndex = 0;
}

const std::string& GameData::LocalizedText(const std::string textName)
{
	TextData& txtData = mTextRepository.Item(textName);
	return txtData.Text(Language());
}

bool GameData::LocalizedTextSmall(const std::string textName)
{
	TextData& txtData = mTextRepository.Item(textName);
	return txtData.Small(Language());
}

int GameData::TotalScore() const
{
	int score = 0;
	
	for (int worldId = 0; worldId < this->NumWorlds(); ++worldId)
	{
		score += this->World(worldId).Score();
	}
	
	return score;
}

int GameData::NumStarsCollected() const
{
	int numStarsCollected = 0;
	
	for (int worldId = 0; worldId < this->NumWorlds(); ++worldId)
	{
		numStarsCollected += this->World(worldId).NumStarsCollected();
	}
	
	return numStarsCollected;
}

void GameData::UnlockAvailableWorlds()
{
	const int numStarsCollected = this->NumStarsCollected();
	
	for (int worldId = 1; worldId < this->NumWorlds(); ++worldId)
	{
		WorldData& currWorld = this->World(worldId);
		const WorldData& prevWorld = this->World(worldId - 1);
		
		if (currWorld.Locked() && prevWorld.CompletedAllLevels() && numStarsCollected >= currWorld.NumStarsToUnlock())
		{
			currWorld.SetLocked(false);
		}
	}
}

// -------------------------------------------------------------------------------

void GameData::loadPhysicsFile(const std::string& filename)
{
	Json::Value jsonObj;
	
	if (JsonManager::Instance()->LoadJsonFromFile(filename, "cfg", jsonObj))
	{
		const Json::Value& phyTemplates = jsonObj["templates"];
		
		if (!phyTemplates.isNull())
		{
			for (int index = 0; index < phyTemplates.size(); ++index)
			{
				loadPhyTemplateFromFile(phyTemplates[index].asString());
			}
		}
	}
}

void GameData::loadPhyTemplateFromFile(const std::string& filename)
{
	Json::Value root;
	
	if (JsonManager::Instance()->LoadJsonFromFile(filename, "phy", root))
	{
		mPhyTemplateRepo.AddItem(root);
	}
}

// -------------------------------------------------------------------------------

void GameData::loadWorldsFile(const std::string& filename)
{
	Json::Value jsonObj;
	
	if (JsonManager::Instance()->LoadJsonFromFile(filename, "cfg", jsonObj))
	{
		const Json::Value& worlds = jsonObj["worlds"];
		
		if (!worlds.isNull())
		{
			for (int index = 0; index < worlds.size(); ++index)
			{
				loadWorldDataFromFile(worlds[index].asString());
			}
		}
	}
}

void GameData::loadWorldDataFromFile(const std::string& filename)
{
	Json::Value root;
	if (JsonManager::Instance()->LoadJsonFromFile(filename, "wld", root))
	{
		AddWorld(root);
	}
}

// -------------------------------------------------------------------------------

void GameData::loadScenesFile(const std::string& filename)
{
	Json::Value jsonObj;
	
	if (JsonManager::Instance()->LoadJsonFromFile(filename, "cfg", jsonObj))
	{
		const Json::Value& scenes = jsonObj["scenes"];
		
		if (!scenes.isNull())
		{
			for (int index = 0; index < scenes.size(); ++index)
			{
				std::string sceneName = scenes[index].asString();
				
				mFrameAnimRepoMap.insert(std::make_pair(sceneName, Repository<FrameAnimData>()));
				mTextureRepoMap.insert(std::make_pair(sceneName, StringVector()));
				
				loadSceneDataFromFile(sceneName);
			}
		}
	}
}

void GameData::loadSceneDataFromFile(const std::string& filename)
{
	Json::Value jsonObj;
	
	if (JsonManager::Instance()->LoadJsonFromFile(filename, "scn", jsonObj))
	{
		parseFrameAnims(jsonObj["frameAnims"], mFrameAnimRepoMap[filename]);
		parseTextures(jsonObj["textures"], mTextureRepoMap[filename]);
	}
}

void GameData::parseFrameAnims(const Json::Value& frameAnims, Repository<FrameAnimData>& frameAnimRepo)
{
	if (!frameAnims.isNull())
	{
		for (int index = 0; index < frameAnims.size(); ++index)
		{
			frameAnimRepo.AddItem(frameAnims[index]);
		}
	}
}

void GameData::parseTextures(const Json::Value& textures, StringVector& textureRepo)
{
	if (!textures.isNull())
	{
		for (int index = 0; index < textures.size(); ++index)
		{
			textureRepo.push_back(textures[index].asString());
		}
	}
}

// -------------------------------------------------------------------------------

void GameData::loadProductsFile(const std::string& filename)
{
	Json::Value jsonObj;
	
	if (JsonManager::Instance()->LoadJsonFromFile(filename, "cfg", jsonObj))
	{
		const Json::Value& products = jsonObj["products"];
		if (!products.isNull())
		{
			for (int index = 0; index < products.size(); ++index)
			{
				mProductRepository.AddItem(products[index]);
			}
		}
	}
}

// -------------------------------------------------------------------------------

void GameData::loadTextsFile(const std::string& filename)
{
	Json::Value jsonObj;
	
	if (JsonManager::Instance()->LoadJsonFromFile(filename, "cfg", jsonObj))
	{
		const Json::Value& language = jsonObj["language"];
		if (!language.isNull())
		{
			this->SetLanguage(language.asString());
		}
		
		const Json::Value& text = jsonObj["text"];
		if (!text.isNull())
		{
			for (int index = 0; index < text.size(); ++index)
			{
				mTextRepository.AddItem(text[index]);
			}
		}
	}
}

// -------------------------------------------------------------------------------

void GameData::PopulateFromJson(const Json::Value& jsonObj)
{
	if (jsonObj.isNull()) return;
	
	const Json::Value& worldsFile = jsonObj["worldsFile"];
	if (!worldsFile.isNull())
	{
		loadWorldsFile(worldsFile.asString());
	}
	
	const Json::Value& physicsFile = jsonObj["physicsFile"];
	if (!physicsFile.isNull())
	{
		loadPhysicsFile(physicsFile.asString());
	}
	
	const Json::Value& scenesFile = jsonObj["scenesFile"];
	if (!scenesFile.isNull())
	{
		loadScenesFile(scenesFile.asString());
	}
	
	const Json::Value& productsFile = jsonObj["productsFile"];
	if (!productsFile.isNull())
	{
		loadProductsFile(productsFile.asString());
	}
	
	const Json::Value& buttons = jsonObj["buttons"];
	if (!buttons.isNull())
	{
		for (int index = 0; index < buttons.size(); ++index)
		{
			const Json::Value& name = buttons[index]["name"];
			const Json::Value& frame = buttons[index]["frame"];
			
			if (!name.isNull() && !frame.isNull())
			{
				NSString* key = [[NSString alloc] initWithFormat:@"%s", name.asString().c_str()];
				NSString* val = [[NSString alloc] initWithFormat:@"%s", frame.asString().c_str()];
				
				[mButtonFrameNames setObject:val forKey:key];
				
				[key release];
				[val release];
			}
		}
	}
	
	const Json::Value& textsFile = jsonObj["textsFile"];
	if (!textsFile.isNull())
	{
		loadTextsFile(textsFile.asString());
	}
}

GameData* GameData::FromJson(const Json::Value& jsonObj)
{
	if (jsonObj.isNull()) return NULL;
	
	GameData* gd = new GameData;
	gd->PopulateFromJson(jsonObj);
	return gd;
}
