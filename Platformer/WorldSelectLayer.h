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

class LevelSelectionController;

@class TextLabel;


@interface WorldSelectLayer : CustomLayer
{
	LevelSelectionController* mLevelSelectionController;
	
	CCSprite* mTemplate;
	CCSprite* mBackground;
	CCRenderTexture* mRenderTexture;
	
	TextLabel* mLabel;
	
	NSMutableArray* mButtonKeys;
	
	NSMutableArray* mWorldButtons;
	CCNode* mWorldButtonsHolder;
	UITouch* mWorldTouch;
	
	CGPoint mDeltaItemPos;
	
	CGFloat mTouchX;
	
	int mItemIndex;
	BOOL mMoved;
	bool mCanSwipe;
	
	bool mGesturesEnabled;
}

-(id) initWithLevelSelectionController:(LevelSelectionController*)controller;

-(void) showUI;
-(void) hideUI;

-(void) showWorlds;
-(void) centerWorld:(int)worldId animate:(bool)animate;

-(void) selectButton:(int)index;
-(void) deselectButton:(int)index;

-(void) addGestureRecognizer;
-(void) removeGestureRecognizer;

@end