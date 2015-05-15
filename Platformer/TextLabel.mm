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

#import "TextLabel.h"
#import "Game.h"


@implementation TextLabel

-(id) initWithLocalizedStringName:(const std::string&)localizedName width:(float)width alignment:(CCTextAlignment)alignment
{
	bool small = Game::Instance()->Data().LocalizedTextSmall(localizedName);
	
	return [self initWithLocalizedStringName:localizedName width:width alignment:alignment smallFont:small];
}

-(id) initWithLocalizedStringName:(const std::string&)localizedName width:(float)width alignment:(CCTextAlignment)alignment smallFont:(bool)small
{
	const std::string& strText = Game::Instance()->Data().LocalizedText(localizedName);
	NSString* text = [[NSString alloc] initWithUTF8String:strText.c_str()];
	
	id retVal = [self initWithStringValue:text width:width alignment:alignment smallFont:small];
	
	[text release];
	
	return retVal;
}

-(id) initWithStringValue:(NSString*)theString width:(float)width alignment:(CCTextAlignment)alignment
{
	return [self initWithStringValue:theString width:width alignment:alignment smallFont:false];
}

-(id) initWithStringValue:(NSString*)theString width:(float)width alignment:(CCTextAlignment)alignment smallFont:(bool)small
{
	NSString* font = small ? @"GroboldSmall.fnt" : @"Grobold.fnt";
	
	id retVal = [super initWithString:theString fntFile:font width:width alignment:alignment];
	
	self.scale = 1.25;
	
	return retVal;
}

-(void) refreshWithLocalizedStringName:(const std::string&)localizedName
{
	bool small = Game::Instance()->Data().LocalizedTextSmall(localizedName);
	
	[self refreshWithLocalizedStringName:localizedName smallFont:small];
}

-(void) refreshWithLocalizedStringName:(const std::string&)localizedName smallFont:(bool)small
{
	self.fntFile = small ? @"GroboldSmall.fnt" : @"Grobold.fnt";
	
	const std::string& strText = Game::Instance()->Data().LocalizedText(localizedName);
	NSString* text = [[NSString alloc] initWithUTF8String:strText.c_str()];
	
	self.string = text;
	
	[text release];
}

@end
