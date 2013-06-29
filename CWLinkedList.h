/*
//  CWDoublyLinkedList.h
//  Zangetsu
//
//  Created by Colin Wheeler on 5/11/12.
//  Copyright (c) 2012. All rights reserved.
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

#import <Foundation/Foundation.h>
	
typedef enum : NSUInteger {
	kCWDoublyLinkedListEnumerateForward = 0,
	kCWDoublyLinkedListEnumerateReverse = 1
} CWDoublyLinkedListEnumerationOption;

@interface CWLinkedList : NSObject

/**
 Returns a count of how many objects are present in the receiver
 
 @return a NSUInteger with the receivers item count
 */
@property(readonly,assign) NSUInteger count;

/**
 Appends anObject to the end of the receiver
 
 This simply appends an object to the tail end of the receiver. If anObject is 
 nil then this method simply does nothing.
 
 @praram an Object any valid Cocoa object
 */
-(void)addObject:(id)anObject;

/**
 Inserts an object at the specified index
 
 This method checks to make sure it has a valid Cocoa object, if it doesn't it
 simply returns right away. Then it checks the index to see if its valid. It 
 must be within the bounds of the receiver or at the very end. For example if 
 you had a list with 3 objects in it (0,1,2) and you said insert at index 3 this
 would be valid, in that case it would simply perform -addObject: and return. 
 Otherwise this method inserts the object at the specified index.
 
 @param anObject any valid Cocoa object
 @param index a NSUInteger with a valid index
 */
-(void)insertObject:(id)anObject atIndex:(NSUInteger)index;

/**
 Removes the object at a specified index in the receiver
 
 First a check is done to see if the index is valid. If the index is invalid 
 then it checks to see if the list is empty. If either of these true then the 
 method immediately exits. Otherwise it goes to the specified index and removes
 the node from the receiver.
 
 @param NSUInteger a valid index within the bounds of the receiver
 */
-(void)removeObjectAtIndex:(NSUInteger)index;

/**
 Removes the specified object from the receiver if found
 
 This method simple enumerates through the contents of the receiver and if it 
 finds the object then it will remove it. Otherwise this will enumerate through
 all objects in the receiver without finding anything and then exit.
 
 @param object any valid Cocoa object
 */
-(void)removeObject:(id)object;

/**
 Returns the object at a specified index in the receiver
 
 This method checks for the index being within the bounds of the receiver and 
 if not then it immediately exits. Otherwise it enumerates to the specified 
 index and returns the object associated with that index.
 
 @param index where you want the data associated with that slot in the receiver
 */
-(id)objectAtIndexedSubscript:(NSUInteger)index;

/**
 Sets object to be at the specified index in the receiver
 
 This method will get a reference to the node at the specified index and set 
 object to be the value there. This method may log any errors it encounters
 if it cannot set your object to be at the specified index.
 
 @param object the object to be added to the receiver Linked List
 @param idx the index to set the object at
 */
-(void)setObject:(id)object atIndexedSubscript:(NSUInteger)idx;

/**
 Swaps the objects at the given indexes with each other if the indexes are valid
 
 @param index1 a NSUInteger index
 @param index2 a NSUinteger index
 */
-(void)swapObjectAtIndex:(NSUInteger)index1 withIndex:(NSUInteger)index2;

/**
 Returns a new CWDoublyLinkedList with the range given in the receiver
 
 This method checks for a valid range. If the range is invalid then this method
 immediately exits. Otherwise it adds the node in the receiver to a new list and
 returns that list.
 
 @param a NSRange for the receiver
 @return if the range index is valid a new CWDoublyLinkedList instance, else nil
 */
-(CWLinkedList *)linkedListWithRange:(NSRange)range;

/**
 Enumerates the contents of the receiver
 
 If the list is empty this method immediately exits. Otherwise this method then 
 starts at the front of the list and enumerates through all nodes until it 
 reaches the end.
 
 @param object (block) the object being enumerated over
 @param index (block) the index of the object being enumerated over
 @param stop (block) a BOOL pointer which you can set to YES to stop enumeration
 */
-(void)enumerateObjectsWithBlock:(void(^)(id object,NSUInteger index, BOOL *stop))block;

/**
 Enumerates the nodes of the receiver linked list
 
 If the list is empty this method immediately exits. If 
 kCWDoublyLinkedListEnumerateForward is passed in then this is the same as 
 calling -enumerateObjectsWithBlock: otherwise passing in 
 kCWDoublyLinkedListEnumerateReverse enumerates the nodes of the reseiver 
 starting at the end and goes backwards towards the front of the list.
 
 @param option the way the list should be enumerated in
 @param object (block) the object being enumerated over
 @param index (block) the index of the object being enumerated over
 @param stop (block) a BOOL pointer which you can set to YES to stop enumeration
 */
-(void)enumerateObjectsWithOption:(CWDoublyLinkedListEnumerationOption)option
					   usingBlock:(void (^)(id object, NSUInteger index, BOOL *stop))block;

@end
