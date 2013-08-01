/*
//  CWStack.m
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

#import "CWStack.h"
#import <libkern/OSAtomic.h>

@interface CWStack()
@property(nonatomic, strong) NSMutableArray *dataStore;
@property(nonatomic, assign) dispatch_queue_t queue;
@end

static int64_t queueCounter = 0;

@implementation CWStack

/**
 Initializes an empty stack
 
 @return a empty CWStack instance
 */
- (id)init {
    self = [super init];
    if (self == nil) return nil;
	
	_dataStore = [[NSMutableArray alloc] init];
	const char *label = [[NSString stringWithFormat:@"com.Zangetsu.CWStack_%lli",
						  OSAtomicIncrement64(&queueCounter)] UTF8String];
	_queue = dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL);
	
    return self;
}

-(id)initWithObjectsFromArray:(NSArray *)objects {
	self = [super init];
	if (self == nil) return nil;
	
	_dataStore = [[NSMutableArray alloc] init];
	const char *label = [[NSString stringWithFormat:@"com.Zangetsu.CWStack_%lli",
						  OSAtomicIncrement64(&queueCounter)] UTF8String];
	_queue = dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL);
	if (objects.count > 0) [_dataStore addObjectsFromArray:objects];
	
	return self;
}

-(void)push:(id)object {
	__typeof(self) __weak wself = self;
	dispatch_async(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		if (object) [sself.dataStore addObject:object];
	});
}

-(id)pop {
	__block id object = nil;
	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		if (sself.dataStore.count > 0) {
			object = [sself.dataStore lastObject];
			[sself.dataStore removeLastObject];
		}
	});
	return object;
}

-(NSArray *)popToObject:(id)object {
	if (![self.dataStore containsObject:object]) return nil;
	
	NSMutableArray *poppedObjects = [NSMutableArray array];
	id currentObject = nil;
	while (![self.topOfStackObject isEqual:object]) {
		currentObject = [self pop];
		[poppedObjects addObject:currentObject];
	}
	return poppedObjects;
}

-(void)popToObject:(id)object withBlock:(void (^)(id obj))block {
	if (![self.dataStore containsObject:object]) return;
	
	while (![self.topOfStackObject isEqual:object]) {
		id obj = [self pop];
		block(obj);
	}
}

-(NSArray *)popToBottomOfStack {
	if(self.dataStore.count == 0) return nil;
	return [self popToObject:self.dataStore[0]];
}

-(id)topOfStackObject {
	__block id object = nil;
	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		if(sself.dataStore.count == 0) return;
		object = [sself.dataStore lastObject];
	});
	return object;
}

-(id)bottomOfStackObject {
	__block id object = nil;
	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		if (sself.dataStore.count == 0) return;
		object = sself.dataStore[0];
	});
	return object;
}

-(void)clearStack {
	__typeof(self) __weak wself = self;
	dispatch_async(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		[sself.dataStore removeAllObjects];
	});
}

-(BOOL)isEqualToStack:(CWStack *)aStack {
	__block BOOL isEqual = NO;
	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		isEqual = [aStack.dataStore isEqual:sself.dataStore];
	});
	return isEqual;
}

-(BOOL)containsObject:(id)object {
	__block BOOL contains = NO;
	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		contains = [sself.dataStore containsObject:object];
	});
	return contains;
}

-(BOOL)containsObjectWithBlock:(BOOL (^)(id object))block {
	__block BOOL contains = NO;
	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		NSUInteger index = [sself.dataStore indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
			return block(obj);
		}];
		if (index != NSNotFound) contains = YES;
	});
	return contains;
}

/**
 returns a NSString with the contents of the stack
 
 @return a NSString object with the description of the stack contents
 */
-(NSString *)description {
	__block NSString *stackDescription = nil;
	__typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		stackDescription = [sself.dataStore description];
	});
	return stackDescription;
}

-(BOOL)isEmpty {
    __block BOOL empty;
    __typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		empty = (sself.dataStore.count <= 0);
	});
	return empty;
}

-(NSInteger)count {
    __block NSInteger theCount = 0;
    __typeof(self) __weak wself = self;
	dispatch_sync(self.queue, ^{
		__typeof(wself) __strong sself = wself;
		theCount = sself.dataStore.count;
	});
	return theCount;
}

-(void)dealloc {
	dispatch_release(_queue);
}

@end
