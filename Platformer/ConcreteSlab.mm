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

#import "ConcreteSlab.h"
#import "ConcreteSlabStates.h"
#import "LevelController.h"
#import "Game.h"


ConcreteSlab::ConcreteSlab(LevelController* level, CGPoint pos, NSDictionary* opt) :
	GameObjectFSM<ConcreteSlab>("ConcreteSlab", level, opt)
{
	mNode = [[CCSprite alloc] initWithFile:@"ConcreteSlab.png"];
	mNode.position = pos;
	if (Game::Instance()->DebugOn()) ((CCSprite*)mNode).opacity = 32;
	
	mPhyBody = instantiatePhysicsFor("ConcreteSlab", pos);
	
	State<ConcreteSlab>* startState = CommonState_Init<ConcreteSlab>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(ConcreteSlabState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

ConcreteSlab::~ConcreteSlab()
{
	// CCLOG(@"DEALLOC: ConcreteSlab");
	
	if (mPhyBody != NULL)
	{
		mPhyWorld->DestroyBody(mPhyBody);
		mPhyBody = NULL;
	}
}

void ConcreteSlab::Update(ccTime dt)
{
	GameObjectFSM::Update(dt);
}

void ConcreteSlab::BeginContact(CollisionInfo* colInfo)
{
	if (colInfo->ThisObjFixType == 180 && colInfo->OtherObject->Class() != "Tile")
	{
		mLevel->MsgDispatcher()->DispatchMsg(ID(), colInfo->OtherObject->ID(), Msg_BeginCollisionWithConcreteSlab, NULL);
	}
}

void ConcreteSlab::EndContact(CollisionInfo* colInfo)
{
	if (colInfo->ThisObjFixType == 180 && colInfo->OtherObject->Class() != "Tile")
	{
		mLevel->MsgDispatcher()->DispatchMsg(ID(), colInfo->OtherObject->ID(), Msg_EndCollisionWithConcreteSlab, NULL);
	}
}
