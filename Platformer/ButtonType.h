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

#ifndef BUTTONTYPE_H
#define BUTTONTYPE_H

typedef enum
{
	Btn_Invalid = -1,
	
	Btn_Up,
	Btn_Down,
	Btn_Left,
	Btn_Right,
	Btn_A,
	Btn_B,
	
	Btn_Pause,
	Btn_Resume,
	
	Btn_Start,
	Btn_Restart,
	Btn_Advance,
	Btn_Quit,
	Btn_Ready,
	
	Btn_GameCompleted,
	Btn_WorldCompleted,
	
	Btn_Facebook,
	Btn_Twitter,
	
	Btn_Leaderboards,
	Btn_Achievements,
	
	Btn_Music,
	Btn_Sound,
	
	Btn_Info,
	
	Btn_Settings,
	Btn_Controls,
	Btn_Language,
	
	Btn_Store,
	Btn_BuyFullVersion,
	Btn_RestorePurchases,
	
	Btn_Back,
	
	Btn_Reset,
	Btn_Apply,
	Btn_UseGestures,
	
	Btn_World,
	Btn_Level,
	
	Btn_ExitToOS
	
} ButtonType;

#endif
