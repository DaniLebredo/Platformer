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

#import "CustomLayer.h"
#import "StdInclude.h"

class LevelController;

@class TextLabel;


@interface LevelCompleteLayer : CustomLayer
{
	LevelController* mLevelController;		// weak ref
	
	TextLabel* mLabel;
	
	TextLabel* mCoinsLabel;
	TextLabel* mTimeLabel;
	
	NSMutableArray* mLives;
	
	CCSprite* mCoinsIcon;
	CCSprite* mTimeIcon;
	
	NSMutableArray* mStars;
	NSMutableArray* mGlitter;
	
	ccTime mTimer;
	bool mShortBreak;
	
	int mCountedCoins;
	int mCountedLives;
	int mCountedTime;
}

-(id) initWithLevelController:(LevelController*)controller;

-(void) calculateStats;

-(void) countCoins;
-(void) countLives;
-(void) showTime;

-(void) showStarAtIndex:(int)index;
-(void) showGlitterForStarAtIndex:(int)index;

-(void) setStarAtIndex:(int)index success:(BOOL)success;

-(void) preDisplay;

@end
