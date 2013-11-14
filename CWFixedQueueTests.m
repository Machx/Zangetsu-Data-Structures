/*
//  CWFixedQueueTests.m
//  Zangetsu
//
//  Created by Colin Wheeler on 9/11/12.
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

#import "CWFixedQueueTests.h"
#import "CWFixedQueue.h"

SpecBegin(CWFixedQueue)

it(@"should enqueue & dequeue objects as expected", ^{
	CWFixedQueue *queue = [CWFixedQueue new];
	queue.capacity = 2;
	
	expect(queue.count == 0).to.beTruthy();
	
	[queue enqueue:@"Good"];
	expect(queue.count == 1).to.beTruthy();
	
	[queue enqueue:@"News"];
	expect(queue.count == 2).to.beTruthy();
	
	[queue enqueue:@"Everybody!"];
	expect(queue.count == 2).to.beTruthy();
	
	[queue enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
		if (index == 0) {
			expect(object).to.equal(@"News");
		} else if (index == 1) {
			expect(object).to.equal(@"Everybody!");
		} else {
			XCTFail(@"enumerated past bounds");
		}
	}];
	
	expect([queue dequeue]).to.equal(@"News");
	expect([queue dequeue]).to.equal(@"Everybody!");
	//Test that queue.count == 0 on dequeue returns nil
	expect([queue dequeue]).to.beNil();
});

describe(@"-enqueueObjectsFromArray", ^{
	it(@"should enqueue objects from an array as expected", ^{
		CWFixedQueue *queue = [CWFixedQueue new];
		queue.capacity = 2;
		
		[queue enqueueObjectsInArray:@[ @"Nope",@"Everybody Watch",@"Hypnotoad" ]];
		expect(queue.count == 2).to.beTruthy();
		
		[queue enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
			if (index == 0) {
				expect(object).to.equal(@"Everybody Watch");
			} else if (index == 1) {
				expect(object).to.equal(@"Hypnotoad");
			} else {
				XCTFail(@"Enumerated past bounds");
			}
		}];
	});
});

it(@"should work with object subscripting", ^{
	CWFixedQueue *queue = [CWFixedQueue new];
	queue.capacity = 2;
	[queue enqueueObjectsInArray:@[ @"Everybody Watch",@"Hypnotoad" ]];
	
	expect(queue[0]).to.equal(@"Everybody Watch");
	expect(queue[1]).to.equal(@"Hypnotoad");
	
	queue[0] = @"Obey";
	expect(queue[0]).to.equal(@"Obey");
});

it(@"should call the eviction block when evicting objects from the queue", ^{
	CWFixedQueue *queue = [CWFixedQueue new];
	queue.capacity = 2;
	
	__block BOOL everybodyWatchTrigger = NO;
	__block BOOL hypnotoadTrigger = NO;
	queue.evictionBlock = ^(id object) {
		if([(NSString *)object isEqualToString:@"Everybody Watch"]){
			everybodyWatchTrigger = YES;
		} else if([(NSString *)object isEqualToString:@"Hypnotoad"]){
			hypnotoadTrigger = YES;
		}
	};
	
	//should be at capacity
	[queue enqueueObjectsInArray:@[ @"Everybody Watch",@"Hypnotoad" ]];
	
	//overflow the queue by 2
	[queue enqueueObjectsInArray:@[ @"Bite my shiny metal ass", @"Im gonna get my own theme park" ]];
	
	expect(everybodyWatchTrigger).to.beTruthy();
	expect(hypnotoadTrigger).to.beTruthy();
});

describe(@"enumeration operations", ^{
	CWFixedQueue *queue = [CWFixedQueue new];
	queue.capacity = 2;
	[queue enqueueObjectsInArray:@[ @"Everybody Watch",@"Hypnotoad" ]];
	
	it(@"should enumerate contents in the order expected forward", ^{
		//test forward
		__block NSUInteger count = 0;
		[queue enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop) {
			if (count == 0) {
				expect(object).to.equal(@"Everybody Watch");
			} else if (count == 1) {
				expect(object).to.equal(@"Hypnotoad");
			} else {
				XCTFail(@"Enumerated past expected bounds");
			}
			++count;
		}];
	});
	
	it(@"should be able to enumerate contents concurrently", ^{
		__block int32_t count = 0;
		[queue enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id object, NSUInteger index, BOOL *stop) {
			if (count == 0) {
				expect(object).to.equal(@"Everybody Watch");
			} else if (count == 1) {
				expect(object).to.equal(@"Hypnotoad");
			} else {
				XCTFail(@"Enumerated past expected bounds");
			}
			OSAtomicIncrement32(&count);
		}];
	});
	
	it(@"should be able to enumerate in reverse", ^{
		__block NSUInteger count = 0;
		[queue enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id object, NSUInteger index, BOOL *stop) {
			if (count == 1) {
				expect(object).to.equal(@"Everybody Watch");
			} else if (count == 0) {
				expect(object).to.equal(@"Hypnotoad");
			} else {
				XCTFail(@"Enumerated past expected bounds");
			}
			++count;
		}];
	});
});

SpecEnd
