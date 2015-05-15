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

#ifndef WORLDDATA_H
#define WORLDDATA_H

#import "StdInclude.h"
#import "LevelData.h"
#import "TileAnimData.h"
#import "FrameAnimData.h"
#import "Repository.h"


class WorldData
{
public:
	WorldData();
	~WorldData();
	
	void SetName(const std::string& name) { mName = name; }
	const std::string& Name() const { return mName; }
	
	LevelData& Level(int levelId) { return *mLevels[levelId]; }
	const LevelData& Level(int levelId) const { return *mLevels[levelId]; }
	int NumLevels() const { return mLevels.size(); }
	void AddLevel(const Json::Value& level);
	
	TileAnimData& TileAnim(int tileAnimIndex) { return *mTileAnims[tileAnimIndex]; }
	int NumTileAnims() const { return mTileAnims.size(); }
	void AddTileAnim(const Json::Value& tileAnim);
	
	Repository<FrameAnimData>& FrameAnimRepo() { return mFrameAnimRepo; }
	
	StringVector& TextureRepo() { return mTextureRepo; }
	const std::string& Texture(int textureIndex) { return mTextureRepo[textureIndex]; }
	int NumTextures() const { return mTextureRepo.size(); }
	void AddTexture(const std::string& texture) { mTextureRepo.push_back(texture); }
	
	void SetLocked(bool locked) { mLocked = locked; }
	bool Locked() const { return mLocked; }
	
	void SetNumStarsToUnlock(int numStarsToUnlock) { mNumStarsToUnlock = numStarsToUnlock; }
	int NumStarsToUnlock() const { return mNumStarsToUnlock; }
	
	void SetStaticBackground(const std::string& background) { mStaticBackground = background; }
	const std::string& StaticBackground() const { return mStaticBackground; }
	
	void SetMusic(const std::string& music) { mMusic = music; }
	const std::string& Music() const { return mMusic; }
	
	bool CompletedAllLevels() const;
	bool CollectedAllStars() const;
	
	int NumStarsCollected() const;
	int MaxNumStars() const;
	
	int Score() const;
	
	static WorldData* FromJson(const Json::Value& jsonObj);
	
private:
	std::string mName;
	
	std::vector<LevelData*> mLevels;
	std::vector<TileAnimData*> mTileAnims;
	
	Repository<FrameAnimData> mFrameAnimRepo;
	StringVector mTextureRepo;
	
	bool mLocked;
	int mNumStarsToUnlock;
	
	std::string mStaticBackground;
	std::string mMusic;
};

#endif
