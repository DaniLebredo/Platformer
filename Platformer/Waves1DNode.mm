#import "Waves1DNode.h"
#import "Utility.h"

@implementation Waves1DNode

@synthesize color = _color;

-(id)initWithBounds:(CGRect)bounds count:(int)count damping:(float)damping diffusion:(float)diffusion
{
	self = [super init];
	if (self)
	{
		_bounds = bounds;
		_count = count;
		_damping = damping;
		_diffusion = diffusion;
		
		_color = ccc4f(1.0, 1.0, 1.0, 1.0);
		
		_h1 = (float*)calloc(_count, sizeof(float));
		_h2 = (float*)calloc(_count, sizeof(float));
		
		mWaterVertices.reserve(2 * _count);
		mFoamVertices.reserve(2 * _count);
		
		GLfloat dx = [self dx];
		GLfloat top = _bounds.size.height;
		
		for (int i = 0; i < _count; ++i)
		{
			GLfloat x = i * dx;
			
			mWaterVertices[2 * i + 0].x = x;
			mWaterVertices[2 * i + 0].y = 0;
			mWaterVertices[2 * i + 0].color = ccc4f(0.3, 0.3, 0.9, 0.5);
			
			mWaterVertices[2 * i + 1].x = x;
			mWaterVertices[2 * i + 1].y = top + _h2[i];
			mWaterVertices[2 * i + 1].color = ccc4f(0.3, 0.3, 0.9, 0.5);
			
			mFoamVertices[2 * i + 0].x = x;
			mFoamVertices[2 * i + 0].y = 0;
			mFoamVertices[2 * i + 0].texCoord.u = 0.5;
			mFoamVertices[2 * i + 0].texCoord.v = 0;
			
			mFoamVertices[2 * i + 1].x = x;
			mFoamVertices[2 * i + 1].y = 0;
			mFoamVertices[2 * i + 1].texCoord.u = 0.5;
			mFoamVertices[2 * i + 1].texCoord.v = 1;
		}
		
		mWaterShader = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];
		
		mFoamShader = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTexture];
		
		mFoamTexture = [[CCTextureCache sharedTextureCache] addImage:@"stars-grayscale.png"];
		//[mFoamTexture setAliasTexParameters];
		
		[self scheduleUpdate];
	}
	
	return self;
}

- (void) dealloc
{
	free(_h1);
	free(_h2);
	
	[super dealloc];
}

-(void) vertlet
{
	for (int i = 0; i < _count; ++i)
		_h1[i] = 2.0 * _h2[i] - _h1[i];
	
	float* temp = _h2;
	_h2 = _h1;
	_h1 = temp;
}

static inline
float diffuse(float diff, float damp, float prev, float curr, float next)
{
	return damp * (curr * diff + 0.5 * (prev + next) * (1.0 - diff));
}

-(void) diffuse
{
	float prev = _h2[0];
	float curr = _h2[0];
	float next = _h2[1];
	
	_h2[0] = diffuse(_diffusion, _damping, prev, curr, next);
	
	for (int i = 1; i < _count - 1; ++i)
	{
		prev = curr;
		curr = next;
		next = _h2[i + 1];
		
		_h2[i] = diffuse(_diffusion, _damping, prev, curr, next);
	}
	
	prev = curr;
	curr = next;
	_h2[_count - 1] = diffuse(_diffusion, _damping, prev, curr, next);
}

-(float) dx
{
	return _bounds.size.width / (GLfloat)(_count - 1);
}

-(void) update:(ccTime)dt
{
	// It would be better to run these on a fixed timestep.
	// As an GFX only effect it doesn't really matter though.
	[self vertlet];
	[self diffuse];
}

-(void) draw
{
	GLfloat top = _bounds.size.height;
	float lineHeight = PNGMakeFloat(4);
	
	for (int i = 0; i < _count; ++i)
	{
		mWaterVertices[2 * i + 1].y = top + _h2[i];
		mFoamVertices[2 * i + 0].y = mWaterVertices[2 * i + 1].y - 0.5 * lineHeight;
		mFoamVertices[2 * i + 1].y = mWaterVertices[2 * i + 1].y + 0.5 * lineHeight;
	}
	
	// -- Draw water
	
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	[mWaterShader use];
	[mWaterShader setUniformsForBuiltins];
	
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color);
	
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, sizeof(WaterVertex), &mWaterVertices[0].x);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, sizeof(WaterVertex), &mWaterVertices[0].color.r);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)(2 * _count));
	
	//glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	 
	// -- Draw foam
	
	[mFoamShader use];
	[mFoamShader setUniformsForBuiltins];
	
	ccGLBindTexture2D([mFoamTexture name]);
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords);
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, sizeof(FoamVertex), &mFoamVertices[0].x);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, sizeof(FoamVertex), &mFoamVertices[0].texCoord.u);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)(2 * _count));
	
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
}

-(void) makeSplashAt:(float)x amount:(float)amount
{
	// Changing the values of heightfield in h2 will make the waves move.
	// Here I only change one column, but you get the idea.
	// Change a bunch of the heights using a nice smoothing function for a better effect.
	
	int index = std::max(0, std::min((int)(x / [self dx]), _count - 1));
	
	_h2[index] += amount;
	
	if (index - 1 >= 0)
		_h2[index - 1] += 0.85 * amount;
	if (index + 1 < _count)
		_h2[index + 1] += 0.85 * amount;
	if (index - 2 >= 0)
		_h2[index - 2] += 0.6 * amount;
	if (index + 2 < _count)
		_h2[index + 2] += 0.6 * amount;
	if (index - 3 >= 0)
		_h2[index - 3] += 0.3 * amount;
	if (index + 3 < _count)
		_h2[index + 3] += 0.3 * amount;
}

@end

/**
 -Ideas to make it better:
 * Add clamping to avoid giant, crappy looking waves.
 * Make it run on a fixed timestep.
 * Add texturing to give the surface a nice (and anti-aliased) look.
 * Fancier makeSplash method that does more than a single point.
 */
