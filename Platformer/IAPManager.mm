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

#import "IAPManager.h"
#import "IAPDelegate.h"


IAPManager::IAPManager()
{
	mDelegate = [[IAPDelegate alloc] init];
	CCLOG(@"IAP DELEGATE CREATED");
}

IAPManager::~IAPManager()
{
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:mDelegate];
	[mDelegate release];
}

void IAPManager::RegisterTransactionQueueObserver()
{
	[[SKPaymentQueue defaultQueue] addTransactionObserver:mDelegate];
}

void IAPManager::RestorePurchases()
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

void IAPManager::ValidateProductIdentifiers(StringVector productIdentifiers)
{
	NSMutableSet* identifiers = [[NSMutableSet alloc] initWithCapacity:10];
	
	for (int index = 0; index < productIdentifiers.size(); ++index)
	{
		NSString* prodId = [[NSString alloc] initWithFormat:@"%s", productIdentifiers[index].c_str()];
		[identifiers addObject:prodId];
		[prodId release];
	}
	
	NSLog(@"%@", identifiers);
	
	[mDelegate validateProductIdentifiers:identifiers];
	
	[identifiers release];
}

void IAPManager::BuyFullVersion()
{
	[mDelegate buyProductWithIdentifier:@"eu.pointynose.lethallance.fullversion"];
}
