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

#import "PhyFixtureTemplate.h"
#import "FixtureUserData.h"
#import "Game.h"


PhyFixtureTemplate::~PhyFixtureTemplate()
{
	delete mFixtureDef.shape;
	delete static_cast<FixtureUserData*>(mFixtureDef.userData);
}

PhyFixtureTemplate* PhyFixtureTemplate::FromJson(const Json::Value& jsonObj)
{
	if (jsonObj.isNull()) return NULL;
	
	Json::Value name = jsonObj["name"];
	if (name.isNull())
	{
		CCLOG(@"Fixture doesn't have a name. Skipping...");
		return NULL;
	}
	
	Json::Value shape = jsonObj["shape"];
	if (shape.isNull())
	{
		CCLOG(@"Fixture shape not specified. Skipping...");
		return NULL;
	}
	
	Json::Value type = shape["type"];
	if (type.isNull())
	{
		CCLOG(@"Fixture shape type not specified. Skipping...");
		return NULL;
	}
	
	PhyFixtureTemplate* phyFixTmpl = new PhyFixtureTemplate;
	phyFixTmpl->SetName(name.asString());
	
	b2FixtureDef& fixtureDef = phyFixTmpl->FixtureDef();
	
	if (type.asString() == "circle")
	{
		b2CircleShape* circle = new b2CircleShape;
		fixtureDef.shape = circle;
		
		Json::Value radius = shape["radius"];
		if (!radius.isNull())
			circle->m_radius = radius.asFloat();
		
		Json::Value position = shape["position"];
		if (!position.isNull())
		{
			Json::Value x = position["x"];
			Json::Value y = position["y"];
			
			if (!x.isNull() && !y.isNull())
				circle->m_p.Set(x.asFloat(), y.asFloat());
		}
	}
	else if (type.asString() == "box")
	{
		b2PolygonShape* polygon = new b2PolygonShape;
		fixtureDef.shape = polygon;
		
		b2Vec2 center = b2Vec2_zero;
		
		Json::Value position = shape["position"];
		if (!position.isNull())
		{
			Json::Value x = position["x"];
			Json::Value y = position["y"];
			
			if (!x.isNull() && !y.isNull())
				center.Set(x.asFloat(), y.asFloat());
		}
		
		Json::Value size = shape["size"];
		if (!size.isNull())
		{
			Json::Value width = size["width"];
			Json::Value height = size["height"];
			
			if (!width.isNull() && !height.isNull())
				polygon->SetAsBox(0.5 * width.asFloat(), 0.5 * height.asFloat(), center, 0);
		}
	}
	else if (type.asString() == "polygon")
	{
		b2PolygonShape* polygon = new b2PolygonShape;
		fixtureDef.shape = polygon;
		
		Json::Value vertices = shape["vertices"];
		if (!vertices.isNull())
		{
			b2Vec2 v[8];
			
			for (int index = 0; index < vertices.size(); ++index)
			{
				Json::Value x = vertices[index]["x"];
				Json::Value y = vertices[index]["y"];
				
				if (!x.isNull() && !y.isNull())
				{
					v[index].x = x.asFloat();
					v[index].y = y.asFloat();
				}
			}
			
			polygon->Set(v, vertices.size());
		}
	}
	
	Json::Value filter = jsonObj["filter"];
	if (!filter.isNull())
	{
		Json::Value category = filter["category"];
		if (!category.isNull())
		{
			fixtureDef.filter.categoryBits = Game::Instance()->Data().Categories(category.asString());
		}
		
		Json::Value mask = filter["mask"];
		if (!mask.isNull())
		{
			fixtureDef.filter.maskBits = Game::Instance()->Data().Masks(mask.asString());
		}
		
		Json::Value group = filter["group"];
		if (!group.isNull())
		{
			fixtureDef.filter.groupIndex = Game::Instance()->Data().Groups(group.asString());
		}
	}
	
	Json::Value friction = jsonObj["friction"];
	if (!friction.isNull())
		fixtureDef.friction = friction.asFloat();
	
	Json::Value density = jsonObj["density"];
	if (!density.isNull())
		fixtureDef.density = density.asFloat();
	
	Json::Value restitution = jsonObj["restitution"];
	if (!restitution.isNull())
		fixtureDef.restitution = restitution.asFloat();
	
	Json::Value sensor = jsonObj["sensor"];
	if (!sensor.isNull())
		fixtureDef.isSensor = sensor.asBool();
	
	
	FixtureUserData* fixUserData = new FixtureUserData;
	fixtureDef.userData = static_cast<void*>(fixUserData);
	
	Json::Value userData = jsonObj["userData"];
	if (!userData.isNull())
	{
		Json::Value type = userData["type"];
		if (!type.isNull())
			fixUserData->Type = type.asInt();
		
		Json::Value killsPlayer = userData["killsPlayer"];
		if (!killsPlayer.isNull())
			fixUserData->KillsPlayer = killsPlayer.asBool();
		
		Json::Value killsEnemy = userData["killsEnemy"];
		if (!killsEnemy.isNull())
			fixUserData->KillsEnemy = killsEnemy.asBool();
	}
	
	return phyFixTmpl;
}
