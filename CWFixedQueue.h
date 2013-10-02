/*
//  CWFixedQueue.h
//  Zangetsu
//
//  Created by Colin Wheeler on 9/10/12.
//
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

/**
 CWFixedQueue

 CWFixedQueue is intended to be a liberal queue data structure. It is
 intended to be a collection object that forces old objects out the queue
 when they surpass the capacity of the data structure. Unlike a strict
 queue, CWFixedQueue can return and set objects at any index in the
 structure. Although CWFixedQueues can be used like NSArrays it should not
 be used for this purpose. CWFixedQueues should be used where you need
 a fixed lenth list where older objects get pushed off the queue.
 */

typedef void (^CWFixedQueueEvictionBlock)(id evictedObject);

@interface CWFixedQueue : NSObject

/**
 Initializes the Queue & sets the capacity property to the NSUInteger passed in
 
 @param capacity a NSUInteger that limits the queue to this number of items
 @return a new CWFixedQueue instance
 */
-(instancetype)initWithCapacity:(NSUInteger)capacity;

/**
 An optional label you can apply for debugging purposes
 
 This label string will print off in the -descrption
 */
@property(copy) NSString *label;

/**
 The maximum # of items the queue should contain
 */
@property(assign) NSUInteger capacity;

/**
 The eviction block is called just before an Object is evicted from the Queue
 
 Providing an eviction block to the queue gives you a chance to do something 
 with an object before it is evicted, otherwise it will simply remove the item 
 from the queue and not notify you.
 */
@property(copy) CWFixedQueueEvictionBlock evictionBlock;

/**
 Enqueues the object onto the queue
 
 If the object is nil then this method does nothing. If enqueuing this item
 makes the queue over capacity then the queue will remove the oldest items
 till the queue is no longer over capacity.
 
 @param object the object to be enqueued
 */
-(void)enqueue:(id)object;

/**
 Enqueues the objects in array onto the queue
 
 If array is nil or contains 0 objects this method does nothing. Otherwise
 this method will add the objects in array onto the queue. If enqueueing
 these objects makes the queue over capacity then it will remove the
 oldest items until the queue is no longer over capacity.
 
 @param array the array of items to be enqueued
 */
-(void)enqueueObjectsInArray:(NSArray *)array;

/**
 Removes the oldest item off the queue and returns it
 
 If the queue has no items this returns nil, otherwise it removes the oldest
 item off the queue and returns it to you.
 
 @return the oldest item on the queue or nil if there are no items in the queue
 */
-(id)dequeue;

/**
 Returns the object at the given index. This method matches NSArrays behavior.

 This method is present to support Objective-C's Object subscripting syntax.
 If index is beyond the bounds of the array this method will log a message
 about the failing condition and throw an assertion.

 @param index the slot whose corresponding object is to be retrieved
 @return the object at the given subscript
 */
-(id)objectAtIndexedSubscript:(NSUInteger)index;

/**
 Sets the object at the given index.
 
 If object is nil or if the index is beyond the bounds of the array then this
 method will throw an assertion.

 @param object the object to be retained by the collection and accessible at idx
 @param idx the index that object is to be inserted at
 */
-(void)setObject:(id)object atIndexedSubscript:(NSUInteger)idx;

/**
 Returns the count of items in the queue
 
 @return count the number of items in the queue
 */
-(NSUInteger)count;

/**
 Enumerates over the queue contents using a block
 
 If block is nil this method will throw an assertion.

 @param object The object currently being enumerated over
 @param index The objects position in the queue
 @param stop set this to YES to stop enumeration at any time
 */
-(void)enumerateObjectsUsingBlock:(void (^)(id object, NSUInteger index, BOOL *stop))block;

/**
 Enumerates over the queue using a block
 
 If block is nil this method will throw an assertion.
 
 @param options NSEnumerationOptions same as NSArrays options
 @param block the block to be called for enumerating the block
 @param object The object currently being enumerated over
 @param index The objects position in the queue
 @param stop set this to YES to stop enumeration at any time
 */
-(void)enumerateObjectsWithOptions:(NSEnumerationOptions)options
						usingBlock:(void (^)(id object, NSUInteger index, BOOL *stop))block;

@end
