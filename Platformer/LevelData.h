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

#ifndef LEVELDATA_H
#define LEVELDATA_H

#import "StdInclude.h"
#import "LevelType.h"


class LevelData
{
public:
	LevelData() : mType(Level_Normal), mNumStarsCollected(0), mTime(30), mLocked(true), mCompleted(false) {}
	
	void SetType(LevelType type) { mType = type; }
	LevelType Type() const { return mType; }
	
	void SetNumStarsCollected(int numStarsCollected) { mNumStarsCollected = numStarsCollected; }
	int NumStarsCollected() const { return mNumStarsCollected; }
	
	int MaxNumStars() const { return 3; }
	
	void SetTime(int time) { mTime = time; }
	int Time() const { return mTime; }
	
	void SetLocked(bool locked) { mLocked = locked; }
	bool Locked() const { return mLocked; }
	
	void SetCompleted(bool completed) { mCompleted = completed; }
	bool Completed() const { return mCompleted; }
	
	int Score() const;
	
	static LevelData* FromJson(const Json::Value& jsonObj);
	
private:
	LevelType mType;
	int mNumStarsCollected;
	int mTime;
	int mScore;
	bool mLocked;
	bool mCompleted;
};

#endif
