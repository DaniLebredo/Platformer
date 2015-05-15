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

#ifndef TILE_H
#define TILE_H

#import "GameObjectFSM.h"


typedef enum
{
	Tile_Empty = 0,
	
	Tile_SpikesDown1 = 48,
	Tile_SpikesDown2 = 49,
	Tile_SpikesUp = 67,
	Tile_SpikesLeft = 86,
	Tile_SpikesRight = 105,
	
	Tile_ThinFloor1 = 46,
	//Tile_ThinFloor2 = 46,
	
	Tile_HalfFloorLeft = 115,
	Tile_HalfFloorMiddle1 = 116,
	Tile_HalfFloorMiddle2 = 119,
	Tile_HalfFloorRight = 117,
	
} TileType;


class Tile : public GameObjectFSM<Tile>
{
public:
	Tile(LevelController* level, CGPoint pos, int type, float width, float height);
	Tile(LevelController* level, CGPoint pos, int type, const Point2iVector& vertices);
	virtual ~Tile();
	
	int Type() const { return mType; }
	
	void BeginContact(CollisionInfo* collisionInfo);
	void EndContact(CollisionInfo* collisionInfo);
	void PreSolve(CollisionInfo* collisionInfo);
	void ProcessContacts();
	
private:
	int mType;
};

#endif
