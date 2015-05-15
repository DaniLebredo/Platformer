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

#import "TextButton.h"
#import "Utility.h"
#import "Game.h"


@implementation TextButton

@synthesize label = mLabel;
@synthesize grayscale = mGrayscale;
@synthesize selected = mSelected;
@synthesize focused = mFocused;
@synthesize color = mColor;
@synthesize opacity = mOpacity;
@synthesize userInt = mUserInt;
@synthesize width;
@synthesize height;

-(id) init
{
	return nil;
}

-(id) initWithName:(NSString*)name
{
	return [self initWithName:name text:@""];
}

-(id) initWithName:(NSString*)name text:(NSString*)text
{
	return [self initWithName:name text:text smallFont:false];
}

-(id) initWithName:(NSString*)name text:(NSString*)text smallFont:(bool)small
{
	return [self initWithName:name text:text smallFont:small textOffset:PNGMakePoint(0, 0)];
}

-(id) initWithName:(NSString*)name text:(NSString*)text smallFont:(bool)small textOffset:(CGPoint)textOffset
{
	self = [super init];
	if (self)
	{
		mName = [name copy];
		mNameNormal = [[NSString alloc] initWithFormat:@"%@Normal", name];
		mNameSelected = [[NSString alloc] initWithFormat:@"%@Selected", name];
		
		mGrayscale = false;
		mSelected = false;
		mOpacity = 255;
		mUserInt = 0;
		
		// ---
		
		mSprite = [[CCSprite alloc] initWithSpriteFrameName:Game::Instance()->Data().ButtonFrameName(mNameNormal)];
		[self addChild:mSprite z:10];
		
		mPulsateAction = [[CCRepeatForever alloc] initWithAction:
						  [CCSequence actions:
						   [CCEaseExponentialOut actionWithAction:[CCTintTo actionWithDuration:0.25 red:64 green:64 blue:64]],
						   [CCEaseExponentialOut actionWithAction:[CCTintTo actionWithDuration:0.25 red:255 green:255 blue:255]],
						   nil]];
		
		// ---
		
		mLabel = [[TextLabel alloc] initWithStringValue:text
												  width:mSprite.contentSize.width
											  alignment:kCCTextAlignmentCenter
											  smallFont:small];
		mLabel.position = ccpAdd(textOffset, PNGMakePoint(0, 0));
		mLabel.scale = small ? 1.25 : 1;
		[self addChild:mLabel z:15];
	}
	return self;
}

-(id) initWithName:(NSString*)name localizedTextName:(const std::string&)localizedName
{
	bool small = Game::Instance()->Data().LocalizedTextSmall(localizedName);
	const std::string& strText = Game::Instance()->Data().LocalizedText(localizedName);
	
	NSString* text = [[NSString alloc] initWithUTF8String:strText.c_str()];
	
	id retVal = [self initWithName:name text:text smallFont:small];
	
	[text release];
	
	return retVal;
}

-(void) refreshWithlocalizedTextName:(const std::string&)localizedName
{
	bool small = Game::Instance()->Data().LocalizedTextSmall(localizedName);
	
	[mLabel refreshWithLocalizedStringName:localizedName smallFont:small];
	
	mLabel.scale = small ? 1.25 : 1;
}

-(void) dealloc
{
	CCLOG(@"DEALLOC: TextButton");
	
	[mName release];
	[mNameNormal release];
	[mNameSelected release];
	
	[mSprite release];
	[mLabel release];
	
	[mPulsateAction release];
	
	[super dealloc];
}

-(void) setGrayscale:(bool)gray
{
	mGrayscale = gray;
	
	if (mGrayscale)
		mSprite.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:@"Grayscale"];
	else mSprite.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTextureColor];
}

-(void) setSelected:(bool)sel
{
	mSelected = sel;
	
	if (mSelected)
		SetSpriteFrame(mSprite, Game::Instance()->Data().ButtonFrameName(mNameSelected));
	else SetSpriteFrame(mSprite, Game::Instance()->Data().ButtonFrameName(mNameNormal));
}

-(void) setFocused:(bool)focused
{
	if (mFocused != focused)
	{
		mFocused = focused;
		
		if (mFocused)
		{
			[mSprite runAction:mPulsateAction];
		}
		else
		{
			[mSprite stopAllActions];
			mSprite.color = ccWHITE;
		}
	}
}

-(void) setOpacity:(GLubyte)op
{
	mOpacity = op;
	
	mSprite.opacity = mOpacity;
	mLabel.opacity = mOpacity;
}

-(void) setColor:(ccColor3B)col
{
	mColor = col;
	
	mSprite.color = mColor;
	mLabel.color = mColor;
}

-(bool) containsPoint:(CGPoint)point
{
	return SpriteContainsPoint(mSprite, [self convertToNodeSpace:point]);
}

-(CGFloat) width
{
	return mSprite.contentSize.width;
}

-(CGFloat) height
{
	return mSprite.contentSize.height;
}

@end
