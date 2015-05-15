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

#import "WorldData.h"
#import "Game.h"
#import <algorithm>


WorldData::WorldData() :
	mLocked(true),
	mNumStarsToUnlock(0)
{
}

WorldData::~WorldData()
{
	for (int index = 0; index < mLevels.size(); ++index)
	{
		delete mLevels[index];
	}
	mLevels.clear();
	
	for (int index = 0; index < mTileAnims.size(); ++index)
	{
		delete mTileAnims[index];
	}
	mTileAnims.clear();
}

bool WorldData::CompletedAllLevels() const
{
	for (int levelId = 0; levelId < this->NumLevels(); ++levelId)
	{
		if (!this->Level(levelId).Completed()) return false;
	}
	
	return true;
}

bool WorldData::CollectedAllStars() const
{
	for (int levelId = 0; levelId < this->NumLevels(); ++levelId)
	{
		const LevelData& currLevel = this->Level(levelId);
		if (currLevel.NumStarsCollected() < currLevel.MaxNumStars()) return false;
	}
	
	return true;
}

int WorldData::NumStarsCollected() const
{
	int numStars = 0;
	
	for (int levelId = 0; levelId < this->NumLevels(); ++levelId)
	{
		numStars += this->Level(levelId).NumStarsCollected();
	}
	
	return numStars;
}

int WorldData::MaxNumStars() const
{
	int maxNumStars = 0;
	
	for (int levelId = 0; levelId < this->NumLevels(); ++levelId)
	{
		maxNumStars += this->Level(levelId).MaxNumStars();
	}
	
	return maxNumStars;
}

int WorldData::Score() const
{
	int score = 0;
	
	for (int levelId = 0; levelId < this->NumLevels(); ++levelId)
	{
		score += this->Level(levelId).Score();
	}
	
	return score;
}

void WorldData::AddLevel(const Json::Value& level)
{
	LevelData* ld = LevelData::FromJson(level);
	
	if (ld != NULL)
	{
		mLevels.push_back(ld);
	}
}

void WorldData::AddTileAnim(const Json::Value& tileAnim)
{
	TileAnimData* taData = TileAnimData::FromJson(tileAnim);
	
	if (taData != NULL)
	{
		mTileAnims.push_back(taData);
	}
}

WorldData* WorldData::FromJson(const Json::Value& jsonObj)
{
	if (jsonObj.isNull()) return NULL;
	
	WorldData* wd = new WorldData;
	
	const Json::Value& name = jsonObj["name"];
	if (!name.isNull())
		wd->SetName(name.asString());
	
	const Json::Value& locked = jsonObj["locked"];
	if (!locked.isNull())
	{
		if (Game::Instance()->Distributable() == Distributable_AdHoc ||
			Game::Instance()->Distributable() == Distributable_AppStore)
		{
			wd->SetLocked(locked.asBool());
		}
		else
		{
			wd->SetLocked(false);
		}
	}
	
	const Json::Value& starsToUnlock = jsonObj["starsToUnlock"];
	if (!starsToUnlock.isNull())
		wd->SetNumStarsToUnlock(starsToUnlock.asInt());
	
	const Json::Value& staticBackground = jsonObj["staticBackground"];
	if (!staticBackground.isNull())
		wd->SetStaticBackground(staticBackground.asString());
	
	const Json::Value& music = jsonObj["music"];
	if (!music.isNull())
		wd->SetMusic(music.asString());
	
	const Json::Value& tileAnims = jsonObj["tileAnims"];
	if (!tileAnims.isNull())
	{
		for (int index = 0; index < tileAnims.size(); ++index)
		{
			wd->AddTileAnim(tileAnims[index]);
		}
	}
	
	const Json::Value& frameAnims = jsonObj["frameAnims"];
	if (!frameAnims.isNull())
	{
		for (int index = 0; index < frameAnims.size(); ++index)
		{
			wd->FrameAnimRepo().AddItem(frameAnims[index]);
		}
	}
	
	const Json::Value& textures = jsonObj["textures"];
	if (!textures.isNull())
	{
		for (int index = 0; index < textures.size(); ++index)
		{
			wd->AddTexture(textures[index].asString());
		}
	}
	
	const Json::Value& levels = jsonObj["levels"];
	if (!levels.isNull())
	{
		for (int index = 0; index < levels.size(); ++index)
		{
			wd->AddLevel(levels[index]);
		}
	}
	
	return wd;
}
