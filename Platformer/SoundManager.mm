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

#import "SoundManager.h"
#import "ObjectAL.h"
#import "Utility.h"
#import "Game.h"

#ifdef ANDROID
#import "SoundPool.h"
#import <BridgeKit/AndroidActivity.h>
#import <BridgeKit/AndroidAssetsManager.h>
#endif


SoundManager::SoundManager()
{
#ifdef ANDROID
	mSoundPool = [[SoundPool alloc] initWithIntValue:16 intValue:0x3 intValue:0];
#endif
}

SoundManager::~SoundManager()
{
#ifdef ANDROID
	[mSoundPool release];
#endif
}

void SoundManager::PreloadEffect(const std::string& effect)
{
	NSString* effectName = [[NSString alloc] initWithFormat:@"%s", effect.c_str()];
	
#ifdef ANDROID
	AndroidActivity* activity = [AndroidActivity currentActivity];
	AndroidAssetFileDescriptor* afd = [activity.assetManager openFd:effectName];
	
	mSoundIds[effect] = [mSoundPool loadFromAssetFileDescriptor:afd priority:1];
#else
	[[OALSimpleAudio sharedInstance] preloadEffect:effectName];
#endif
	
	[effectName release];
}

void SoundManager::ScheduleEffect(const std::string& effect, float gain)
{
	if (!Game::Instance()->SoundOn()) return;
	
	gain = Clamp(gain, 0.0F, 1.0F);
	
	StrFloatMap::iterator it = mScheduledEffects.find(effect);
	
	if (it != mScheduledEffects.end())
	{
		if (gain > it->second) it->second = gain;
	}
	else
	{
		mScheduledEffects[effect] = gain;
	}
}

void SoundManager::ScheduleDampenedEffect(const std::string& effect, const b2Vec2& deltaPos)
{
	if (!Game::Instance()->SoundOn()) return;
	
	float distanceSq = deltaPos.LengthSquared();
	float minDistSq = 5 * 5;
	float maxDistSq = 20 * 20;
	
	float gain = 1 + (distanceSq - minDistSq) / (minDistSq - maxDistSq);
	
	gain = Clamp(gain, 0.0F, 1.0F);
	gain *= gain;
	gain *= gain;
	
	ScheduleEffect(effect, gain);
}

void SoundManager::PlayScheduledEffects()
{
	for (StrFloatMap::iterator it = mScheduledEffects.begin(); it != mScheduledEffects.end(); ++it)
	{
		std::string effect = it->first;
		float gain = it->second;
		
#ifdef ANDROID
		[mSoundPool playSound:mSoundIds[effect] leftVolume:gain rightVolume:gain priority:0 loop:0 rate:1.0F];
#else
		NSString* effectName = [[NSString alloc] initWithFormat:@"%s", effect.c_str()];
		[[OALSimpleAudio sharedInstance] playEffect:effectName volume:gain pitch:1.0F pan:0.0F loop:false];
		[effectName release];
#endif
	}
	
	mScheduledEffects.clear();
}

void SoundManager::PreloadBackgroundMusic(const std::string& bkgMusic)
{
	NSString* bkgMusicName = [[NSString alloc] initWithFormat:@"%s", bkgMusic.c_str()];
	
	[[OALSimpleAudio sharedInstance] preloadBg:bkgMusicName];
	
	[bkgMusicName release];
}

void SoundManager::PlayBackgroundMusic(const std::string& bkgMusic, bool loop)
{
	NSString* bkgMusicName = [[NSString alloc] initWithFormat:@"%s", bkgMusic.c_str()];
	
	[[OALSimpleAudio sharedInstance] playBg:bkgMusicName loop:true];
	
	[bkgMusicName release];
}

void SoundManager::StopBackgroundMusic()
{
	[[OALSimpleAudio sharedInstance] stopBg];
}

void SoundManager::FadeOutBackgroundMusic(float duration, bool shouldStop)
{
	[[OALSimpleAudio sharedInstance].backgroundTrack fadeOut:duration shouldStop:shouldStop];
}

bool SoundManager::IsBackgroundMusicPlaying()
{
	return [[OALSimpleAudio sharedInstance] bgPlaying];
}

void SoundManager::SetBackgroundMusicVolume(BackgroundMusicVolume volume)
{
	switch (volume)
	{
		case BkgMusic_Loud:
			[[OALSimpleAudio sharedInstance] setBgVolume:0.5];
			break;
			
		case BkgMusic_Quiet:
			[[OALSimpleAudio sharedInstance] setBgVolume:0.15];
			break;
			
		default:
			break;
	}
}
