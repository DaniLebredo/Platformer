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

#ifndef GAMEDATA_H
#define GAMEDATA_H

#import "StdInclude.h"
#import "WorldData.h"
#import "Repository.h"
#import "ProductData.h"
#import "TextData.h"


class GameData
{
public:
	GameData();
	~GameData();
	
	WorldData& World(int worldId) { return *mWorlds[worldId]; }
	const WorldData& World(int worldId) const { return *mWorlds[worldId]; }
	int NumWorlds() const { return mWorlds.size(); }
	
	void AddWorld(const Json::Value& world);
	
	// Physics templates.
	Repository<PhyBodyTemplate>& PhyTemplateRepo() { return mPhyTemplateRepo; }
	uint16 Categories(const std::string& name) { return mCategories[name]; }
	uint16 Masks(const std::string& name) { return mMasks[name]; }
	int16 Groups(const std::string& name) { return mGroups[name]; }
	
	// Frame anim & texture repositories.
	Repository<FrameAnimData>& FrameAnimRepo(const std::string& name) { return mFrameAnimRepoMap[name]; }
	StringVector& TextureRepo(const std::string& name) { return mTextureRepoMap[name]; }
	
	Repository<ProductData>& ProductRepo() { return mProductRepository; }
	
	Repository<TextData>& TextRepo() { return mTextRepository; }
	void SetLanguage(const std::string& language);
	const std::string& Language() const { return mLanguages[mActiveLanguageIndex]; }
	void SelectNextLanguage() { mActiveLanguageIndex = (mActiveLanguageIndex + 1) % mLanguages.size(); }
	const StringVector& Languages() const { return mLanguages; }
	
	// Two helper functions to ease access to text data for current language.
	const std::string& LocalizedText(const std::string textName);
	bool LocalizedTextSmall(const std::string textName);
	
	NSString* ButtonFrameName(NSString* buttonName) { return [mButtonFrameNames objectForKey:buttonName]; }
	
	int TotalScore() const;
	int NumStarsCollected() const;
	void UnlockAvailableWorlds();
	
	void PopulateFromJson(const Json::Value& jsonObj);
	static GameData* FromJson(const Json::Value& jsonObj);
	
private:
	void loadWorldsFile(const std::string& filename);
	void loadPhysicsFile(const std::string& filename);
	void loadScenesFile(const std::string& filename);
	void loadProductsFile(const std::string& filename);
	void loadTextsFile(const std::string& filename);
	
	void loadPhyTemplateFromFile(const std::string& filename);
	void loadWorldDataFromFile(const std::string& filename);
	void loadSceneDataFromFile(const std::string& filename);
	void parseFrameAnims(const Json::Value& frameAnims, Repository<FrameAnimData>& frameAnimRepo);
	void parseTextures(const Json::Value& textures, StringVector& textureRepo);
	
	std::vector<WorldData*> mWorlds;
	
	Repository<PhyBodyTemplate> mPhyTemplateRepo;
	StrUint16Map mCategories;
	StrUint16Map mMasks;
	StrInt16Map mGroups;
	
	std::map<std::string, Repository<FrameAnimData> > mFrameAnimRepoMap;
	std::map<std::string, StringVector> mTextureRepoMap;
	
	Repository<ProductData> mProductRepository;
	
	Repository<TextData> mTextRepository;
	
	std::vector<std::string> mLanguages;
	int mActiveLanguageIndex;
	
	NSMutableDictionary* mButtonFrameNames;
};

#endif
