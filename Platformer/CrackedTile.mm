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

#import "CrackedTile.h"
#import "CrackedTileStates.h"
#import "LevelController.h"
#import "Game.h"


CrackedTile::CrackedTile(LevelController* level, CGPoint pos, NSDictionary* opt) :
	GameObjectFSM<CrackedTile>("CrackedTile", level, opt),
	mHitCount(0)
{
	// ---
	
	int frames[] = { 3, 4, 5, 6 };
	int numFrames = sizeof(frames) / sizeof(int);
	addAction("Default", frames, numFrames, "CrackedTile", 0.05, false);
	
	// ---
	
	if (opt)
	{
		NSString* hitCount = [opt objectForKey:@"hitCount"];
		if (hitCount) mHitCount = Clamp([hitCount intValue], 0, 2);
	}
	
	NSString* name = [NSString stringWithFormat:@"CrackedTile%d", mHitCount];
	mNode = [[CCSprite alloc] initWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:name]];
	//mNode = [[CCSprite alloc] initWithFile:@"CrackedTile.png"];
	mNode.position = pos;
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 32;
	
	mPhyBody = instantiatePhysicsFor("CrackedTile", pos);
	
	State<CrackedTile>* startState = CommonState_Init<CrackedTile>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(CrackedTileState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

CrackedTile::~CrackedTile()
{
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void CrackedTile::IncreaseHitCount()
{
	++mHitCount;
	
	if (mHitCount <= 3)
	{
		if (mHitCount < 3)
		{
			CCSprite* sprite = (CCSprite*)mNode;
			NSString* name = [[NSString alloc] initWithFormat:@"CrackedTile%d", mHitCount];
			sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:name];
			[name release];
		}
		
		b2Vec2 deltaPos = mPhyBody->GetPosition() - mLevel->PlayerObj()->PhyBody()->GetPosition();
		SoundManager::Instance()->ScheduleDampenedEffect("CrackedTile.caf", deltaPos);
	}
}

void CrackedTile::Update(ccTime dt)
{
	GameObjectFSM::Update(dt);
}

void CrackedTile::OnWentOnScreen()
{
	if (!mNode.visible)
		mNode.visible = YES;
}

void CrackedTile::OnWentOffScreen()
{
	if (mNode.visible)
		mNode.visible = NO;
}
