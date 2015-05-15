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

#import "IAPDelegate.h"
#import "Game.h"


@implementation IAPDelegate

@synthesize products = mProducts;

-(id) init
{
	self = [super init];
	if (self)
	{
		mCanValidateProducts = true;
		mProducts = nil;
	}
	return self;
}

-(void) dealloc
{
	[mProducts release];
	
	[super dealloc];
}

-(void) provideContent:(NSString*)productIdentifier
{
	NSLog(@"Toggling flag for: %@", productIdentifier);
	
	std::string prodId([productIdentifier UTF8String]);
	
	if (Game::Instance()->Data().ProductRepo().ItemExists(prodId))
	{
		ProductData& prodData = Game::Instance()->Data().ProductRepo().Item(prodId);
		
		if (!prodData.Purchased())
		{
			prodData.SetPurchased(true);
			Game::Instance()->SaveStats();
		}
	}
}

-(void) completeTransaction:(SKPaymentTransaction*)transaction
{
	NSLog(@"completeTransaction...");
	//[self recordTransaction: transaction];
	[self provideContent:transaction.payment.productIdentifier];
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
	
	Game::Instance()->OnTransactionCompleted(true);
}

- (void) restoreTransaction:(SKPaymentTransaction*)transaction
{
	NSLog(@"restoreTransaction...");
	//[self recordTransaction: transaction];
	[self provideContent:transaction.originalTransaction.payment.productIdentifier];
	[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

-(void)failedTransaction:(SKPaymentTransaction*)transaction
{
	/*
	if (transaction.error.code != SKErrorPaymentCancelled)
	{
		NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
	}
	 */
	
	NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
	
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	
	Game::Instance()->OnTransactionCompleted(false);
}

-(void) paymentQueue:(SKPaymentQueue*)queue updatedTransactions:(NSArray*)transactions
{
	for (SKPaymentTransaction* transaction in transactions)
	{
		switch (transaction.transactionState)
		{
			// Call the appropriate custom method.
            case SKPaymentTransactionStatePurchased:
				NSLog(@"Complete transaction");
				[self completeTransaction:transaction];
				//[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				break;
				
			case SKPaymentTransactionStateFailed:
				NSLog(@"Failed transaction");
				[self failedTransaction:transaction];
				//[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				break;
				
			case SKPaymentTransactionStateRestored:
				NSLog(@"Restore transaction");
				[self restoreTransaction:transaction];
				//[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				break;
				
			default:
				break;
		}
	}
}

-(void) productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse*)response
{
	NSLog(@"CALLBACK TRIGGERED");
	self.products = response.products;
	
	for (NSString* invalidIdentifier in response.invalidProductIdentifiers)
	{
		// Handle any invalid product identifiers.
		NSLog(@"INVALID ID: %@", invalidIdentifier);
	}
	
	//[mStoreLayer productValidationCompletedWithSuccess:YES];
	
	Game::Instance()->OnProductValidationCompleted(true);
	
	mCanValidateProducts = true;
}

-(void) request:(SKRequest*)request didFailWithError:(NSError*)error
{
	NSLog(@"ERROR OCCURRED:");
	NSLog(@"%@", error.description);
		
	//[mStoreLayer productValidationCompletedWithSuccess:NO];
	
	Game::Instance()->OnProductValidationCompleted(false);
	
	mCanValidateProducts = true;
}

-(void) validateProductIdentifiers:(NSSet*)productIdentifiers
{
	if (mCanValidateProducts)
	{
		mCanValidateProducts = false;
		
		SKProductsRequest* productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
		productsRequest.delegate = self;
		[productsRequest start];
		[productsRequest release];
	}
}

-(void) buyProductWithIdentifier:(NSString*)productIdentifier
{
	for (SKProduct* product in self.products)
	{
		if ([product.productIdentifier isEqualToString:productIdentifier])
		{
			SKMutablePayment* payment = [SKMutablePayment paymentWithProduct:product];
			payment.quantity = 1;
			[[SKPaymentQueue defaultQueue] addPayment:payment];
			break;
		}
	}
}

-(void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue*)queue
{
	Game::Instance()->OnRestoreTransactionsCompleted(true);
}

-(void) paymentQueue:(SKPaymentQueue*)queue restoreCompletedTransactionsFailedWithError:(NSError*)error
{
	Game::Instance()->OnRestoreTransactionsCompleted(false);
}

@end
