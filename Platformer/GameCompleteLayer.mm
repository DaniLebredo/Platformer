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

#import "GameCompleteLayer.h"
#import "LevelController.h"
#import "Game.h"
#import "TextButton.h"
#import "TextLabel.h"
#import "Fireworks.h"


@implementation GameCompleteLayer

-(id) initWithSceneController:(SceneController*)controller color:(ccColor4B)color
{
	return nil;
}

-(id) initWithLevelController:(LevelController*)controller
{
	self = [super initWithSceneController:controller color:ccc4(16, 16, 16, 230)];
	if (self)
	{
		self.touchEnabled = NO;
		self.visible = NO;
		
		mLevelController = controller;
		
		mElapsedTime = 0;
		
		// --------------
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		CGFloat labelOffset = PNGMakeFloat(25);
		
		// --------------
		
		CCSprite* lanceUp = [[CCSprite alloc] initWithFile:@"LanceUp.png"];
		lanceUp.position = ccp(0.5 * winSize.width, 0.5 * winSize.height - PNGMakeFloat(20));
		[self addChild:lanceUp];
		[lanceUp release];
		
		// --------------
		
		mStars = [[NSMutableArray alloc] initWithCapacity:6];
		mGlitter = [[NSMutableArray alloc] initWithCapacity:6];
		
		for (int i = 0; i < 6; ++i)
		{
			float sign = (i % 2 == 0) ? -1 : 1;		// Left or right star.
			float margin = (i / 2 == 1) ? 1 : 0;	// Stars in 2nd row have smaller margin.
			
			CCSprite* star = [[CCSprite alloc] initWithSpriteFrameName:@"Star0"];
			star.position = ccp(0.5 * winSize.width + sign * (PNGMakeFloat(180) + margin * PNGMakeFloat(20)),
								0.5 * winSize.height + (1 - i / 2) * PNGMakeFloat(50));
			star.visible = NO;
			[self addChild:star];
			[mStars addObject:star];
			[star release];
			
			CCSprite* glitter = [[CCSprite alloc] initWithSpriteFrameName:@"Stars0"];
			glitter.position = star.position;
			glitter.scale = 2;
			glitter.visible = NO;
			[self addChild:glitter];
			[mGlitter addObject:glitter];
			[glitter release];
		}
		
		// --------------
		
		mLabel = [[TextLabel alloc] initWithStringValue:@""
												  width:PNGMakeFloat(400)
											  alignment:kCCTextAlignmentCenter
											  smallFont:false];
		
		mLabel.position = ccp(0.5 * winSize.width, winSize.height - labelOffset);
		mLabel.anchorPoint = ccp(0.5, 1);
		[self addChild:mLabel];
		
		mMessageLabel1 = [[TextLabel alloc] initWithStringValue:@""
														  width:PNGMakeFloat(360)
													  alignment:kCCTextAlignmentCenter
													  smallFont:true];
		
		mMessageLabel1.position = ccp(0.5 * winSize.width, 0.5 * winSize.height - PNGMakeFloat(105));
		mMessageLabel1.anchorPoint = ccp(0.5, 1);
		mMessageLabel1.color = ccc3(255, 255, 255);
		mMessageLabel1.opacity = 0;
		mMessageLabel1.userData = reinterpret_cast<void*>(0);
		[self addChild:mMessageLabel1];
		
		mMessageLabel2 = [[TextLabel alloc] initWithStringValue:@""
														  width:PNGMakeFloat(360)
													  alignment:kCCTextAlignmentCenter
													  smallFont:true];
		
		mMessageLabel2.position = mMessageLabel1.position;
		mMessageLabel2.anchorPoint = ccp(0.5, 1);
		mMessageLabel2.color = mMessageLabel1.color;
		mMessageLabel2.opacity = mMessageLabel1.opacity;
		mMessageLabel2.userData = reinterpret_cast<void*>(0);
		[self addChild:mMessageLabel2];
		
		mMessageLabel3 = [[TextLabel alloc] initWithStringValue:@""
														  width:PNGMakeFloat(360)
													  alignment:kCCTextAlignmentCenter
													  smallFont:true];
		
		mMessageLabel3.position = mMessageLabel1.position;
		mMessageLabel3.anchorPoint = ccp(0.5, 1);
		mMessageLabel3.color = mMessageLabel1.color;
		mMessageLabel3.opacity = mMessageLabel1.opacity;
		mMessageLabel3.userData = reinterpret_cast<void*>(0);
		[self addChild:mMessageLabel3];
		
		// --------------
		
		CGFloat offset = PNGMakeFloat(5);
		
		TextButton* advanceButton = [[TextButton alloc] initWithName:@"OK"];
		advanceButton.position = ccp(winSize.width - offset - 0.5 * advanceButton.width, offset + 0.5 * advanceButton.height);
		[self addChild:advanceButton z:10];
		[mButtons setObject:advanceButton forKey:@"Advance"];
		[advanceButton release];
	}
	return self;
}

