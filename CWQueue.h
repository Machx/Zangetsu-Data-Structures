/*
//  CWQueue.h
//  Zangetsu
//
//  Created by Colin Wheeler on 10/29/11.
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

/**
 CWQueue is a Thread Safe Class

 Internally CWQueue uses a dispatch_queue_t queue to perform all operations
 on and to ensure that all operations to a given queue instance are 
 executed serially.
 */

@interface CWQueue : NSObject

/**
 Initializes a CWQueue object with the contents of array
 
 When a CWQueue dequeues all the objects initialized from a NSArray it will
 enumerate over them in the same order in which they were added in the array 
 going over object at index 0,1,2...etc.
 
 @param array a NSArray to initialize the contents of the Queue with
 @return an initialized CWQueue instance object
 */
-(instancetype)initWithObjectsFromArray:(NSArray *)array;

/**
 Adds a object to the receiving objects queue
 
 Adds object to the receiving CWQueues internal storage. If the object is
 nil then this method simply does nothing.
 
 @param object added to the end of the queue. If nil an assertion is thrown.
 */
-(void)enqueue:(id)object;

/**
 Adds the objects from the objects array to the receiving queue
 
 This takes the objects in order they are in the objects array and appends them
 onto the receiving queues storage. If the object array is empty(0 objects) or
 nil then this method simply does nothing.
 
 @param a NSArray of objects to be appended onto the receiving queues storage
 */
-(void)enqueueObjectsFromArray:(NSArray *)objects;

/**
 Removes all objects from the receiving queues storage
 */
-(void)removeAllObjects;

/**
 Removes the first object in the queue and returns its reference
 
 Grabs a reference to the first object in CWQueues objects and then removes it
 from the receiving queue object and returns it to you. If the queue has no 
 objects in its storage then this method returns nil.
 
 @return a reference to the first object in the queue after removing it or nil
 */
-(id)dequeue;

/**
 Dequeues the queue with a block until the queue is empty or stop is set to YES
 
 Dequeues the receiving queue, until the queue is empty or until the BOOL 
 pointer in the block is set to YES. If the receiving queue is empty then this
 method will immediately return, otherwise it will dequeue the first object in
 the queue and return to your code (via the block) and pass to you the object 
 being dequeued and the BOOL pointer to stop further dequeueing if you desire.
 */
-(void)dequeueOueueWithBlock:(void(^)(id object, BOOL *stop))block;

/**
 Dequeues the queue objects while calling block, until it reaches targetObject
 
 This method dequeues the target queue until it reaches the specified target 
 object. If the target object does not exist in the queue or the targetObject is
 nil or there are no objects in the target queue, then this method just 
 immediately exists, never calling the block. Otherwise this method calls the 
 block till it has dequeued the target object and executed the last block.
 
 @param targetObject the object you wish to dequeue to
 @param block a block with the object being dequeued as an argument
 */
-(void)dequeueToObject:(id)targetObject withBlock:(void(^)(id object))block;

/**
 Enumerates over the objects in the receiving queues storage in order
 
 Enumerates over the receiving queues objects in order. Each time the block is 
 called it gives you a reference to the object in the queue currently being
 enumerated over.
 */
-(void)enumerateObjectsInQueue:(void(^)(id object, BOOL *stop))block;

/**
 Allows you to view the head object without dequeueing it
 
 @return the object at the head of the queue
 */
-(id)peek;

/**
 Returns a BOOL value if the object passed in exists in the queue
 
 If the passed in object is non nil then this method queries the internal
 storage and returns a bool if the object is contained in the queue instance.
 
 @param object an object you wish to query if it exists in the queue instance
 @return a BOOL with YES if the object is in the queue or NO if it isn't
 */
-(BOOL)containsObject:(id)object;

/**
 Returns a BOOL value with the result of using the block on the queue data
 
 This method calls the block passing in an object in the receiving queue. When
 any block returns a YES result instead of NO then this method stops enumerating
 over the qeueue and returns the result. Otherwise all the queue is enumerated 
 over and the final result is returned. This method allows better inspection of
 all objects in the queue.
 
 @param block passes an id obj argument and returns a BOOL if obj matches
 @return a BOOL value with YES if the block at any time 
 */
-(BOOL)containsObjectWithBlock:(BOOL (^)(id obj))block;

/**
 Returns a NSUInteger with the Queues object count
 
 @return a NSUInteger with the receing Queues object count
 */
-(NSUInteger)count;

/**
 Returns a BOOL indicating if the queue is empty
 
 @return Returns YES if the queue object count is 0, otherwise it returns NO.
 */
-(BOOL)isEmpty;

/**
 Returns a BOOL indicating if aQueue is equal to the receiving queue
 
 @return a BOOL if the queues are equal
 */
-(BOOL)isEqualToQueue:(CWQueue *)aQueue;

@end
