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

#ifndef SOUNDMANAGER_H
#define SOUNDMANAGER_H

#import "StdInclude.h"
#import "Singleton.h"

#ifdef ANDROID
@class SoundPool;
#endif


enum BackgroundMusicVolume
{
	BkgMusic_Loud = 0,
	BkgMusic_Quiet
};

class SoundManager : public Singleton<SoundManager>
{
	friend class Singleton<SoundManager>;
	
public:
	void PreloadEffect(const std::string& effect);
	void ScheduleEffect(const std::string& effect, float gain = 1.0F);
	void ScheduleDampenedEffect(const std::string& effect, const b2Vec2& deltaPos);
	void PlayScheduledEffects();
	
	void PreloadBackgroundMusic(const std::string& bkgMusic);
	void PlayBackgroundMusic(const std::string& bkgMusic, bool loop);
	void StopBackgroundMusic();
	void FadeOutBackgroundMusic(float duration, bool shouldStop);
	bool IsBackgroundMusicPlaying();
	void SetBackgroundMusicVolume(BackgroundMusicVolume volume);
	
private:
	SoundManager();
	SoundManager(const SoundManager&);
	virtual ~SoundManager();
	SoundManager& operator=(const SoundManager&);
	
	StrFloatMap mScheduledEffects;
	
#ifdef ANDROID
	SoundPool* mSoundPool;
	std::map<std::string, int> mSoundIds;
#endif
};

#endif
