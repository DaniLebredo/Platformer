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

#import "StdInclude.h"
#import "ButtonType.h"

class LevelController;


@interface HUDLayer : CCLayer<UIGestureRecognizerDelegate>
{
	LevelController* mSceneController;		// weak ref
	
	CCSpriteBatchNode* mBatch;
	
	NSMutableDictionary* mControlButtons;
	NSMutableDictionary* mControlTouches;
	std::map<std::string, ButtonType> mControlTypes;
	
	CCSprite* mLeftButton;
	CCSprite* mRightButton;
	
	CCSprite* mPauseButton;
	UITouch* mPauseTouch;
	
	CCSprite* mScoreIcon;
	CCLabelBMFont* mScoreLabel;
	int mScore;
	
	NSMutableArray* mHearts;
	int mLives;
	
	CCSprite* mTimeIcon;
	CCLabelBMFont* mTimeLabel;
	int mMinutes;
	int mSeconds;
	
	NSMutableArray* mKeys;
	int mNumKeys;
	
	float mIconsScale;
}

-(id) initWithLevelController:(LevelController*)controller;

-(void) setScoreLabel:(int)score outOf:(int)maxScore;
-(void) setLivesLabel:(int)lives;
-(void) setKeysLabel:(int)keys;
-(void) setTimeLabel:(ccTime)time;

-(bool) button:(CCSprite*)button containsPoint:(CGPoint)pos;

-(void) refreshControls;

-(void) preDisplay;
-(void) preHide;

@end
