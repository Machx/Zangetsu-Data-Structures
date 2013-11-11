/*
//  CWFixedQueue.m
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

#import "CWFixedQueue.h"

#define kCWFixedQueueDefaultCapacity 50

@interface CWFixedQueue()
@property(strong) NSMutableArray *storage;
@end

@implementation CWFixedQueue

-(instancetype)initWithCapacity:(NSUInteger)capacity {
	self = [super init];
	if (self == nil) return nil;
	
	_storage = [NSMutableArray array];
	_capacity = capacity;
	_evictionBlock = nil;
	
	return self;
}

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;
	
	_storage = [NSMutableArray array];
	_capacity = kCWFixedQueueDefaultCapacity;
	_evictionBlock = nil;
	
    return self;
}

#pragma mark Debugging -

-(NSString *)description {
	return [NSString stringWithFormat:@"%@: Label: %@\nItem Count: %lu\nCapacity: %lu\nItems: %@",
			NSStringFromClass([self class]),
			self.label,
			(unsigned long)self.count,
			(unsigned long)self.capacity,
			self.storage];
}

-(NSUInteger)count {
	return self.storage.count;
}

#pragma mark Objective-C Object Subscript Methods -

-(id)objectAtIndexedSubscript:(NSUInteger)index {
	CWAssert(index <= (self.storage.count - 1));
	return [self.storage objectAtIndexedSubscript:index];
}

-(void)setObject:(id)object atIndexedSubscript:(NSUInteger)idx {
	CWAssert(object != nil);
	CWAssert(idx <= (self.storage.count - 1));
	[self.storage setObject:object
		 atIndexedSubscript:idx];
}

#pragma mark Enqueue & Dequeue -

-(void)enqueue:(id)object {
	if(object == nil) return;
	if (![self.storage containsObject:object]) {
		[self.storage addObject:object];
		[self clearExcessObjects];
	} else {
		NSUInteger objectIndex = [self.storage indexOfObject:object];
		[self.storage removeObjectAtIndex:objectIndex];
		[self.storage addObject:object];
	}
}

-(void)enqueueObjectsInArray:(NSArray *)array {
	CWAssert(array != nil);
	if(array.count == 0) return;
	[self.storage addObjectsFromArray:array];
	[self clearExcessObjects];
}

-(void)clearExcessObjects {
	while (self.storage.count > self.capacity) {
		if (self.evictionBlock) self.evictionBlock(self.storage[0]);
		[self.storage removeObjectAtIndex:0];
	}
}

-(id)dequeue {
	if(self.storage.count == 0) return nil;
	id dequeuedObject = self.storage[0];
	[self.storage removeObjectAtIndex:0];
	return dequeuedObject;
}

#pragma mark Enumeration -

-(void)enumerateObjectsUsingBlock:(void (^)(id object, NSUInteger index, BOOL *stop))block {
	CWAssert(block != nil);
	[self.storage enumerateObjectsUsingBlock:block];
}

-(void)enumerateObjectsWithOptions:(NSEnumerationOptions)options
						usingBlock:(void (^)(id object, NSUInteger index, BOOL *stop))block {
	CWAssert(block != nil);
	[self.storage enumerateObjectsWithOptions:options
								   usingBlock:block];
}

@end
