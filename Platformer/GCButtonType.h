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

#ifndef GCBUTTONTYPE_H
#define GCBUTTONTYPE_H

enum GCButtonType
{
	GCBtn_Invalid = -1,
	
	// Basic profile
	
	GCBtn_DPadUp,
	GCBtn_DPadDown,
	GCBtn_DPadLeft,
	GCBtn_DPadRight,
	GCBtn_ButtonA,
	GCBtn_ButtonB,
	GCBtn_ButtonX,
	GCBtn_ButtonY,
	GCBtn_ButtonL1,
	GCBtn_ButtonR1,
	
	// Extended profile
	
	GCBtn_LThumbUp,
	GCBtn_LThumbDown,
	GCBtn_LThumbLeft,
	GCBtn_LThumbRight,
	GCBtn_RThumbUp,
	GCBtn_RThumbDown,
	GCBtn_RThumbLeft,
	GCBtn_RThumbRight,
	GCBtn_ButtonL2,
	GCBtn_ButtonR2
};

#endif
