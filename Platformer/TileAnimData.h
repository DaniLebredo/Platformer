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

#ifndef TILEANIMDATA_H
#define TILEANIMDATA_H

#import "StdInclude.h"


class TileAnimData
{
public:
	TileAnimData() : mCurrID(0), mNextID(0), mDelay(0) {}
	
	void SetCurrentID(int currID) { mCurrID = currID; }
	int CurrentID() const { return mCurrID; }
	
	void SetNextID(int nextID) { mNextID = nextID; }
	int NextID() const { return mNextID; }
	
	void SetDelay(float delay) { mDelay = delay; }
	float Delay() const { return mDelay; }
	
	static TileAnimData* FromJson(const Json::Value& jsonObj);
	
private:
	int mCurrID;
	int mNextID;
	float mDelay;
};

#endif
