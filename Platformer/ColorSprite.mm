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

#import "ColorSprite.h"


@implementation ColorSprite

@synthesize color = mColor;

// We're using this initializer because it is the designated initializer in CCSprite.
// This way, we can be sure it will get called regardless of what initializer a user invoked.
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect rotated:(BOOL)rotated
{
	self = [super initWithTexture:texture rect:rect rotated:rotated];
	if (self)
	{
		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:@"ColorBlend"];
		
		mColorUniformLocation = glGetUniformLocation(self.shaderProgram->_program, "u_color");
		mLuminanceUniformLocation = glGetUniformLocation(self.shaderProgram->_program, "u_luminance");
		
		self.color = ccc4f(0, 0, 0, 1);
	}
	
	return self;
}

-(void) dealloc
{
	CCLOG(@"DEALLOC: ColorSprite");
	
	[super dealloc];
}

-(void) draw
{
	[self.shaderProgram use];
	
	glUniform3f(mColorUniformLocation, mColor.r, mColor.g, mColor.b);
	glUniform1f(mLuminanceUniformLocation, mLuminance);
	
	[super draw];
}

-(void) setColor:(ccColor4F)color
{
	mColor = color;
	mLuminance = (mColor.r * 0.3) + (mColor.g * 0.59) + (mColor.b * 0.11);
}

@end
