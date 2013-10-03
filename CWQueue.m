/*
//  CWQueue.m
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
 
#import "CWQueue.h"
#import <libkern/OSAtomic.h>

@interface CWQueue()
//private internal ivar
@property(nonatomic, copy) NSMutableArray *dataStore;
@property(nonatomic, assign) dispatch_queue_t queue;
@end

static int64_t queueCounter = 0;

@implementation CWQueue

/**
 Note on the usage of dispatch_barrier_sync(_storageQueue, ^{ });
 these are synchronization points. Anytime a "batch operation" ie
 a method that alters more than 1 object in the queue appears then
 these are needed to ensure that all operations before that point
 complete and any ones at the end of the method ensure that all
 operations enqueued complete before going on.
 */

#pragma mark Initiailziation -

/**
 Initializes a CWQueue object with no contents
 
 Initializes & returns an empty CWQueue object ready to
 accept objects to be added to it.
 
 @return a CWQueue object ready to accept objects to be added to it.
 */
-(instancetype)init {
	self = [super init];
	if (self == nil) return nil;
	
	_dataStore = [NSMutableArray array];
	const char *label = [[NSString stringWithFormat:@"com.Zangetsu.CWStack_%lli",
						  OSAtomicIncrement64(&queueCounter)] UTF8String];
	_queue = dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL);
	
	return self;
}

-(instancetype)initWithObjectsFromArray:(NSArray *)array {
	self = [super init];
	if (self == nil) return nil;
	
	_dataStore = [NSMutableArray arrayWithArray:array];
	const char *label = [[NSString stringWithFormat:@"com.Zangetsu.CWStack_%lli",
						  OSAtomicIncrement64(&queueCounter)] UTF8String];
	_queue = dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL);
	
	return self;
}

#pragma mark Add & Remove Objects -

-(id)dequeue {
	__block id object = nil;
	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		if (sself.dataStore.count == 0) return;
		object = sself.dataStore[0];
		[sself.dataStore removeObjectAtIndex:0];
	});
	return object;
}

-(void)enqueue:(id)object {
	if (object == nil) return;

	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		[sself.dataStore addObject:object];
	});
}

-(void)enqueueObjectsFromArray:(NSArray *)objects {
	if(objects.count == 0) return;

	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		[sself.dataStore addObjectsFromArray:objects];
	});
}

-(void)removeAllObjects {
	__typeof(self) __weak wself = self;
	dispatch_async(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		[sself.dataStore removeAllObjects];
	});
}

#pragma mark Query Methods -

-(BOOL)containsObject:(id)object {
	__block BOOL contains = NO;
	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		contains = [sself.dataStore containsObject:object];
	});
	return contains;
}

-(BOOL)containsObjectWithBlock:(BOOL (^)(id obj))block {
	__block BOOL contains = NO;
	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		NSUInteger index = [sself.dataStore indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
			return block(obj);
		}];
		contains = (index != NSNotFound);
	});
	return contains;
}

-(id)peek {
	__block id object = nil;
	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		if (sself.dataStore.count >= 1) {
			object = sself.dataStore[0];
		}
	});
	return object;
}

#pragma mark Enumeration Methods -

-(void)enumerateObjectsInQueue:(void(^)(id object, BOOL *stop))block {
	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		BOOL shouldStop = NO;
		for (id object in sself.dataStore) {
			block(object,&shouldStop);
			if (shouldStop) return;
		}
	});
}

-(void)dequeueOueueWithBlock:(void(^)(id object, BOOL *stop))block {
	if(self.dataStore.count == 0) return;
	
	BOOL shouldStop = NO;
	id dequeuedObject = nil;
	do {
		dequeuedObject = [self dequeue];
		if(dequeuedObject){
			block(dequeuedObject,&shouldStop);
		}
	} while ((shouldStop == NO) && (dequeuedObject));
}

-(void)dequeueToObject:(id)targetObject 
			 withBlock:(void(^)(id object))block {
	if (![self.dataStore containsObject:targetObject]) return;
	[self dequeueOueueWithBlock:^(id object, BOOL *stop) {
		block(object);
		if ([object isEqual:targetObject]) *stop = YES;
	}];
}

#pragma mark Debug Information -

/**
 Returns an NSString with a description of the queues storage
 
 @return a NSString detailing the queues internal storage
 */
-(NSString *)description {
	__block NSString *queueDescription = nil;
	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		queueDescription = [sself.dataStore description];
	});
	return queueDescription;
}

-(NSUInteger)count {
	__block NSUInteger queueCount = 0;
	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		queueCount = sself.dataStore.count;
	});
	return queueCount;
}

-(BOOL)isEmpty {
	__block BOOL queueEmpty = YES;
	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		queueEmpty = (sself.dataStore.count == 0);
	});
	return queueEmpty;
}

#pragma mark Comparison -

-(BOOL)isEqualToQueue:(CWQueue *)aQueue {
	__block BOOL isEqual = NO;
	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		isEqual = [sself.dataStore isEqual:aQueue.dataStore];
	});
	return isEqual;
}

-(void)dealloc {
	dispatch_release(_queue);
	_queue = nil;
}

@end
