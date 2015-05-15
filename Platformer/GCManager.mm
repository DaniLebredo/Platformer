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

#import "GCManager.h"
#import "AppDelegate.h"
#import "Utility.h"


GCManager::GCManager() :
	mDebugMode(true),
	mPlayerAuthenticated(false)
{
	mAchievements = [[NSMutableDictionary alloc] initWithCapacity:15];
}

GCManager::~GCManager()
{
	[mAchievements release];
}

void GCManager::AuthenticateLocalPlayer()
{
#ifndef ANDROID
	CCLOG(@"GC: Authenticating Local Player...");
	
	GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController* viewController, NSError* error) {
		if (viewController != nil)
		{
			CCLOG(@"GC: viewController != nil");
			//showAuthenticationDialogWhenReasonable: is an example method name. Create your own method that displays an authentication view when appropriate for your app.
			//[self showAuthenticationDialogWhenReasonable: viewController];
			
			AppController* delegate = [UIApplication sharedApplication].delegate;
			[delegate.navController presentViewController:viewController animated:YES completion:nil];
		}
		else if (localPlayer.isAuthenticated)
		{
			CCLOG(@"GC: localPlayer.isAuthenticated == YES");
			//authenticatedPlayer: is an example method name. Create your own method that is called after the loacal player is authenticated.
			//[self authenticatedPlayer: localPlayer];
			mPlayerAuthenticated = true;
			loadAchievements();
		}
		else
		{
			CCLOG(@"GC: localPlayer.isAuthenticated == NO");
			//[self disableGameCenter];
			mPlayerAuthenticated = false;
		}
	};
#endif
}

void GCManager::ReportScore(const std::string& identifier, int64_t scoreValue)
{
#ifndef ANDROID
	if (!mPlayerAuthenticated) return;
	
	NSString* scoreId = [[NSString alloc] initWithFormat:@"%s", identifier.c_str()];
	
	if (IsOSVersionSupported(@"7.0"))
	{
		GKScore* scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:scoreId];
		scoreReporter.value = scoreValue;
		scoreReporter.context = 0;
		
		NSArray* scores = @[scoreReporter];
		[GKScore reportScores:scores withCompletionHandler:^(NSError* error)
			{
				if (error == nil)
				{
					[scoreReporter release];
				}
			}];
	}
	else	// iOS 6
	{
		GKScore* scoreReporter = [[GKScore alloc] initWithCategory:scoreId];
		scoreReporter.value = scoreValue;
		scoreReporter.context = 0;
		
		[scoreReporter reportScoreWithCompletionHandler:^(NSError* error)
			{
				if (error == nil)
				{
					[scoreReporter release];
				}
			}];
	}
	
	[scoreId release];
#endif
}

void GCManager::ReportAchievement(const std::string& identifier, float percentComplete)
{
#ifndef ANDROID
	if (!mPlayerAuthenticated) return;
	
	GKAchievement* achievement = getAchievementForIdentifier(identifier);
	
	if (percentComplete > achievement.percentComplete)
	{
		achievement.percentComplete = percentComplete;
		[achievement reportAchievementWithCompletionHandler:^(NSError* error)
			{
				if (error != nil)
				{
					// Log the error.
					CCLOG(@"Error in reporting achievements: %@", error);
				}
			}];
	}
#endif
}

bool GCManager::IsAchievementCompleted(const std::string& identifier)
{
#ifndef ANDROID
	if (!mPlayerAuthenticated) return false;
	
	GKAchievement* achievement = getAchievementForIdentifier(identifier);
	
	return achievement.completed == YES;
#else
	return false;
#endif
}

#ifndef ANDROID
GKAchievement* GCManager::getAchievementForIdentifier(const std::string& identifier)
{
	NSString* achievementId = [[NSString alloc] initWithFormat:@"%s", identifier.c_str()];
	
    GKAchievement* achievement = [mAchievements objectForKey:achievementId];
	
    if (achievement == nil)
    {
        achievement = [[GKAchievement alloc] initWithIdentifier:achievementId];
		achievement.showsCompletionBanner = YES;
        [mAchievements setObject:achievement forKey:achievement.identifier];
		[achievement release];
    }
	
	[achievementId release];
	
    return achievement;
}

void GCManager::loadAchievements()
{
	if (!mPlayerAuthenticated) return;
	
	[GKAchievement loadAchievementsWithCompletionHandler:^(NSArray* achievements, NSError* error)
		{
			if (error == nil)
			{
				CCLOG(@"Achievements:");
				for (GKAchievement* achievement in achievements)
				{
					CCLOG(@"%@", achievement.identifier);
					[mAchievements setObject:achievement forKey:achievement.identifier];
				}
			}
		}];
}
#endif
