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

#ifdef GL_ES
precision mediump float;
#endif

varying vec2 v_texCoord;

uniform sampler2D CC_Texture0;
uniform vec3 u_color;
uniform float u_luminance;


float Lum(vec3 colour)
{
	return (colour.r * 0.3) + (colour.g * 0.59) + (colour.b * 0.11);
}

vec3 ClipColour(vec3 colour, float luminance)
{
	float cMin = min(min(colour.r, colour.g), colour.b);
	float cMax = max(max(colour.r, colour.g), colour.b);
	
	vec3 lum3 = vec3(luminance);
	
	if (cMin < 0.0) colour = lum3 + (colour - lum3) * luminance / (luminance - cMin);
	if (cMax > 1.0) colour = lum3 + (colour - lum3) * (1.0 - luminance) / (cMax - luminance);
	
	return colour;
}

vec3 SetLum(vec3 colour, float luminance)
{
	float diff = luminance - u_luminance;
	
	colour += vec3(diff);
	
	return ClipColour(colour, luminance);
}

void main()
{
	vec3 baseColor = texture2D(CC_Texture0, v_texCoord).rgb;
	vec3 resultingColor = SetLum(u_color, Lum(baseColor));
	
	gl_FragColor = vec4(resultingColor, 1);
}
