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


inline
BOOL IsRunningOnPad()
{
	return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

inline
CGFloat GetDeviceFactor()
{
	return IsRunningOnPad() ? 2.0F : 1.0F;
}

inline
CGFloat PNGMakeFloat(CGFloat f)
{
	CGFloat factor = GetDeviceFactor();
	return f * factor;
}

inline
CGPoint PNGMakePoint(CGFloat x, CGFloat y)
{
	CGFloat factor = GetDeviceFactor();
	return CGPointMake(x * factor, y * factor);
}

inline
CGSize PNGMakeSize(CGFloat width, CGFloat height)
{
	CGFloat factor = GetDeviceFactor();
	return CGSizeMake(width * factor, height * factor);
}

inline
CGRect PNGMakeRect(CGFloat x, CGFloat y, CGFloat width, CGFloat height)
{
	CGFloat factor = GetDeviceFactor();
	return CGRectMake(x * factor, y * factor, width * factor, height * factor);
}

bool IsOSVersionSupported(NSString* reqSysVer);
bool IsOS8Supported();

bool SpriteContainsPoint(CCSprite* sprite, CGPoint pos);
void LoadSpriteFrames(const std::string& name, CCTexture2D* texture, CGPoint offset, CGSize spriteSize, int numSpritesTotal, int numSpritesPerRow);
void LoadSpriteFramesFromRepository(Repository<FrameAnimData>& frameAnimRepo);
void LoadTexturesFromRepository(StringVector& textureRepo);
void SetSpriteFrame(CCSprite* sprite, NSString* frameName);
NSString* DocumentsDirectoryPath();
NSString* PathForFile(NSString* filename);

template <typename T>
T Clamp(const T& value, const T& min, const T& max)
{
	return std::min(max, std::max(value, min));
}

template <typename T>
T Lerp(const T& prev, const T& current, float t)
{
	return t * current + (1.0F - t) * prev;
}

inline
void ApplyCorrectiveImpulse(b2Body* body, const b2Vec2& targetVelocity)
{
	b2Vec2 impulse = body->GetMass() * (targetVelocity - body->GetLinearVelocity());
	body->ApplyLinearImpulse(impulse, body->GetWorldCenter());
}

inline
void MakeFixtureNotCollidable(b2Fixture* fixture)
{
	b2Filter filter = fixture->GetFilterData();
	filter.maskBits = 0;
	fixture->SetFilterData(filter);
}

inline
void MakeBodyNotCollidable(b2Body* body)
{
	b2Fixture* fixture = body->GetFixtureList();
	
	while (fixture)
	{
		MakeFixtureNotCollidable(fixture);
		fixture = fixture->GetNext();
	}
}

inline
std::vector<std::string> SplitString(const std::string& source, const char* delimiter = " ", bool keepEmpty = false)
{
	std::vector<std::string> results;

	size_t prev = 0;
	size_t next = 0;

	while ((next = source.find_first_of(delimiter, prev)) != std::string::npos)
	{
		if (keepEmpty || (next - prev != 0))
		{
			results.push_back(source.substr(prev, next - prev));
		}
		prev = next + 1;
	}

	if (prev < source.size())
	{
		results.push_back(source.substr(prev));
	}

	return results;
}
