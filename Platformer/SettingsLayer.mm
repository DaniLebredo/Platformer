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

#import "SettingsLayer.h"
#import "Game.h"
#import "SceneController.h"
#import "TextButton.h"
#import "TextLabel.h"


@implementation SettingsLayer

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
		
		// --------------
		
		CGFloat labelOffset = PNGMakeFloat(25);
		
		mLabel = [[TextLabel alloc] initWithStringValue:@""
												  width:PNGMakeFloat(400)
											  alignment:kCCTextAlignmentCenter];
		
		mLabel.position = ccp(0.5 * winSize.width, winSize.height - labelOffset);
		mLabel.anchorPoint = ccp(0.5, 1);
		[mContainer addChild:mLabel];
		
		// --------------
		
		CGFloat offset = PNGMakeFloat(5);
		
		TextButton* goBackButton = [[TextButton alloc] initWithName:@"Back"];
		goBackButton.position = ccp(offset + 0.5 * goBackButton.width, offset + 0.5 * goBackButton.height);
		goBackButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Back));
		mPreferredFocusButton = goBackButton;
		[mContainer addChild:goBackButton z:10];
		[mButtons setObject:goBackButton forKey:@"Back"];
		[goBackButton release];
		
		TextButton* musicButton = [[TextButton alloc] initWithName:@"Music"];
		musicButton.position = ccp(0.5 * winSize.width - PNGMakeFloat(30), 0.5 * winSize.height + PNGMakeFloat(55));
		musicButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Music));
		[mContainer addChild:musicButton z:10];
		[mButtons setObject:musicButton forKey:@"Music"];
		[musicButton release];
		
		TextButton* musicOffButton = [[TextButton alloc] initWithName:@"MusicOff"];
		musicOffButton.position = musicButton.position;
		musicOffButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Music));
		[mContainer addChild:musicOffButton z:10];
		[mButtons setObject:musicOffButton forKey:@"MusicOff"];
		[musicOffButton release];
		
		TextButton* soundButton = [[TextButton alloc] initWithName:@"Sound"];
		soundButton.position = ccp(0.5 * winSize.width + PNGMakeFloat(30), 0.5 * winSize.height + PNGMakeFloat(55));
		soundButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Sound));
		[mContainer addChild:soundButton z:10];
		[mButtons setObject:soundButton forKey:@"Sound"];
		[soundButton release];
		
		TextButton* soundOffButton = [[TextButton alloc] initWithName:@"SoundOff"];
		soundOffButton.position = soundButton.position;
		soundOffButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Sound));
		[mContainer addChild:soundOffButton z:10];
		[mButtons setObject:soundOffButton forKey:@"SoundOff"];
		[soundOffButton release];
		
		TextButton* controlsButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		controlsButton.position = ccp(0.5 * winSize.width, musicButton.position.y - 2 * offset - 0.5 * musicButton.height - 0.5 * controlsButton.height);
		controlsButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Controls));
		[mContainer addChild:controlsButton z:10];
		[mButtons setObject:controlsButton forKey:@"Controls"];
		[controlsButton release];
		
		TextButton* languageButton = [[TextButton alloc] initWithName:@"Empty" text:@""];
		languageButton.position = ccp(controlsButton.position.x, controlsButton.position.y - 2 * offset - controlsButton.height);
		languageButton.userData = reinterpret_cast<void*>(static_cast<int>(Btn_Language));
		[mContainer addChild:languageButton z:10];
		[mButtons setObject:languageButton forKey:@"Language"];
		[languageButton release];
		
		[self preDisplay];
	}
	return self;
}

-(void) dealloc
{
	[mLabel release];
	
	[super dealloc];
}

-(void) preDisplay
{
	[self updateMusicButton];
	[self updateText];
}

-(void) updateMusicButton
{
	TextButton* musicButton = [mButtons objectForKey:@"Music"];
	musicButton.visible = Game::Instance()->MusicOn() ? YES : NO;
	
	TextButton* musicOffButton = [mButtons objectForKey:@"MusicOff"];
	musicOffButton.visible = !musicButton.visible;
	
	if (musicButton.visible && musicOffButton.focused)
	{
		[self removeFocus];
		[self setFocusToButton:musicButton];
	}
	else if (musicOffButton.visible && musicButton.focused)
	{
		[self removeFocus];
		[self setFocusToButton:musicOffButton];
	}
	
	// ---
	
	TextButton* soundButton = [mButtons objectForKey:@"Sound"];
	soundButton.visible = Game::Instance()->SoundOn() ? YES : NO;
	
	TextButton* soundOffButton = [mButtons objectForKey:@"SoundOff"];
	soundOffButton.visible = !soundButton.visible;
	
	if (soundButton.visible && soundOffButton.focused)
	{
		[self removeFocus];
		[self setFocusToButton:soundButton];
	}
	else if (soundOffButton.visible && soundButton.focused)
	{
		[self removeFocus];
		[self setFocusToButton:soundOffButton];
	}
}

-(void) updateText
{
	[mLabel refreshWithLocalizedStringName:"Settings" smallFont:false];
	
	TextButton* controlsButton = [mButtons objectForKey:@"Controls"];
	[controlsButton refreshWithlocalizedTextName:"Controls"];
	
	TextButton* languageButton = [mButtons objectForKey:@"Language"];
	[languageButton refreshWithlocalizedTextName:"Language"];
}

-(void) clickFocusedButton
{
	if (!mCanTouch) return;
	
	if (mFocusedButton)
	{
		TextButton* nextFocusedButton = nil;
		
		if ([mButtons objectForKey:@"Music"] == mFocusedButton)
		{
			nextFocusedButton = [mButtons objectForKey:@"MusicOff"];
		}
		else if ([mButtons objectForKey:@"MusicOff"] == mFocusedButton)
		{
			nextFocusedButton = [mButtons objectForKey:@"Music"];
		}
		else if ([mButtons objectForKey:@"Sound"] == mFocusedButton)
		{
			nextFocusedButton = [mButtons objectForKey:@"SoundOff"];
		}
		else if ([mButtons objectForKey:@"SoundOff"] == mFocusedButton)
		{
			nextFocusedButton = [mButtons objectForKey:@"Sound"];
		}
		
		[super clickFocusedButton];
		
		if (nextFocusedButton != nil)
		{
			[self removeFocus];
			[self setFocusToButton:nextFocusedButton];
		}
	}
}

@end
