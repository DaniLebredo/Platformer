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

#ifndef STDINCLUDE_H
#define STDINCLUDE_H

#import "cocos2d.h"
#import "Box2D.h"
#import "json.h"
#import <string>
#import <vector>
#import <list>
#import <map>
#import <set>
#import <algorithm>
#import <sstream>
#import <iomanip>


template<typename T> class Repository;
class FrameAnimData;
class PhyBodyTemplate;
class GameObject;
class Tile;
class SceneController;


typedef std::vector<int> IntVector;
typedef std::vector<bool> BoolVector;
typedef std::vector<std::string> StringVector;
typedef std::map<std::string, uint16> StrUint16Map;
typedef std::map<std::string, int16> StrInt16Map;
typedef std::map<std::string, bool> StrBoolMap;
typedef std::map<std::string, float> StrFloatMap;
typedef std::map<std::string, std::string> StrStrMap;
typedef std::list<GameObject*> GameObjList;
typedef std::map<int, GameObject*> GameObjIntMap;
typedef std::map<std::string, GameObject*> GameObjStrMap;
typedef std::list<Tile*> TileList;
typedef std::list<SceneController*> SceneList;

struct Point2i
{
	Point2i() : x(0), y(0) {}
	Point2i(int x, int y) : x(x), y(y) {}
	Point2i(const Point2i& p) : x(p.x), y(p.y) {}
	
	Point2i& operator=(const Point2i& rhs)
	{
		if (this != &rhs)
		{
			x = rhs.x;
			y = rhs.y;
		}
		return *this;
	}
	
	bool operator==(const Point2i& other) const { return x == other.x && y == other.y; }
	bool operator!=(const Point2i& other) const { return !(*this == other); }
	
	int x;
	int y;
};

typedef std::vector<Point2i> Point2iVector;

#endif
