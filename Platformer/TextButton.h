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
#import "TextLabel.h"


@interface TextButton : CCNode
{
	CCSprite* mSprite;
	TextLabel* mLabel;
	
	CCAction* mPulsateAction;
	
	NSString* mName;
	NSString* mNameNormal;
	NSString* mNameSelected;
	
	bool mGrayscale;
	bool mSelected;
	bool mFocused;
	
	ccColor3B mColor;
	GLubyte mOpacity;
	
	int mUserInt;
}

@property (nonatomic, readonly) TextLabel* label;
@property (nonatomic, readwrite, assign) bool grayscale;
@property (nonatomic, readwrite, assign) bool selected;
@property (nonatomic, readwrite, assign) bool focused;
@property (nonatomic, readwrite, assign) ccColor3B color;
@property (nonatomic, readwrite, assign) GLubyte opacity;
@property (nonatomic, readwrite, assign) int userInt;
@property (nonatomic, readonly) CGFloat width;
@property (nonatomic, readonly) CGFloat height;

-(id) initWithName:(NSString*)name;
-(id) initWithName:(NSString*)name text:(NSString*)text;
-(id) initWithName:(NSString*)name text:(NSString*)text smallFont:(bool)small;
-(id) initWithName:(NSString*)name text:(NSString*)text smallFont:(bool)small textOffset:(CGPoint)textOffset;
-(id) initWithName:(NSString*)name localizedTextName:(const std::string&)localizedName;

-(void) refreshWithlocalizedTextName:(const std::string&)localizedName;

-(bool) containsPoint:(CGPoint)point;

@end
