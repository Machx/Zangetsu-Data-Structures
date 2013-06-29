
/*  CWPriorityQueue.h
//  Zangetsu Data Structures
//
//  Created by Colin Wheeler on 12/18/12.
//  Copyright (c) 2012 Colin Wheeler. All rights reserved.
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

#define kCWPriorityMax 0
#define kCWPriorityMin NSUIntegerMax

#import <Foundation/Foundation.h>

@interface CWPriorityQueue : NSObject

/**
 Adds the item to the queue and sorts all items by their priority
 
 The item is added to the Queue and then sorted by the priority it was given in
 this API. The lower an items number is the higher its priority is in the queue.
 
 @param item to be added to the queue
 @param priority this number is used to sort the item in the queue
 */
-(void)addItem:(id)item
  withPriority:(NSUInteger)priority;

/**
 Removes all objects on the queue from the queue instance
 */
-(void)removeAllObjects;

/**
 Returns the count of objects currently on the queue instance
 
 @return a NSUInteger with the count of objects contained in the receiving queue
 */
-(NSUInteger)count;

/**
 Returns the first item on the queue without removing it from the queue or nil
 
 If the queue has items in it then this method returns the first item to be
 dequeued. Otherwise if the queue is empty, this method will simply return nil.
 
 @return the first object to the dequeued from the queue or nil.
 */
-(id)peek;

/**
 Removes an item with the highest priority off the queue & returns it
 
 This method grabs a reference to the item with the highest priority on the
 queue (priority 0 or as close to it as there is), removes it from the queue
 and then returns it to you.
 
 @return the item with the highest priority (lowest #) or nil if queue is empty
 */
-(id)dequeue;

/**
 Dequeues all objects of the next priority level off the queue
 
 This method looks at what the highest priority is of items on the queue, and
 then dequeues all items of the same priority level. This removes all the items
 from the queue and returns them to you.
 
 @return a NSArray of all items matching the next highest priority level
 */
-(NSArray *)dequeueAllObjectsOfNextPriorityLevel;

/**
 Returns all objects that have a priority in the queue that matches the argument
 
 @return an NSArray of all objects matching the given priority, or an empty set
 */
-(NSArray *)allObjectsOfPriority:(NSUInteger)priority;

/**
 Returns the count of all objects in the Queue matching the given priority level
 
 @param priority the given priority level you want to get the count of objects
 @return a NSUInteger with the number of objects who have the given priority
 */
-(NSUInteger)countofObjectsWithPriority:(NSUInteger)priority;

@end
