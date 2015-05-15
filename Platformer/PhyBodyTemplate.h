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

#ifndef PHYBODYTEMPLATE_H
#define PHYBODYTEMPLATE_H

#import "StdInclude.h"
#import "Repository.h"
#import "PhyFixtureTemplate.h"


class PhyBodyTemplate
{
public:
	void SetName(const std::string& name) { mName = name; }
	const std::string& Name() const { return mName; }
	
	b2BodyDef& BodyDef() { return mBodyDef; }
	
	Repository<PhyFixtureTemplate>& PhyFixtureRepo() { return mPhyFixtureRepo; }
	
	b2Body* Instantiate(b2World* world, const b2Vec2& pos, void* userData);
	
	static PhyBodyTemplate* FromJson(const Json::Value& jsonObj);
	
private:
	std::string mName;
	b2BodyDef mBodyDef;
	
	Repository<PhyFixtureTemplate> mPhyFixtureRepo;
};

#endif
