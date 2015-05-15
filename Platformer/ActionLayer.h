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
#import "GLES-Render.h"
#import "HKTMXTiledMap.h"

class LevelController;
class GameObject;


@interface ActionLayer : CCLayer
{
	LevelController* mSceneController;		// weak ref
	
	HKTMXTiledMap* mTileMap;
	CCSpriteBatchNode* mCoinsBatch;
	CCSpriteBatchNode* mBulletsBatch;
	
	b2World* mPhyWorld;				// weak ref
	GLESDebugDraw* mDebugDraw;		// strong ref
	float mPtmRatio;
	
	int mZOrderFront;
	int mZOrderPreFront;
}

@property (nonatomic, readonly) HKTMXTiledMap* tileMap;

-(id) initWithLevelController:(LevelController*)controller;

-(void) addGameObject:(GameObject*)gObj;

@end
