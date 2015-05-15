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

#import "ContactListener.h"
#import "LevelController.h"
#import "GameObject.h"
#import "CollisionInfo.h"


ContactListener::ContactListener(LevelController* controller) :
	mLevelController(controller)
{
	assert(mLevelController != NULL && "<ContactListener::ctor>: Level controller must not be NULL.");
}

void ContactListener::BeginContact(b2Contact* contact)
{
	if (mLevelController->IsBeingDestroyed()) return;
	
	GameObject* actorA = static_cast<GameObject*>(contact->GetFixtureA()->GetBody()->GetUserData());
	GameObject* actorB = static_cast<GameObject*>(contact->GetFixtureB()->GetBody()->GetUserData());
	
	if (actorA != NULL && actorB != NULL)
	{
		CollisionInfo collisionInfoA(actorA, actorB, contact);
		actorA->AddContact(collisionInfoA);
		/*
		Telegram telegramA(ID_IRRELEVANT, actorA->ID(), Msg_BeginContact, static_cast<void*>(&collisionInfoA));
		actorA->HandleMessage(telegramA);
		//mLevelController->MsgDispatcher()->DispatchMsg(ID_IRRELEVANT, actorA->ID(), Msg_BeginContact, static_cast<void*>(&collisionInfoA));
		*/
		
		CollisionInfo collisionInfoB(actorB, actorA, contact);
		actorB->AddContact(collisionInfoB);
		/*
		Telegram telegramB(ID_IRRELEVANT, actorB->ID(), Msg_BeginContact, static_cast<void*>(&collisionInfoB));
		actorB->HandleMessage(telegramB);
		//mLevelController->MsgDispatcher()->DispatchMsg(ID_IRRELEVANT, actorB->ID(), Msg_BeginContact, static_cast<void*>(&collisionInfoB));
		*/
	}
}

void ContactListener::EndContact(b2Contact* contact)
{
	if (mLevelController->IsBeingDestroyed()) return;
	
	GameObject* actorA = static_cast<GameObject*>(contact->GetFixtureA()->GetBody()->GetUserData());
	GameObject* actorB = static_cast<GameObject*>(contact->GetFixtureB()->GetBody()->GetUserData());
	
	if (actorA != NULL && actorB != NULL)
	{
		CollisionInfo collisionInfoA(actorA, actorB, contact);
		actorA->RemoveContact(collisionInfoA);
		/*
		Telegram telegramA(ID_IRRELEVANT, actorA->ID(), Msg_EndContact, static_cast<void*>(&collisionInfoA));
		actorA->HandleMessage(telegramA);
		//mLevelController->MsgDispatcher()->DispatchMsg(ID_IRRELEVANT, actorA->ID(), Msg_EndContact, static_cast<void*>(&collisionInfoA));
		*/
		
		CollisionInfo collisionInfoB(actorB, actorA, contact);
		actorB->RemoveContact(collisionInfoB);
		/*
		Telegram telegramB(ID_IRRELEVANT, actorB->ID(), Msg_EndContact, static_cast<void*>(&collisionInfoB));
		actorB->HandleMessage(telegramB);
		//mLevelController->MsgDispatcher()->DispatchMsg(ID_IRRELEVANT, actorB->ID(), Msg_EndContact, static_cast<void*>(&collisionInfoB));
		*/
	}
}

void ContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold)
{
	if (mLevelController->IsBeingDestroyed()) return;
	
	GameObject* actorA = static_cast<GameObject*>(contact->GetFixtureA()->GetBody()->GetUserData());
	GameObject* actorB = static_cast<GameObject*>(contact->GetFixtureB()->GetBody()->GetUserData());
	
	if (actorA != NULL && actorB != NULL)
	{
		CollisionInfo collisionInfoA(actorA, actorB, contact, oldManifold);
		Telegram telegramA(ID_IRRELEVANT, actorA->ID(), Msg_PreSolve, static_cast<void*>(&collisionInfoA));
		actorA->HandleMessage(telegramA);
		//mLevelController->MsgDispatcher()->DispatchMsg(ID_IRRELEVANT, actorA->ID(), Msg_PreSolve, static_cast<void*>(&collisionInfoA));
		
		CollisionInfo collisionInfoB(actorB, actorA, contact, oldManifold);
		Telegram telegramB(ID_IRRELEVANT, actorB->ID(), Msg_PreSolve, static_cast<void*>(&collisionInfoB));
		actorB->HandleMessage(telegramB);
		//mLevelController->MsgDispatcher()->DispatchMsg(ID_IRRELEVANT, actorB->ID(), Msg_PreSolve, static_cast<void*>(&collisionInfoB));
	}
}

void ContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse)
{
	if (mLevelController->IsBeingDestroyed()) return;
	
	GameObject* actorA = static_cast<GameObject*>(contact->GetFixtureA()->GetBody()->GetUserData());
	GameObject* actorB = static_cast<GameObject*>(contact->GetFixtureB()->GetBody()->GetUserData());
	
	if (actorA != NULL && actorB != NULL)
	{
		CollisionInfo collisionInfoA(actorA, actorB, contact, impulse);
		Telegram telegramA(ID_IRRELEVANT, actorA->ID(), Msg_PostSolve, static_cast<void*>(&collisionInfoA));
		actorA->HandleMessage(telegramA);
		//mLevelController->MsgDispatcher()->DispatchMsg(ID_IRRELEVANT, actorA->ID(), Msg_PostSolve, static_cast<void*>(&collisionInfoA));
		
		CollisionInfo collisionInfoB(actorB, actorA, contact, impulse);
		Telegram telegramB(ID_IRRELEVANT, actorB->ID(), Msg_PostSolve, static_cast<void*>(&collisionInfoB));
		actorB->HandleMessage(telegramB);
		//mLevelController->MsgDispatcher()->DispatchMsg(ID_IRRELEVANT, actorB->ID(), Msg_PostSolve, static_cast<void*>(&collisionInfoB));
	}
}