-(void) dealloc
{
	mLevelController = NULL;
	
	[mLabel release];
	[mMessageLabel1 release];
	[mMessageLabel2 release];
	[mMessageLabel3 release];
	
	[mStars release];
	[mGlitter release];
	
	[super dealloc];
}

-(void) showStarAtIndex:(int)index
{
	CCSprite* star = [mStars objectAtIndex:index];
	
	star.scale = 0;
	star.visible = YES;
	
	[star runAction:[CCEaseElasticOut actionWithAction:
					 [CCScaleTo actionWithDuration:1 scale:1]]];
}

-(void) showGlitterForStarAtIndex:(int)index
{
	CCSpriteFrameCache* sfc = [CCSpriteFrameCache sharedSpriteFrameCache];
	
	NSArray* spriteFrames = [[NSArray alloc] initWithObjects:
							 [sfc spriteFrameByName:@"Stars0"],
							 [sfc spriteFrameByName:@"Stars1"],
							 [sfc spriteFrameByName:@"Stars2"],
							 [sfc spriteFrameByName:@"Stars3"],
							 nil];
	
	CCAnimation* animation = [[CCAnimation alloc] initWithSpriteFrames:spriteFrames delay:0.05];
	CCFiniteTimeAction* animAction = [[CCAnimate alloc] initWithAnimation:animation];
	
	CCSprite* glitter = [mGlitter objectAtIndex:index];
	glitter.visible = YES;
	[glitter runAction:[CCSequence actions:animAction, [CCFadeTo actionWithDuration:0.2 opacity:0], nil]];
	
	[animAction release];
	[animation release];
	[spriteFrames release];
}

-(void) updateScrollingLabel:(TextLabel*)label
{
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	int state = reinterpret_cast<int>(label.userData);
	
	if (state == 1 && label.position.y > 0.5 * winSize.height + PNGMakeFloat(75))
	{
		label.userData = reinterpret_cast<void*>(2);
		[label runAction:[CCFadeTo actionWithDuration:0.5 opacity:0]];
	}
	else if (state == 0 && label.position.y > 0.5 * winSize.height - PNGMakeFloat(100))
	{
		label.userData = reinterpret_cast<void*>(1);
		[label runAction:[CCFadeTo actionWithDuration:0.5 opacity:255]];
	}
}

-(void) updateStars
{
	for (int index = 0; index < 3; ++index)
	{
		// Show a new pair of stars every 0.25 seconds.
		if (mElapsedTime < index * 0.25) break;
		
		CCSprite* star1 = [mStars objectAtIndex:index];
		if (!star1.visible)
		{
			[self showStarAtIndex:index];
			[self showGlitterForStarAtIndex:index];
		}
		
		int index2 = 6 - index - 1;
		CCSprite* star2 = [mStars objectAtIndex:index2];
		if (!star2.visible)
		{
			[self showStarAtIndex:index2];
			[self showGlitterForStarAtIndex:index2];
		}
	}
}

-(void) update:(ccTime)dt
{
	mElapsedTime += dt;
	
	mMessageLabel2.position = ccpAdd(mMessageLabel1.position, PNGMakePoint(0, -40));
	mMessageLabel3.position = ccpAdd(mMessageLabel2.position, PNGMakePoint(0, -40));
	
	[self updateScrollingLabel:mMessageLabel1];
	[self updateScrollingLabel:mMessageLabel2];
	[self updateScrollingLabel:mMessageLabel3];
	
	[self updateStars];
}

