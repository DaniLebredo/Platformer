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

#import "Tile.h"
#import "TileStates.h"
#import "LevelController.h"
#import "Game.h"


Tile::Tile(LevelController* level, CGPoint pos, int type, float width, float height) :
	GameObjectFSM<Tile>("Tile", level),
	mType(type)
{
	// Physics
	b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(pos.x / mPtmRatio, pos.y / mPtmRatio);
	bodyDef.userData = this;
	mPhyBody = mPhyWorld->CreateBody(&bodyDef);
	
	float widthMultiplier = 0.5;
	float heightMultiplier = 0.5;
	b2Vec2 offset = b2Vec2_zero;
	
	b2PolygonShape shape;
	
	switch (type)
	{
		case Tile_HalfFloorLeft:
		case Tile_HalfFloorRight:
		case Tile_HalfFloorMiddle1:
		case Tile_HalfFloorMiddle2:
			offset = b2Vec2(0, 0.25);
			heightMultiplier = 0.25;
			break;
			
		case Tile_ThinFloor1:
		//case Tile_ThinFloor2:
			offset = b2Vec2(0, 0.375);
			heightMultiplier = 0.125;
			break;
			
		case Tile_SpikesUp:
			offset = b2Vec2(0, 0.25);
			heightMultiplier = 0.25;
			width -= 0.2;
			break;
			
		case Tile_SpikesDown1:
		case Tile_SpikesDown2:
			offset = b2Vec2(0, -0.25);
			heightMultiplier = 0.25;
			width -= 0.2;
			break;
			
		case Tile_SpikesLeft:
			offset = b2Vec2(-0.25, 0);
			widthMultiplier = 0.25;
			height -= 0.4; // this is bigger than 0.2 because of foot sensor height
			break;
			
		case Tile_SpikesRight:
			offset = b2Vec2(0.25, 0);
			widthMultiplier = 0.25;
			height -= 0.4; // this is bigger than 0.2 because of foot sensor height
			break;
			
		default:
			break;
	}
	
	shape.SetAsBox(widthMultiplier * width, heightMultiplier * height, offset, 0);
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;
	fixtureDef.density = 1;
	fixtureDef.friction = 1;
	fixtureDef.filter.categoryBits = Game::Instance()->Data().Categories("CATEGORY_GROUND");
	fixtureDef.filter.maskBits = Game::Instance()->Data().Masks("MASK_ALL");
	
	FixtureUserData* fixUserData = new FixtureUserData(2, false);
	fixtureDef.userData = static_cast<void*>(fixUserData);
	
	switch (type)
	{
		case Tile_SpikesUp:
		case Tile_SpikesDown1:
		case Tile_SpikesDown2:
		case Tile_SpikesLeft:
		case Tile_SpikesRight:
			fixUserData->KillsPlayer = true;
			fixUserData->KillsEnemy = true;
			break;
			
		default:
			break;
	}
	
	mPhyBody->CreateFixture(&fixtureDef);
	
	State<Tile>* startState = TileState_Normal::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(TileState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Tile::Tile(LevelController* level, CGPoint pos, int type, const Point2iVector& vertices) :
	GameObjectFSM<Tile>("Tile", level),
	mType(type)
{
	if (vertices.size() == 0)
		throw "<Tile::ctor> List of vertices is empty.";
	
	// Physics
	b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(pos.x / mPtmRatio, pos.y / mPtmRatio);
	bodyDef.userData = this;
	mPhyBody = mPhyWorld->CreateBody(&bodyDef);
	
	b2Vec2* vertArray = new b2Vec2[vertices.size()];
	
	for (int index = 0; index < vertices.size(); ++index)
	{
		vertArray[index].x = vertices[index].x;
		vertArray[index].y = vertices[index].y;
	}
	
	b2ChainShape shape;
	//shape.CreateChain(vertArray, vertices.size());
	shape.CreateLoop(vertArray, vertices.size());
	
	delete vertArray;
	vertArray = NULL;
	
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;
	fixtureDef.density = 1;
	fixtureDef.friction = 1;
	fixtureDef.filter.categoryBits = Game::Instance()->Data().Categories("CATEGORY_GROUND");
	fixtureDef.filter.maskBits = Game::Instance()->Data().Masks("MASK_ALL");
	fixtureDef.userData = static_cast<void*>(new FixtureUserData(2, false));
	
	mPhyBody->CreateFixture(&fixtureDef);
	
	State<Tile>* startState = TileState_Normal::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(TileState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Tile::~Tile()
{
	if (mPhyBody != NULL)
	{
		FixtureUserData* fixUserData = static_cast<FixtureUserData*>(mPhyBody->GetFixtureList()->GetUserData());
		
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
		
		delete fixUserData;
		fixUserData = NULL;
	}
}

void Tile::ProcessContacts()
{
}

void Tile::PreSolve(CollisionInfo* colInfo)
{
	switch (mType)
	{
		case Tile_ThinFloor1:
		//case Tile_ThinFloor2:
			if (colInfo->OtherObject->Class() == "Player" ||
				colInfo->OtherObject->Class() == "Barrel" ||
				colInfo->OtherObject->IsEnemy())
			{
				if (colInfo->OtherObject->PhyBody()->GetLinearVelocity().y > 0 ||
					colInfo->OtherObject->PhyBody()->GetPosition().y - mPhyBody->GetPosition().y < 0.5 + 0.5 - 0.05)
				{
					colInfo->Contact->SetEnabled(false);
				}
			}
			break;
			
		default:
			break;
	}
}

void Tile::BeginContact(CollisionInfo* colInfo)
{
}

void Tile::EndContact(CollisionInfo* colInfo)
{
}
