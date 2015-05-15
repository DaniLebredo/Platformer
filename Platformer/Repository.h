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

#ifndef REPOSITORY_H
#define REPOSITORY_H

#import "StdInclude.h"


template<typename T>
class Repository
{
public:
	Repository() {}
	
	~Repository()
	{
		typename std::map<std::string, T*>::iterator it;
		for (it = mItems.begin(); it != mItems.end(); ++it)
		{
			delete it->second;
		}
		mItems.clear();
	}
	
	T& Item(const std::string& name)
	{
		typename std::map<std::string, T*>::iterator it;
		it = mItems.find(name);
		
		if (it != mItems.end())
		{
			return *(it->second);
		}
		
		throw "<Repository::Item> Item with given name not found.";
	}
	
	bool ItemExists(const std::string& name)
	{
		typename std::map<std::string, T*>::iterator it;
		it = mItems.find(name);
		
		return it != mItems.end();
	}
	
	const StringVector& ItemNames() const { return mItemNames; }
	
	void AddItem(const Json::Value& jsonObj)
	{
		T* item = T::FromJson(jsonObj);
		
		if (item != NULL)
		{
			mItems[item->Name()] = item;
			mItemNames.push_back(item->Name());
		}
	}
	
private:
	std::map<std::string, T*> mItems;
	StringVector mItemNames;
};

#endif
