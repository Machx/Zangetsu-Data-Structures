/*
//  CWStack.h
//  Zangetsu
//
//  Created by Colin Wheeler on 5/24/11.
//  Copyright 2012. All rights reserved.
//
 
 Copyright (c) 2013, Colin Wheeler
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 - Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

  /*
 This class should not make any use of the Zangetsu Framework API's so it can
 retain its independence and be used in other projects not making use of the
 Zangetsu Framework.
  */

/**
 This class is thread safe
 */

#import <Foundation/Foundation.h>

/**
 If uncommented (defined) then this enables Stack Peeking or Subscript access to
 read abitrary indexes within the receivers bounds.
 */
#ifndef CWSTACK_PEEKING
#define CWSTACK_PEEKING
#endif

@interface CWStack : NSObject

/**
 initializes a CWStack object with the content of the array passed in
 
 If the NSArray passed in has at least 1 object
 
 @param objects an array to initialize the contents of a CWStack object with
 @return an intialized CWStack object
 */
-(instancetype)initWithObjectsFromArray:(NSArray *)objects;

/**
 Pushes an object onto the stack
 
 Pushes the object onto the stack instance. If the object
 is nil then this method does nothing.
 
 @param object the object you want pushed onto the stack
 */
-(void)push:(id)object;

/**
 pops an object off of the top of the CWStack object and returns that object
 
 @return the object at the top of the stack
 */
-(id)pop;

#ifdef CWSTACK_PEEKING

/**
 Accesses the object at the specified index
 
 This method has the same behavior as NSArray object subscripting because 
 internally it just forwards this same method onto its internal NSArray ivar,
 but in a thread safe manner.
 
 @param index A specified index to access the object at
 @return the object at the specified index
 */
-(id)objectAtIndexedSubscript:(NSUInteger)index;

#endif

/**
 continuously pops objects off the stack until the object specified is found
 
 popToObject pops all objects off the stack until it finds the object specified
 in the passed in value. If the object is not in the stack it returns nil 
 immediately, otherwise a NSArray containing all objects popped off the stack 
 before the object specified is returned
 
 @param object the object you wish the stack to be popped off to
 @return an array of all popped off objects, or nil if object is not in receiver
 */
-(NSArray *)popToObject:(id)object;

/**
 pops to object and calls block for each popped off object as it pops off
 
 If the object provided does not exist in the stack then the method returns 
 immediately
 
 @param object The object you wish to pop the stack to
 @param block the block that will be called as objects are popped off
 */
-(void)popToObject:(id)object withBlock:(void (^)(id obj))block;

/**
 pops all objects off the stack except for the bottom object
 
 @return a NSArray of all popped off objects
 */
-(NSArray *)popToBottomOfStack;

/**
 returns the object at the top of the stack
 
 @return the objct at the top of the stack
 */
-(id)topOfStackObject;

/**
 returns the object at the bottom of the stack
 
 @return the objct at the bottom of the stack
 */
-(id)bottomOfStackObject;

/**
 clears the stack of all objects
 */
-(void)clearStack;

/**
 checks to see if the stack contents of another CWStack object are the same
 
 first checks to see if the other object is a CWStack Object and then checks to 
 see if their contents are the same. This method does this by comparing the 
 string description of the contents to the receivers string description of its 
 contents. This way is used currently because the private ivar that holds the 
 contents is hidden and never exposed in the public header for CWStack. This is 
 as close to direct ivar access to private contents that you will get in CWStack

 @param object another CWStack object which you wish to compare its contents to
 @return a BOOL with YES if the 2 stack objects have the same contents or NO
 */
-(BOOL)isEqualToStack:(CWStack *)aStack;

/**
 Returns a bool indicating if the pass in object is contained in the stack
 
 @param object An object you wish to see if its contained in the receiver
 @return A BOOL value of YES if it is contained in the receiver, no otherwise
 */
-(BOOL)containsObject:(id)object;

/**
 Returns if the object is in the receiver using the block to compare objects
 
 @param block a block with a id object passed in and returning a BOOL
 @return a BOOL with yes if any block call returned yes, otherwise no
 */
-(BOOL)containsObjectWithBlock:(BOOL (^)(id object))block;

/**
 returns if the stack is currently empty
 
 @return a BOOL indicating if the stack is empty
 */
-(BOOL)isEmpty;

/**
 returns a count of objects in the current stack object
 
 @return a NSInteger indicating how many objects are currently in the stack
 */
-(NSInteger)count;
@end
