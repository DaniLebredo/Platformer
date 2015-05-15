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

#import "PhyBodyTemplate.h"


PhyBodyTemplate* PhyBodyTemplate::FromJson(const Json::Value& jsonObj)
{
	if (jsonObj.isNull()) return NULL;
	
	Json::Value name = jsonObj["name"];
	if (name.isNull())
	{
		CCLOG(@"Body doesn't have a name. Skipping...");
		return NULL;
	}
	
	Json::Value type = jsonObj["type"];
	if (type.isNull())
	{
		CCLOG(@"Body type not specified. Skipping...");
		return NULL;
	}
	
	PhyBodyTemplate* phyTemplate = new PhyBodyTemplate;
	phyTemplate->SetName(name.asString());
	
	b2BodyDef& bodyDef = phyTemplate->BodyDef();
	
	if (type.asString() == "dynamic")
	{
		bodyDef.type = b2_dynamicBody;
	}
	else if (type.asString() == "kinematic")
	{
		bodyDef.type = b2_kinematicBody;
	}
	else if (type.asString() == "static")
	{
		bodyDef.type = b2_staticBody;
	}
	
	Json::Value fixedRotation = jsonObj["fixedRotation"];
	if (!fixedRotation.isNull())
		bodyDef.fixedRotation = fixedRotation.asBool();
	
	Json::Value bullet = jsonObj["bullet"];
	if (!bullet.isNull())
		bodyDef.bullet = bullet.asBool();
	
	Json::Value gravityScale = jsonObj["gravityScale"];
	if (!gravityScale.isNull())
		bodyDef.gravityScale = gravityScale.asFloat();
	
	// Recurse into each fixture attached to this body.
	Json::Value fixtures = jsonObj["fixtures"];
	if (!fixtures.isNull())
	{
		for (int index = 0; index < fixtures.size(); ++index)
		{
			phyTemplate->PhyFixtureRepo().AddItem(fixtures[index]);
		}
	}
	
	return phyTemplate;
}

b2Body* PhyBodyTemplate::Instantiate(b2World* world, const b2Vec2& pos, void* userData)
{
	b2BodyDef bodyDef = mBodyDef;
	bodyDef.position = pos;
	bodyDef.userData = userData;
	
	b2Body* body = world->CreateBody(&bodyDef);
	
	const StringVector& fixtureNames = mPhyFixtureRepo.ItemNames();
	
	for (int index = 0; index < fixtureNames.size(); ++index)
	{
		b2FixtureDef& fixDef = mPhyFixtureRepo.Item(fixtureNames[index]).FixtureDef();
		body->CreateFixture(&fixDef);
	}
	
	return body;
}
