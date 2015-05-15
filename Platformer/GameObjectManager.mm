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

#import "GameObjectManager.h"
#import "GameObject.h"


GameObjectManager::GameObjectManager(bool freeMemoryOnRemove) :
	mFreeMemoryOnRemove(freeMemoryOnRemove)
{
}

GameObjectManager::~GameObjectManager()
{
	RemoveAllGameObjects();
}

void GameObjectManager::AddGameObject(GameObject* gObj)
{
	assert(gObj != NULL && "<GameObjectManager::AddGameObject>: Game object is NULL.");
	
	// Platforms need to appear before Player in the list because Player's position
	// could depend on some Platform's position being calculated correctly before.
	// That's why they're simply put to the front of the list.
	if (gObj->Class() == "Platform")
	{
		mGameObjList.push_front(gObj);
	}
	// This is to make sure that EndOfLevel object appears last in the list. That's
	// because we don't want anything to happen after Player reached the EndOfLevel.
	else if (!mGameObjList.empty() && mGameObjList.back()->Class() == "EndOfLevel")
	{
		GameObjList::iterator it = mGameObjList.end();
		--it;
		mGameObjList.insert(it, gObj);
	}
	else
	{
		mGameObjList.push_back(gObj);
	}
	
	mGameObjIntMap.insert(std::make_pair(gObj->ID(), gObj));
	
	if (gObj->Tag().length() > 0)
		mGameObjStrMap.insert(std::make_pair(gObj->Tag(), gObj));
}

void GameObjectManager::AddGameObjectList(const GameObjList& gObjList)
{
	for (GameObjList::const_iterator it = gObjList.begin(); it != gObjList.end(); ++it)
		AddGameObject(*it);
}

void GameObjectManager::RemoveGameObject(GameObject* gObj)
{
	assert(gObj != NULL && "<GameObjectManager::RemoveGameObject>: Game object is NULL.");
	
	GameObjList::iterator listIter = std::find(mGameObjList.begin(), mGameObjList.end(), gObj);
	if (listIter != mGameObjList.end()) mGameObjList.erase(listIter);
	
	GameObjIntMap::iterator intMapIter = mGameObjIntMap.find(gObj->ID());
	if (intMapIter != mGameObjIntMap.end()) mGameObjIntMap.erase(intMapIter);
	
	if (gObj->Tag().length() > 0)
	{
		GameObjStrMap::iterator strMapIter = mGameObjStrMap.find(gObj->Tag());
		if (strMapIter != mGameObjStrMap.end()) mGameObjStrMap.erase(strMapIter);
	}
	
	if (mFreeMemoryOnRemove)
	{
		delete gObj;
		gObj = NULL;
	}
}

void GameObjectManager::RemoveGameObjectList(const GameObjList& gObjList)
{
	for (GameObjList::const_iterator it = gObjList.begin(); it != gObjList.end(); ++it)
		RemoveGameObject(*it);
}

void GameObjectManager::RemoveAllGameObjects()
{
	if (mFreeMemoryOnRemove)
	{
		for (GameObjList::const_iterator it = mGameObjList.begin(); it != mGameObjList.end(); ++it)
		{
			delete *it;
		}
	}
	
	mGameObjList.clear();
	mGameObjIntMap.clear();
	mGameObjStrMap.clear();
}

GameObject* GameObjectManager::GetGameObjectByID(int id) const
{
	GameObjIntMap::const_iterator gObj = mGameObjIntMap.find(id);
	return (gObj != mGameObjIntMap.end()) ? gObj->second : NULL;
}

GameObject* GameObjectManager::GetGameObjectByTag(const std::string& tag) const
{
	GameObjStrMap::const_iterator gObj = mGameObjStrMap.find(tag);
	return (gObj != mGameObjStrMap.end()) ? gObj->second : NULL;
}
