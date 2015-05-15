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

#import "ScrollableLayer.h"
#import "Game.h"


@implementation ScrollableLayer

-(id) init
{
	return nil;
}

-(id) initWithImage:(NSString*)name numTiles:(int)numTiles numVisibleTiles:(int)numVisibleTiles
{
	self = [super init];
	if (self)
	{
		mName = [name copy];
		mNumTiles = numTiles;
		mNumVisibleTiles = numVisibleTiles;
		
		mCurrentTileIndex = 0;
		
		// Find a frame by appending "0" to the name.
		CCSpriteFrame* frame = [self spriteFrameByNumber:0];
		
		NSAssert(frame, @"ScrollableLayer: Frame MUST NOT be nil!");
		
		mTileSize = frame.originalSize;
		
		// NOTE: This is because we resize scrollable layer texture into
		// half its original size and then scale it up 2x to save memory.
		mTileSize.width *= 2;
		mTileSize.height *= 2;
		
		mBatch = [[CCSpriteBatchNode alloc] initWithTexture:frame.texture capacity:numVisibleTiles];
		[self addChild:mBatch];
		
		mTiles = [[NSMutableArray alloc] initWithCapacity:numVisibleTiles];
		
		for (int index = 0; index < mNumVisibleTiles; ++index)
		{
			CCSprite* tile = [[CCSprite alloc] initWithTexture:frame.texture];
			tile.anchorPoint = ccp(0, 0);
			tile.scale = 2; // Read the note above.
			
			[mBatch addChild:tile];
			[mTiles addObject:tile];
			
			[tile release];
		}
		
		[self updateTiles];
	}
	return self;
}

-(void) dealloc
{
	[mName release];
	[mTiles release];
	[mBatch release];
	
	[super dealloc];
}

-(CCSpriteFrame*) spriteFrameByNumber:(int)number
{
	NSString* frameName = [[NSString alloc] initWithFormat:@"%@%d", mName, number];
	
	CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
	
	[frameName release];
	
	return frame;
}

-(void) updateTiles
{
	for (int index = 0; index < mNumVisibleTiles; ++index)
	{
		CCSprite* tile = [mTiles objectAtIndex:index];
		tile.position = ccp((mCurrentTileIndex + index) * mTileSize.width, PNGMakeFloat(-35));
		tile.displayFrame = [self spriteFrameByNumber:(mCurrentTileIndex + index) % mNumTiles];
	}
}

-(void) refresh
{
	int nextTileIndex = fabsf(self.position.x) / mTileSize.width;
	if (nextTileIndex != mCurrentTileIndex)
	{
		mCurrentTileIndex = nextTileIndex;
		[self updateTiles];
	}
}

@end
