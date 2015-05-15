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

#import "Fireworks.h"
#import "Utility.h"


@implementation Fireworks

-(id) initWithTotalParticles:(NSUInteger)p
{
	self = [super initWithTotalParticles:p];
	if (self)
	{
		_angleVar = 30;
		
		_startSize *= PNGMakeFloat(1);
		_startSizeVar *= PNGMakeFloat(1);
		
		_endSize *= PNGMakeFloat(1);
		_endSizeVar *= PNGMakeFloat(1);
		
		self.speed *= PNGMakeFloat(1.3);
		self.speedVar *= PNGMakeFloat(1);
		
		self.gravity = ccpMult(self.gravity, PNGMakeFloat(1));
		
		self.texture = [[CCTextureCache sharedTextureCache] addImage:@"stars-grayscale.png"];
		self.blendAdditive = YES;
	}
	return self;
}

-(void) dealloc
{
	CCLOG(@"DEALLOC: Fireworks");
	
	[super dealloc];
}

@end
