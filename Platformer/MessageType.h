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

#ifndef MESSAGETYPE_H
#define MESSAGETYPE_H

typedef enum
{
	Msg_Empty = -1,
	
	// Box2D messages
	Msg_BeginContact,
	Msg_EndContact,
	Msg_PreSolve,
	Msg_PostSolve,
	
	Msg_GameObjAddedToScene,
	
	Msg_WentOnScreen,
	Msg_WentOffScreen,
	
	Msg_BeginCollisionWithWater,
	
	Msg_BeginCollisionWithConcreteSlab,
	Msg_EndCollisionWithConcreteSlab,
	
	Msg_BeginCollisionWithPlayer,
	Msg_EndCollisionWithPlayer,
	Msg_CollidedWithPlayer,
	Msg_StompedByPlayer,
	
	Msg_HitByBullet,
	Msg_HitByBomb,
	Msg_HitByBarrelExplosion,
	
	Msg_KeyPickedUp,
	Msg_KeyLost,
	Msg_DoorOpened,
	Msg_BoulderStopped,
	
	Msg_ZeroHealth,
	
	Msg_Activated,
	
	Msg_HealthChanged,
	Msg_LifeLost,
	Msg_LevelComplete,
	
	Msg_SceneEntered,
	
	Msg_PauseGame,
	Msg_ResumeGame,
	
	Msg_ControllerStateChanged,
	
	Msg_LanguageChanged,
	
	Msg_ButtonPressed,
	Msg_ButtonReleased,
	Msg_ButtonClicked,
	
	Msg_ProductValidationCompleted,
	Msg_RestoreTransactionsCompleted,
	Msg_TransactionCompleted
	
} MessageType;

#endif
