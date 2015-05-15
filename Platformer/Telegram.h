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

#ifndef TELEGRAM_H
#define TELEGRAM_H

#import "MessageType.h"


struct Telegram
{
	int Sender;
	int Receiver;
	
	MessageType Msg;
	
	void* ExtraInfo;
	void* ExtraInfo2;
	
	Telegram() : Sender(-1), Receiver(-1), Msg(Msg_Empty) {}
	
	Telegram(int sender, int receiver, MessageType msg, void* info = NULL, void* info2 = NULL) :
		Sender(sender), Receiver(receiver), Msg(msg), ExtraInfo(info), ExtraInfo2(info2) {}
};

const double SmallestDelay = 0.25;


inline bool operator==(const Telegram& t1, const Telegram& t2)
{
	return (t1.Sender == t2.Sender) && (t1.Receiver == t2.Receiver) && (t1.Msg == t2.Msg);
}

#endif
