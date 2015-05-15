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

#ifndef FRAMEANIMDATA_H
#define FRAMEANIMDATA_H

#import "StdInclude.h"


class FrameAnimData
{
public:
	FrameAnimData() : mNumFramesTotal(0), mNumFramesPerRow(0) {}
	
	void SetName(const std::string& name) { mName = name; }
	const std::string& Name() const { return mName; }
	
	void SetTextureName(const std::string& textureName) { mTextureName = textureName; }
	const std::string& TextureName() const { return mTextureName; }
	
	void SetNumFramesTotal(int numFramesTotal) { mNumFramesTotal = numFramesTotal; }
	int NumFramesTotal() const { return mNumFramesTotal; }
	
	void SetNumFramesPerRow(int numFramesPerRow) { mNumFramesPerRow = numFramesPerRow; }
	int NumFramesPerRow() const { return mNumFramesPerRow; }
	
	void SetOffset(float x, float y)
	{
		mOffset.x = x;
		mOffset.y = y;
	}
	CGPoint Offset() const { return mOffset; }
	
	void SetFrameSize(float width, float height)
	{
		mFrameSize.width = width;
		mFrameSize.height = height;
	}
	CGSize FrameSize() const { return mFrameSize; }
	
	static FrameAnimData* FromJson(const Json::Value& jsonObj);
	
private:
	std::string mName;
	std::string mTextureName;
	
	CGPoint mOffset;
	CGSize mFrameSize;
	
	int mNumFramesTotal;
	int mNumFramesPerRow;
};

#endif
