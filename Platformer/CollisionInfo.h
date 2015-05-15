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

#ifndef COLLISIONINFO_H
#define COLLISIONINFO_H

#import "Box2D.h"
#import "FixtureUserData.h"

class GameObject;


struct CollisionInfo
{
	CollisionInfo(GameObject* thisObj, GameObject* otherObj, b2Contact* contact) :
		ThisObject(thisObj), OtherObject(otherObj), Contact(contact), OldManifold(NULL), Impulse(NULL)
	{
		this->initialize();
	}
	
	CollisionInfo(GameObject* thisObj, GameObject* otherObj, b2Contact* contact, const b2Manifold* oldManifold) :
		ThisObject(thisObj), OtherObject(otherObj), Contact(contact), OldManifold(oldManifold), Impulse(NULL)
	{
		this->initialize();
	}
	
	CollisionInfo(GameObject* thisObj, GameObject* otherObj, b2Contact* contact, const b2ContactImpulse* impulse) :
		ThisObject(thisObj), OtherObject(otherObj), Contact(contact), Impulse(impulse), OldManifold(NULL)
	{
		this->initialize();
	}
	
	bool operator==(const CollisionInfo& other) const
	{
		return ThisObjFix == other.ThisObjFix && OtherObjFix == other.OtherObjFix;
	}
	
	GameObject* ThisObject;
	GameObject* OtherObject;
	
	b2Fixture* ThisObjFix;
	b2Fixture* OtherObjFix;
	
	int ThisObjFixType;
	int OtherObjFixType;
	
	FixtureUserData* ThisFixUserData;
	FixtureUserData* OtherFixUserData;
	
	b2Contact* Contact;
	const b2Manifold* OldManifold;
	const b2ContactImpulse* Impulse;
	
	// User data
	bool Processed;
	b2Vec2 PlayerVelocity;
	
private:
	void initialize()
	{
		b2Fixture* fixA = Contact->GetFixtureA();
		b2Fixture* fixB = Contact->GetFixtureB();
		
		FixtureUserData* fixUserDataA = static_cast<FixtureUserData*>(fixA->GetUserData());
		FixtureUserData* fixUserDataB = static_cast<FixtureUserData*>(fixB->GetUserData());
		
		int fixTypeA = fixUserDataA->Type;
		int fixTypeB = fixUserDataB->Type;
		
		GameObject* actorA = static_cast<GameObject*>(fixA->GetBody()->GetUserData());
		GameObject* actorB = static_cast<GameObject*>(fixB->GetBody()->GetUserData());
		
		if (actorA == ThisObject && actorB == OtherObject)
		{
			ThisObjFix = fixA;
			ThisObjFixType = fixTypeA;
			ThisFixUserData = fixUserDataA;
			
			OtherObjFix = fixB;
			OtherObjFixType = fixTypeB;
			OtherFixUserData = fixUserDataB;
		}
		else if (actorA == OtherObject && actorB == ThisObject)
		{
			ThisObjFix = fixB;
			ThisObjFixType = fixTypeB;
			ThisFixUserData = fixUserDataB;
			
			OtherObjFix = fixA;
			OtherObjFixType = fixTypeA;
			OtherFixUserData = fixUserDataA;
		}
		
		// User data
		Processed = false;
		PlayerVelocity.SetZero();
	}
};

#endif
