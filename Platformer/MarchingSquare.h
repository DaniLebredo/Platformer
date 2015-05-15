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

#ifndef MARCHINGSQUARE_H
#define MARCHINGSQUARE_H

#import "StdInclude.h"
#import "Utility.h"
#import "Singleton.h"


class MarchingSquare : public Singleton<MarchingSquare>
{
	friend class Singleton<MarchingSquare>;

public:
	void DoMarch(const IntVector& data, int width, int height, Point2iVector& output);

private:
	MarchingSquare() {}
	MarchingSquare(const MarchingSquare&);
	virtual ~MarchingSquare() {}
	MarchingSquare& operator=(const MarchingSquare&);
	
	bool findStartPoint(Point2i& startPoint);
	void walkPerimeter(Point2i startPoint, Point2iVector& output);
	void makeStep(const Point2i& point);
	bool isPixelSolid(const Point2i& point);
	
	// A simple enumeration to represent the direction we
	// just moved, and the direction we will next move.
	enum StepDirection
	{
		StepDir_None,
		StepDir_Up,
		StepDir_Left,
		StepDir_Down,
		StepDir_Right
	};
	
	int mWidth;
	int mHeight;
	
	IntVector mData;
	
	StepDirection mPrevStep;
	StepDirection mNextStep;
};

#endif
