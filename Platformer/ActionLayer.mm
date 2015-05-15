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

#import "ActionLayer.h"
#import "Game.h"
#import "LevelController.h"
#import "GameObject.h"
#import "Pendulum.h"
#import "Stomper.h"


@implementation ActionLayer

@synthesize tileMap = mTileMap;

-(id) init
{
	return nil;
}

-(id) initWithLevelController:(LevelController*)controller
{
	self = [super init];
	if (self)
	{
		mSceneController = controller;
		
		mPhyWorld = controller->PhyWorld();
		mPtmRatio = controller->PtmRatio();
		
		[self initVisuals];
	}
	return self;
}

-(void) dealloc
{
	CCLOG(@"DEALLOC: ActionLayer");
	
	mSceneController = NULL;
	
	// Clean up visuals.
	[mTileMap release];
	[mCoinsBatch release];
	[mBulletsBatch release];
	
	delete mDebugDraw;
	mDebugDraw = NULL;
	
	[super dealloc];
}

-(void) initVisuals
{
	NSString* levelName = [NSString stringWithFormat:@"Level%d%d.tmx",
						   mSceneController->WorldId() + 1,
						   mSceneController->LevelId() + 1];
	
	CCLOG(@"LEVEL NAME: %@", levelName);
	
	mTileMap = [[HKTMXTiledMap alloc] initWithTMXFile:levelName];
	[self addChild:mTileMap z:0];
	if (Game::Instance()->DebugOn()) mTileMap.visible = NO;
	
	HKTMXLayer* frontLayer = [mTileMap layerNamed:@"Front"];
	mZOrderFront = frontLayer.zOrder;
	
	HKTMXLayer* preFrontLayer = [mTileMap layerNamed:@"PreFront"];
	mZOrderPreFront = preFrontLayer.zOrder;
	
	mCoinsBatch = [[CCSpriteBatchNode alloc] initWithFile:@"Coin2.png" capacity:150];
	[mTileMap addChild:mCoinsBatch z:mZOrderFront + 10];
	
	mBulletsBatch = [[CCSpriteBatchNode alloc] initWithFile:@"Bullet.png" capacity:50];
	[mTileMap addChild:mBulletsBatch z:mZOrderFront + 70];
	
	// ---
	
	mDebugDraw = new GLESDebugDraw(mPtmRatio);
	mPhyWorld->SetDebugDraw(mDebugDraw);
	
	// Physics debug draw.
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
			flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
			flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	mDebugDraw->SetFlags(flags);
}

-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	
	[super draw];
	
	if (Game::Instance()->DebugOn())
	{
		ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position);
		kmGLPushMatrix();
		mPhyWorld->DrawDebugData();
		kmGLPopMatrix();
	}
}

-(void) addGameObject:(GameObject*)gObj
{
	std::string gObjClass = gObj->Class();
	CCNode* gObjNode = gObj->Node();
	
	if (gObjClass == "Explosion" || gObjClass == "Ghost")
	{
		[mTileMap addChild:gObjNode z:mZOrderPreFront + 50];
	}
	else if (gObjClass == "Flash" || gObjClass == "SmokeRun" || gObjClass == "SmokeJump" ||
			 gObjClass == "BoulderSmoke")
	{
		[mTileMap addChild:gObjNode z:mZOrderFront + 80];
	}
	else if (gObjClass == "Player" || gObjClass == "PlayerGravity")
	{
		[mTileMap addChild:gObjNode z:mZOrderFront + 75];
	}
	else if (gObjClass == "Bullet")
	{
		[mBulletsBatch addChild:gObjNode]; // z = mZOrderFront + 70
	}
	else if (gObj->IsEnemy())
	{
		if (gObjClass == "Jumper")
			[mTileMap addChild:gObjNode z:mZOrderFront + 67];
		else [mTileMap addChild:gObjNode z:mZOrderFront + 65];
	}
	else if (gObjClass == "Boulder")
	{
		[mTileMap addChild:gObjNode z:mZOrderFront + 63];
	}
	else if (gObjClass == "Cannon")
	{
		[mTileMap addChild:gObjNode z:mZOrderFront + 60];
	}
	else if (gObjClass == "VampireBullet" || gObjClass == "CannonBall" || gObjClass == "Bomb")
	{
		[mTileMap addChild:gObjNode z:mZOrderFront + 55];
	}
	else if (gObjClass == "Pendulum")
	{
		CCNode* gObjNodeMovable = static_cast<Pendulum*>(gObj)->NodeMovable();
		[mTileMap addChild:gObjNode z:mZOrderFront + 35];
		[mTileMap addChild:gObjNodeMovable z:mZOrderFront + 34];
	}
	else if (gObjClass == "Stomper")
	{
		CCNode* gObjNodeMovable = static_cast<Stomper*>(gObj)->NodeMovable();
		[mTileMap addChild:gObjNode z:mZOrderFront + 31];
		[mTileMap addChild:gObjNodeMovable z:mZOrderFront + 30];
	}
	else if (gObjClass == "Platform")
	{
		[mTileMap addChild:gObjNode z:mZOrderFront + 25];
	}
	else if (gObjClass == "CrackedTile" || gObjClass == "Door" ||
			 gObjClass == "ConcreteSlab" || gObjClass == "Barrel")
	{
		[mTileMap addChild:gObjNode z:mZOrderFront + 15];
	}
	else if (gObjClass == "Key")
	{
		[mTileMap addChild:gObjNode z:mZOrderFront + 10];
	}
	else if (gObjClass == "Coin")
	{
		[mCoinsBatch addChild:gObjNode]; // z = mZOrderFront + 10
	}
	else if (gObjClass == "EndOfLevel" || gObjClass == "Button")
	{
		[mTileMap addChild:gObjNode z:mZOrderFront + 5];
	}
	else
	{
		[mTileMap addChild:gObjNode z:mZOrderFront + 95];
	}
}

@end
