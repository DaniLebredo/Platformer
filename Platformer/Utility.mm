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

#import "Utility.h"
#import <string>
#import "Repository.h"
#import "FrameAnimData.h"


bool IsOSVersionSupported(NSString* reqSysVer)
{
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	return ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
}

bool IsOS8Supported()
{
	static bool supported = IsOSVersionSupported(@"8.0");
	return supported;
}

bool SpriteContainsPoint(CCSprite* sprite, CGPoint pos)
{
	NSCAssert(sprite != nil, @"Invalid sprite.");
	CGRect r = CGRectMake(sprite.position.x - sprite.contentSize.width * sprite.anchorPoint.x,
						  sprite.position.y - sprite.contentSize.height * sprite.anchorPoint.y,
						  sprite.contentSize.width, sprite.contentSize.height);
	return CGRectContainsPoint(r, pos);
}

void LoadSpriteFrames(const std::string& name, CCTexture2D* texture, CGPoint offset, CGSize spriteSize, int numSpritesTotal, int numSpritesPerRow)
{
	for (int i = 0; i < numSpritesTotal; ++i)
	{
		CGFloat x = offset.x + spriteSize.width * (i % numSpritesPerRow);
		CGFloat y = offset.y + spriteSize.height * (i / numSpritesPerRow);
		
		NSString* frameName = [[NSString  alloc] initWithFormat:@"%s%d", name.c_str(), i];
		CCSpriteFrame* frame = [[CCSpriteFrame alloc] initWithTexture:texture rect:PNGMakeRect(x, y, spriteSize.width, spriteSize.height)];
		
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:frame name:frameName];
		
		[frameName release];
		[frame release];
	}
}

void LoadSpriteFramesFromRepository(Repository<FrameAnimData>& frameAnimRepo)
{
	CCTextureCache* tc = [CCTextureCache sharedTextureCache];
	
	const StringVector& frameAnimNames = frameAnimRepo.ItemNames();
	
	for (int index = 0; index < frameAnimNames.size(); ++index)
	{
		FrameAnimData& faData = frameAnimRepo.Item(frameAnimNames[index]);
		
		NSString* textureName = [[NSString alloc] initWithFormat:@"%s", faData.TextureName().c_str()];
		LoadSpriteFrames(faData.Name(), [tc addImage:textureName], faData.Offset(), faData.FrameSize(), faData.NumFramesTotal(), faData.NumFramesPerRow());
		[textureName release];
	}
}

void LoadTexturesFromRepository(StringVector& textureRepo)
{
	CCTextureCache* tc = [CCTextureCache sharedTextureCache];
	
	for (int index = 0; index < textureRepo.size(); ++index)
	{
		NSString* textureName = [[NSString alloc] initWithFormat:@"%s", textureRepo[index].c_str()];
		[tc addImage:textureName];
		[textureName release];
	}
}

void SetSpriteFrame(CCSprite* sprite, NSString* frameName)
{
	sprite.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:frameName];
}

NSString* DocumentsDirectoryPath()
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* docsDirPath = [paths objectAtIndex:0];
	return docsDirPath;
}

NSString* PathForFile(NSString* filename)
{
	NSString* docsDirPath = DocumentsDirectoryPath();
	return [docsDirPath stringByAppendingPathComponent:filename];
}
