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

#import "FrameAnimData.h"


FrameAnimData* FrameAnimData::FromJson(const Json::Value& jsonObj)
{
	if (jsonObj.isNull()) return NULL;
	
	const Json::Value& name = jsonObj["name"];
	if (name.isNull())
	{
		CCLOG(@"Frame anim name not specified. Skipping...");
		return NULL;
	}
	
	const Json::Value& textureName = jsonObj["texture"];
	if (textureName.isNull())
	{
		CCLOG(@"Frame anim texture not specified. Skipping...");
		return NULL;
	}
	
	FrameAnimData* faData = new FrameAnimData;
	
	faData->SetName(name.asString());
	faData->SetTextureName(textureName.asString());
	
	const Json::Value& numFramesTotal = jsonObj["numFramesTotal"];
	if (!numFramesTotal.isNull())
		faData->SetNumFramesTotal(numFramesTotal.asInt());
	
	const Json::Value& numFramesPerRow = jsonObj["numFramesPerRow"];
	if (!numFramesPerRow.isNull())
		faData->SetNumFramesPerRow(numFramesPerRow.asInt());
	
	const Json::Value& offset = jsonObj["offset"];
	if (!offset.isNull())
	{
		const Json::Value& x = offset["x"];
		const Json::Value& y = offset["y"];
		
		if (!x.isNull() && !y.isNull())
			faData->SetOffset(x.asFloat(), y.asFloat());
	}
	
	const Json::Value& frameSize = jsonObj["frameSize"];
	if (!frameSize.isNull())
	{
		const Json::Value& width = frameSize["width"];
		const Json::Value& height = frameSize["height"];
		
		if (!width.isNull() && !height.isNull())
			faData->SetFrameSize(width.asFloat(), height.asFloat());
	}
	
	return faData;
}
