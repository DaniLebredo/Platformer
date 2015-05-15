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

#import "LevelData.h"
#import "Game.h"


int LevelData::Score() const
{
	if (mCompleted)
	{
		switch (mNumStarsCollected)
		{
			case 0: return 50;
			case 1: return 100;
			case 2: return 200;
			case 3: return 500;
				
			default: break;
		}
	}
	
	return 0;
}

LevelData* LevelData::FromJson(const Json::Value& jsonObj)
{
	if (jsonObj.isNull()) return NULL;
	
	LevelData* ld = new LevelData;
	
	const Json::Value& type = jsonObj["type"];
	if (!type.isNull())
	{
		std::string strType = type.asString();
		std::transform(strType.begin(), strType.end(), strType.begin(), ::tolower);
		
		if (strType == "normal")
			ld->SetType(Level_Normal);
		else if (strType == "gravity")
			ld->SetType(Level_Gravity);
		else if (strType == "jetpack")
			ld->SetType(Level_Jetpack);
	}
	
	const Json::Value& time = jsonObj["time"];
	if (!time.isNull())
		ld->SetTime(time.asInt());
	
	const Json::Value& locked = jsonObj["locked"];
	if (!locked.isNull())
	{
		if (Game::Instance()->Distributable() == Distributable_AdHoc ||
			Game::Instance()->Distributable() == Distributable_AppStore)
		{
			ld->SetLocked(locked.asBool());
		}
		else
		{
			ld->SetLocked(false);
		}
	}
	
	const Json::Value& completed = jsonObj["completed"];
	if (!completed.isNull())
		ld->SetCompleted(completed.asBool());
	
	return ld;
}
