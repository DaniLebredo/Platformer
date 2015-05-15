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

#import "JsonManager.h"


JsonManager::JsonManager()
{
}

JsonManager::~JsonManager()
{
}

bool JsonManager::LoadJsonFromFile(const std::string& filename, const std::string& type, Json::Value& root)
{
	NSError* error;
	
	NSString* nsFilename = [NSString stringWithUTF8String:filename.c_str()];
	NSString* nsType = [NSString stringWithUTF8String:type.c_str()];
	
	NSString* path = [[NSBundle mainBundle] pathForResource:nsFilename ofType:nsType];
	NSString* fileData = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
	
	if (!fileData)
	{
		CCLOG(@"Error reading file: %s", filename.c_str());
		CCLOG(@"%@", [error description]);
		return false;
	}
	
	return ParseJsonFromString(fileData.UTF8String, root);
}

bool JsonManager::ParseJsonFromString(const std::string& json, Json::Value& root)
{
	Json::Reader reader;
	
	bool parsingSuccessful = reader.parse(json, root);
	if (!parsingSuccessful)
	{
		CCLOG(@"Error parsing JSON: %s", json.c_str());
		CCLOG(@"%s", reader.getFormattedErrorMessages().c_str());
	}
	else
	{
		CCLOG(@"%s", root.toStyledString().c_str());
	}
	
	return parsingSuccessful;
}
