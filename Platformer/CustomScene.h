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
#import "FocusDirection.h"

@class CustomLayer;

class SceneController;

// CustomScene is a custom way of representing a cocos2d scene in ObjC. It should be
// used as a base class instead of CCScene. It notifies Game when a scene has exited
// so it can be properly cleaned up.
//
// NOTE: This class is used only because cocos2d for iPhone was written in ObjC. Derived
// classes should only contain the code that has to be in ObjC, such as touch detection,
// scene composition etc. All of the other stuff should be in SceneController, which is
// written is C++.

@interface CustomScene : CCScene {
	SceneController* mSceneController;	// weak ref
	
	CustomLayer* mFocusedLayer;
}

-(id) initWithSceneController:(SceneController*)scene;

-(void) moveFocus:(FocusDirection)focusDirection;
-(void) applyMoveFocus;
-(void) clickFocusedButton;

@end
