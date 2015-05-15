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

#import "TextData.h"
#import "Game.h"

void TextData::SetText(const std::string& lang, const std::string& text, bool small)
{
	mText[lang] = text;
	mSmall[lang] = small;
}

const std::string& TextData::Text(const std::string& lang) const
{
	StrStrMap::const_iterator it = mText.find(lang);
	
	if (it == mText.end())
	{
		// English version is always available.
		it = mText.find("en");
	}
	
	return it->second;
}

bool TextData::Small(const std::string& lang) const
{
	StrBoolMap::const_iterator it = mSmall.find(lang);
	
	if (it == mSmall.end())
	{
		// English version is always available.
		it = mSmall.find("en");
	}
	
	return it->second;
}

TextData* TextData::FromJson(const Json::Value& jsonObj)
{
	if (jsonObj.isNull()) return NULL;
	
	const Json::Value& name = jsonObj["name"];
	if (name.isNull())
	{
		CCLOG(@"Text name not specified. Skipping...");
		return NULL;
	}
	
	const Json::Value& en = jsonObj["en"];
	if (en.isNull())
	{
		CCLOG(@"Mandatory English localization of \"%s\" text is missing. Skipping...", name.asString().c_str());
		return NULL;
	}
	
	TextData* txtData = new TextData;
	
	txtData->SetName(name.asString());
	
	// Get all available localizations.
	
	const StringVector& languages = Game::Instance()->Data().Languages();
	
	for (int index = 0; index < languages.size(); ++index)
	{
		const std::string& langKey = languages[index];
		
		const Json::Value& langObj = jsonObj[langKey];
		if (!langObj.isNull())
		{
			std::string text = langObj["text"].isNull() ? "" : langObj["text"].asString();
			bool small = langObj["small"].isNull() ? false : langObj["small"].asBool();
			txtData->SetText(langKey, text, small);
		}
	}
	
	return txtData;
}
