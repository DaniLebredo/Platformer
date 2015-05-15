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

#import "StoreLayer.h"
#import "Game.h"
#import "SceneController.h"
#import "TextButton.h"


@implementation StoreLayer

-(id) initWithSceneController:(SceneController*)controller
{
	return [self initWithSceneController:controller color:ccc4(16, 16, 16, 230)];
}

-(id) initWithSceneController:(SceneController*)controller color:(ccColor4B)color
{
	self = [super initWithSceneController:controller color:color];
	if (self)
	{
		self.visible = NO;
		self.touchEnabled = NO;
		
		// --------------
		
		CGSize winSize = [CCDirector sharedDirector].winSize;
		
		CGFloat labelOffset = PNGMakeFloat(25);
		
		mLabel = [[CCLabelBMFont alloc] initWithString:@"Lance's Marketplace"
											   fntFile:@"Grobold.fnt"
												 width:PNGMakeFloat(320)
											 alignment:kCCTextAlignmentCenter];
		
		mLabel.position = ccp(0.5 * winSize.width, winSize.height - labelOffset);
		mLabel.anchorPoint = ccp(0.5, 1);
		[self addChild:mLabel];
		
		mMessageLabel = [[CCLabelBMFont alloc] initWithString:@""
													  fntFile:@"GroboldSmall.fnt"
														width:PNGMakeFloat(320)
													alignment:kCCTextAlignmentCenter];
		
		mMessageLabel.position = ccp(0.5 * winSize.width, 0.5 * winSize.height + PNGMakeFloat(35));
		mMessageLabel.anchorPoint = ccp(0.5, 1);
		[self addChild:mMessageLabel];
		
		// --------------
		
		CGFloat offset = PNGMakeFloat(5);
		
		TextButton* buyFullVersionButton = [[TextButton alloc] initWithName:@"Empty" text:@"Buy Full\nVersion ($0.99)" smallFont:true];
		buyFullVersionButton.position = ccp(0.5 * winSize.width, 0.5 * winSize.height - PNGMakeFloat(50));
		buyFullVersionButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_BuyFullVersion));
		[self addChild:buyFullVersionButton z:10];
		[mButtons setObject:buyFullVersionButton forKey:@"BuyFullVersion"];
		[buyFullVersionButton release];
		
		TextButton* restorePurchasesButton = [[TextButton alloc] initWithName:@"Empty" text:@"Restore\nPurchases" smallFont:true];
		restorePurchasesButton.position = ccp(winSize.width - offset - 0.5 * restorePurchasesButton.width, offset + 0.5 * restorePurchasesButton.height);
		restorePurchasesButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_RestorePurchases));
		[self addChild:restorePurchasesButton z:10];
		[mButtons setObject:restorePurchasesButton forKey:@"RestorePurchases"];
		[restorePurchasesButton release];
		
		TextButton* goBackButton = [[TextButton alloc] initWithName:@"Back"];
		goBackButton.position = ccp(offset + 0.5 * goBackButton.width, offset + 0.5 * goBackButton.height);
		goBackButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Back));
		[self addChild:goBackButton z:10];
		[mButtons setObject:goBackButton forKey:@"Back"];
		[goBackButton release];
	}
	return self;
}

-(void) dealloc
{
	[mLabel release];
	[mMessageLabel release];
	
	[super dealloc];
}

-(void) setAvailability:(bool)available
{
	if (available)
	{
		//mMessageLabel.visible = NO;
		mMessageLabel.string = @"Full version gives you access to all worlds, available now and in the future.";
		
		TextButton* buyFullVersion = [mButtons objectForKey:@"BuyFullVersion"];
		buyFullVersion.visible = YES;
		
		TextButton* restorePurchasesButton = [mButtons objectForKey:@"RestorePurchases"];
		restorePurchasesButton.visible = YES;
	}
	else
	{
		mMessageLabel.string = @"App Store is not available at the moment.\n\nPlease try again later.";
	}
}

-(void) preDisplay
{
	TextButton* buyFullVersion = [mButtons objectForKey:@"BuyFullVersion"];
	buyFullVersion.visible = NO;
	
	TextButton* restorePurchasesButton = [mButtons objectForKey:@"RestorePurchases"];
	restorePurchasesButton.visible = NO;
	
	mMessageLabel.visible = YES;
	mMessageLabel.string = @"Fetching products, please wait...";
}

@end
