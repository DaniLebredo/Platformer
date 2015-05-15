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

#ifndef GAMEOBJECTMANAGER_H
#define GAMEOBJECTMANAGER_H

#import "StdInclude.h"


class GameObjectManager
{
public:
	GameObjectManager(bool freeMemoryOnRemove = false);
	~GameObjectManager();
	
	void AddGameObject(GameObject* gObj);
	void AddGameObjectList(const GameObjList& gObjList);
	void RemoveGameObject(GameObject* gObj);
	void RemoveGameObjectList(const GameObjList& gObjList);
	void RemoveAllGameObjects();
	GameObject* GetGameObjectByID(int id) const;
	GameObject* GetGameObjectByTag(const std::string& tag) const;
	
	GameObjList::const_iterator Begin() const { return mGameObjList.begin(); }
	GameObjList::const_iterator End() const { return mGameObjList.end(); }
	
private:
	GameObjList mGameObjList;
	GameObjIntMap mGameObjIntMap;
	GameObjStrMap mGameObjStrMap;
	
	bool mFreeMemoryOnRemove;
};

#endif