-(void) startScrolling
{
	CGSize winSize = [CCDirector sharedDirector].winSize;
	
	[mMessageLabel1 runAction:[CCMoveTo actionWithDuration:15 position:ccp(0.5 * winSize.width, 0.5 * winSize.height + PNGMakeFloat(300))]];
	
	// Scrolling will be handled in update function.
	[self scheduleUpdate];
}

-(void) preDisplayWorldCompleted
{
	const std::string& strWorldCompleted = Game::Instance()->Data().LocalizedText("WorldCompleted");
	NSString* worldCompletedText = [[NSString alloc] initWithUTF8String:strWorldCompleted.c_str()];
	NSString* titleText = [[NSString alloc] initWithFormat:worldCompletedText, Game::Instance()->Data().World(mLevelController->WorldId()).Name().c_str()];
	mLabel.string = titleText;
	[titleText release];
	[worldCompletedText release];
	
	// -----
	
	const std::string& strWorldCompletedMsg1 = Game::Instance()->Data().LocalizedText("WorldCompletedMsg1");
	NSString* worldCompletedMsg1Text = [[NSString alloc] initWithUTF8String:strWorldCompletedMsg1.c_str()];
	mMessageLabel1.string = worldCompletedMsg1Text;
	[worldCompletedMsg1Text release];
	
	const std::string& strWorldCompletedMsg2 = Game::Instance()->Data().LocalizedText("WorldCompletedMsg2");
	NSString* worldCompletedMsg2Text = [[NSString alloc] initWithUTF8String:strWorldCompletedMsg2.c_str()];
	mMessageLabel2.string = worldCompletedMsg2Text;
	[worldCompletedMsg2Text release];
	
	const std::string& strWorldCompletedMsg3 = Game::Instance()->Data().LocalizedText("WorldCompletedMsg3");
	NSString* worldCompletedMsg3Text = [[NSString alloc] initWithUTF8String:strWorldCompletedMsg3.c_str()];
	NSString* messageText = [[NSString alloc] initWithFormat:worldCompletedMsg3Text, Game::Instance()->Data().World(mLevelController->NextWorldId()).Name().c_str()];
	mMessageLabel3.string = messageText;
	[messageText release];
	[worldCompletedMsg3Text release];
	
	[self startScrolling];
	
	// -----
	
	TextButton* advanceButton = [mButtons objectForKey:@"Advance"];
	advanceButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Advance));
}

-(void) preDisplayGameCompleted
{
	const std::string& strGameCompleted = Game::Instance()->Data().LocalizedText("GameCompleted");
	NSString* gameCompletedText = [[NSString alloc] initWithUTF8String:strGameCompleted.c_str()];
	mLabel.string = gameCompletedText;
	[gameCompletedText release];
	
	// -----
	
	const std::string& strGameCompletedMsg1 = Game::Instance()->Data().LocalizedText("GameCompletedMsg1");
	NSString* gameCompletedMsg1Text = [[NSString alloc] initWithUTF8String:strGameCompletedMsg1.c_str()];
	mMessageLabel1.string = gameCompletedMsg1Text;
	[gameCompletedMsg1Text release];
	
	const std::string& strGameCompletedMsg2 = Game::Instance()->Data().LocalizedText("GameCompletedMsg2");
	NSString* gameCompletedMsg2Text = [[NSString alloc] initWithUTF8String:strGameCompletedMsg2.c_str()];
	mMessageLabel2.string = gameCompletedMsg2Text;
	[gameCompletedMsg2Text release];
	
	const std::string& strGameCompletedMsg3 = Game::Instance()->Data().LocalizedText("GameCompletedMsg3");
	NSString* gameCompletedMsg3Text = [[NSString alloc] initWithUTF8String:strGameCompletedMsg3.c_str()];
	mMessageLabel3.string = gameCompletedMsg3Text;
	[gameCompletedMsg3Text release];
	
	[self startScrolling];
	
	// -----
	
	TextButton* advanceButton = [mButtons objectForKey:@"Advance"];
	advanceButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Quit));
}

@end
