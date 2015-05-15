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

#import "Sign.h"
#import "SignStates.h"
#import "LevelController.h"
#import "Game.h"
#import "TextLabel.h"


Sign::Sign(LevelController* level, CGPoint pos, NSDictionary* opt) :
	GameObjectFSM<Sign>("Sign", level, opt),
	mDeltaTime(0),
	mMinDistance(5 * PNGMakeFloat(26)), mMinDistanceSquared(mMinDistance * mMinDistance)
{
	// --
	
	CCAction* fadeInAction = [[CCFadeTo alloc] initWithDuration:0.5 opacity:160];
	addAction("Show", fadeInAction);
	[fadeInAction release];
	
	// --
	
	CCAction* fadeOutAction = [[CCFadeTo alloc] initWithDuration:0.5 opacity:0];
	addAction("Hide", fadeOutAction);
	[fadeOutAction release];
	
	// --
	
	NSString* signText = @"<No Text>";
	
	if (opt)
	{
		NSString* text = [opt objectForKey:@"text"];
		NSString* locText = [opt objectForKey:@"locText"];
		
		if (text)
		{
			signText = [text retain]; // We have to retain it here, because a few lines below we release it!!
		}
		else if (locText)
		{
			mLocalizedName = locText.UTF8String;
			const std::string& strSign = Game::Instance()->Data().LocalizedText(mLocalizedName);
			signText = [[NSString alloc] initWithUTF8String:strSign.c_str()];
		}
	}
	
	mNode = [[TextLabel alloc] initWithStringValue:signText
											 width:PNGMakeFloat(150)
										 alignment:kCCTextAlignmentCenter
										 smallFont:true];
	
	[signText release];
	
	mNode.position = pos;
	mNode.scale = 1;
	((CCSprite*)mNode).opacity = 0;
	
	State<Sign>* startState = CommonState_Init<Sign>::Instance();
	FSM()->SetCurrentState(startState);
	FSM()->SetPreviousState(startState);
	FSM()->SetGlobalState(SignState_Global::Instance());
	FSM()->CurrentState()->Enter(this);
}

Sign::~Sign()
{
	// CCLOG(@"DEALLOC: Sign");
	
	[mNode stopAllActions];
}

bool Sign::IsPlayerNearby()
{
	float distanceSQ = ccpDistanceSQ(mLevel->PlayerObj()->Node().position, mNode.position);
	return distanceSQ <= mMinDistanceSquared;
}

void Sign::Refresh()
{
	if (mLocalizedName.length() > 0)
	{
		TextLabel* label = (TextLabel*)mNode;
		[label refreshWithLocalizedStringName:mLocalizedName smallFont:true];
	}
}

void Sign::Update(ccTime dt)
{
	mDeltaTime = dt;
	GameObjectFSM::Update(dt);
}

void Sign::UpdateDraw()
{
}

void Sign::UpdateDraw(float t)
{
}

void Sign::OnWentOnScreen()
{
}

void Sign::OnWentOffScreen()
{
}
