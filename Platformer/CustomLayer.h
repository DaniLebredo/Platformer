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
#import "TextButton.h"
#import "FocusDirection.h"

class SceneController;


@interface CustomLayer : CCLayerColor
{
	SceneController* mSceneController;		// weak ref
	
	CCNode* mContainer;
	
	NSMutableDictionary* mButtons;
	
	TextButton* mFocusedButton;
	TextButton* mPreferredFocusButton;
	
	std::map<FocusDirection, bool> mFocusDirection;
	
	bool mCanTouch;
	
	CGFloat mAnimDuration;
}

@property (nonatomic, readwrite, assign) bool canTouch;

-(id) initWithSceneController:(SceneController*)controller;

-(id) initWithSceneController:(SceneController*)controller color:(ccColor4B)color;

-(void) animate;

-(bool) isFocusDirectionSpecified;
-(void) resetFocusDirectionValues;
-(bool) canButtonBeFocused:(TextButton*)button;
-(void) setFocusToButton:(TextButton*)button;
-(void) setFocusToFirstPossibleButton;
-(void) setFocusToClosestButtonInFocusDirection;
-(void) removeFocus;
-(void) moveFocus:(FocusDirection)focusDirection;
-(void) applyMoveFocus;
-(void) clickFocusedButton;

-(TextButton*) processButtonForTouchBegan:(UITouch*)touch;

-(TextButton*) processButtonForTouchMoved:(UITouch*)touch;

-(TextButton*) processButtonForTouchEnded:(UITouch*)touch;

@end
