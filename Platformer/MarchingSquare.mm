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

#import "MarchingSquare.h"


void MarchingSquare::DoMarch(const IntVector& data, int width, int height, Point2iVector& output)
{
	mPrevStep = StepDir_None;
	mNextStep = StepDir_None;
	
	mData = data;
	mWidth = width;
	mHeight = height;
	
	Point2i startPoint;
	
	if (findStartPoint(startPoint))
	{
		walkPerimeter(startPoint, output);
	}
}

bool MarchingSquare::findStartPoint(Point2i& startPoint)
{
	for (int index = 0; index < mData.size(); ++index)
	{
		if (mData[index] != 0)
		{
			startPoint.x = index % mWidth;
			startPoint.y = index / mWidth;
			return true;
		}
	}
	
	// If we get here, we've scanned the whole image and found nothing.
	return false;
}

void MarchingSquare::walkPerimeter(Point2i startPoint, Point2iVector& output)
{
	startPoint.x = Clamp(startPoint.x, 0, mWidth);
	startPoint.y = Clamp(startPoint.y, 0, mHeight);
	
	// Our current x and y positions, initialized to the init values passed in.
	Point2i point = startPoint;
	
	// The main while loop, continues stepping until we return to our initial points.
	do
	{
		// Evaluate our state, and set up our next direction.
		makeStep(point);
		
		if (point.x >= 0 && point.x <= mWidth && point.y >= 0 && point.y <= mHeight)
		{
			output.push_back(point);
		}
		
		switch (mNextStep)
		{
			case StepDir_Up:
				--point.y;
				break;
			case StepDir_Left:
				--point.x;
				break;
			case StepDir_Down:
				++point.y;
				break;
			case StepDir_Right:
				++point.x;
				break;
			default:
				break;
		}
	} while (point != startPoint);
}

// Determines and sets the state of the 4 pixels that
// represent our current state, and sets our current and
// previous directions
void MarchingSquare::makeStep(const Point2i& point)
{
	// Scan our 4 pixel area
	bool upLeft		= isPixelSolid(Point2i(point.x - 1, point.y - 1));
	bool upRight	= isPixelSolid(Point2i(point.x, point.y - 1));
	bool downLeft	= isPixelSolid(Point2i(point.x - 1, point.y));
	bool downRight	= isPixelSolid(Point2i(point.x, point.y));
	
	// Store our previous step
	mPrevStep = mNextStep;
	
	// Determine which state we are in
	int state = 0;
	
	if (upLeft) state |= 1;
	if (upRight) state |= 2;
	if (downLeft) state |= 4;
	if (downRight) state |= 8;
	
	// State now contains a number between 0 and 15
	// representing our state.
	// In binary, it looks like 0000-1111 (in binary)
	
	// An example. Let's say the top two pixels are filled,
	// and the bottom two are empty.
	// Stepping through the if statements above with a state
	// of 0b0000 initially produces:
	// Upper Left == true ==>  0b0001
	// Upper Right == true ==> 0b0011
	// The others are false, so 0b0011 is our state
	// (That's 3 in decimal.)
	
	// Looking at the chart above, we see that state
	// corresponds to a move right, so in our switch statement
	// below, we add a case for 3, and assign Right as the
	// direction of the next step. We repeat this process
	// for all 16 states.
	
	// So we can use a switch statement to determine our
	// next direction based on
	switch (state)
	{
		case 1:
			mNextStep = StepDir_Up;
			break;
		case 2:
			mNextStep = StepDir_Right;
			break;
		case 3:
			mNextStep = StepDir_Right;
			break;
		case 4:
			mNextStep = StepDir_Left;
			break;
		case 5:
			mNextStep = StepDir_Up;
			break;
		case 6:
			mNextStep = (mPrevStep == StepDir_Up) ? StepDir_Left : StepDir_Right;
			break;
		case 7:
			mNextStep = StepDir_Right;
			break;
		case 8:
			mNextStep = StepDir_Down;
			break;
		case 9:
			mNextStep = (mPrevStep == StepDir_Right) ? StepDir_Up : StepDir_Down;
			break;
		case 10:
			mNextStep = StepDir_Down;
			break;
		case 11:
			mNextStep = StepDir_Down;
			break;
		case 12:
			mNextStep = StepDir_Left;
			break;
		case 13:
			mNextStep = StepDir_Up;
			break;
		case 14:
			mNextStep = StepDir_Left;
			break;
		default:
			mNextStep = StepDir_None;
			break;
	}
}

bool MarchingSquare::isPixelSolid(const Point2i& point)
{
	if (point.x < 0 || point.y < 0 || point.x >= mWidth || point.y >= mHeight)
		return false;
	
	if (mData[point.x + point.y * mWidth] != 0)
		return true;
	
	return false;
}
