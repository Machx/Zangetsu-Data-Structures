/*
//  CWQueueTests.m
//  Zangetsu
//
//  Created by Colin Wheeler on 10/30/11.
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

#import "CWQueueTests.h"
#import "CWQueue.h"

SpecBegin(CWQueue)

describe(@"-addObjectsFromArray", ^{
	it(@"should add objects from an array just as if it was enqueueing them", ^{
		NSArray *array1 = @[ @"Cheeze it!" ];
		NSArray *array2 = @[ @"Why not Zoidberg?" ];
		
		CWQueue *queue1 = [[CWQueue alloc] initWithObjectsFromArray:array1];
		CWQueue *queue2 = [[CWQueue alloc] init];
		
		expect([queue1 isEqualToQueue:queue2]).to.beFalsy();
		
		[queue2 enqueueObjectsFromArray:array1];
		
		expect([queue1 isEqualToQueue:queue2]).to.beTruthy();
		
		[queue1 enqueueObjectsFromArray:array2];
		[queue2 enqueueObjectsFromArray:array2];
		
		expect([queue1 isEqualToQueue:queue2]).to.beTruthy();
	});
});

describe(@"-containsObject", ^{
	it(@"should correclty return when it contains a given object", ^{
		CWQueue *queue = [[CWQueue alloc] initWithObjectsFromArray:@[ @"Hypnotoad",@"Bender",@"Cheeze it!" ]];
		
		expect([queue containsObject:@"Bender"]).to.beTruthy();
		expect([queue containsObject:@"Cthulhu"]).to.beFalsy();
	});
});

describe(@"-containsObjectWithBlock", ^{
	it(@"should correctly return when it contains a given object using a block", ^{
		CWQueue *queue = [[CWQueue alloc] initWithObjectsFromArray:@[ @"Hypnotoad",@"Bender",@"Cheeze it!" ]];
		BOOL result = [queue containsObjectWithBlock:^BOOL(id obj) {
			if ([(NSString *)obj isEqualToString:@"Bender"]) return YES;
			return NO;
		}];
		
		expect(result).to.beTruthy();
		
		BOOL result2 = [queue containsObjectWithBlock:^BOOL(id obj) {
			if ([(NSString *)obj isEqualToString:@"Cthulhu"]) return YES;
			return NO;
		}];
		
		expect(result2).to.beFalsy();
	});
});

describe(@"-count", ^{
	it(@"should always return the correct count of objects on the queue", ^{
		CWQueue *queue = [CWQueue new];
		
		expect(queue.count == 0).to.beTruthy();
		[queue enqueue:@" "];
		expect(queue.count == 1).to.beTruthy();
		[queue enqueue:@" "];
		expect(queue.count == 2).to.beTruthy();
		[queue dequeue];
		expect(queue.count == 1).to.beTruthy();
		[queue dequeue];
		expect(queue.count == 0).to.beTruthy();
	});
});

describe(@"-dequeue", ^{
	it(@"should dequeue items in order", ^{
		CWQueue *queue = [[CWQueue alloc] init];
		[queue enqueue:@"First"];
		[queue enqueue:@"Second"];
		[queue enqueue:@"Third"];
		[queue enqueue:@"Fourth"];
		
		expect([queue dequeue]).to.equal(@"First");
		[queue enqueue:@"Fifth"];
		expect([queue dequeue]).to.equal(@"Second");
		[queue enqueue:@"Sixth"];
		expect([queue dequeue]).to.equal(@"Third");
		[queue enqueue:@"Seventh"];
		expect([queue dequeue]).to.equal(@"Fourth");
		[queue enqueue:@"Eighth"];
		expect([queue dequeue]).to.equal(@"Fifth");
		expect([queue dequeue]).to.equal(@"Sixth");
		expect([queue dequeue]).to.equal(@"Seventh");
		expect([queue dequeue]).to.equal(@"Eighth");
	});
	
	it(@"should dequeue nil when there are no more objects on the queue", ^{
		CWQueue *queue = [[CWQueue alloc] init];
		
		expect([queue dequeue]).to.beNil();
		
		[queue enqueue:@"Fishy Joes"];
		
		expect([queue count] == 1).to.beTruthy();
		expect([queue dequeue]).notTo.beNil();
		expect([queue dequeue]).to.beNil();
	});
});

describe(@"-dequeueToObject", ^{
	it(@"should correctly dequeue till it reaches a given object", ^{
		NSString *ob1 = @"Fry";
		NSString *ob2 = @"Leela";
		NSString *ob3 = @"Bender";
		
		CWQueue *queue = [[CWQueue alloc] init];
		[queue enqueue:ob1];
		[queue enqueue:ob2];
		[queue enqueue:ob3];
		[queue dequeueToObject:ob2 withBlock:^(id object) { }];
		
		CWQueue *goodQueue = [[CWQueue alloc] initWithObjectsFromArray:@[ @"Bender" ]];
		
		expect([goodQueue isEqualToQueue:queue]).to.beTruthy();
	});
});

describe(@"-dequeueWithBlock", ^{
	it(@"should dequeue using a block in the correct order", ^{
		CWQueue *queue = [[CWQueue alloc] initWithObjectsFromArray:@[ @"Hypnotoad",@"Bender",@"Cheeze it!" ]];
		
		__block NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:3];
		[queue dequeueOueueWithBlock:^(id object, BOOL *stop) {
			[results addObject:object];
		}];
		
		NSArray *goodResultArray = @[ @"Hypnotoad",@"Bender",@"Cheeze it!" ];
		
		expect(goodResultArray).to.equal(results);
		expect([queue dequeue]).to.beNil();
	});
	
	it(@"should stop enumerating when the stop pointer is set to YES", ^{
		CWQueue *queue = [[CWQueue alloc] initWithObjectsFromArray:@[ @"Hypnotoad",@"Bender",@"Cheeze it!" ]];
		
		[queue dequeueOueueWithBlock:^(id object, BOOL *stop) {
			if ([(NSString *)object isEqualToString:@"Bender"]) *stop = YES;
		}];
		
		CWQueue *goodQueue = [[CWQueue alloc] initWithObjectsFromArray:@[ @"Cheeze it!" ]];
		
		expect([goodQueue isEqualToQueue:queue]).to.beTruthy();
	});
});

describe(@"-enumerateObjectsInQueue", ^{
	it(@"should enumerate objects in order", ^{
		CWQueue *queue = [[CWQueue alloc] initWithObjectsFromArray:@[ @"1",@"2",@"3",@"4",@"5" ]];
		__block NSUInteger index = 0;
		[queue enumerateObjectsInQueue:^(id object, BOOL *stop) {
			index++;
			if (index == 1) {
				expect(object).to.equal(@"1");
			} else if (index == 2) {
				expect(object).to.equal(@"2");
			} else if (index == 3) {
				expect(object).to.equal(@"3");
			} else if (index == 4) {
				expect(object).to.equal(@"4");
			} else if (index == 5) {
				expect(object).to.equal(@"5");
			} else {
				STFail(@"should not reach here");
			}
		}];
	});
	
	it(@"should stop when the stop pointer is set to YES", ^{
		CWQueue *queue = [[CWQueue alloc] initWithObjectsFromArray:@[ @"1",@"2",@"3",@"4",@"5" ]];
		
		__block NSUInteger count = 0;
		[queue enumerateObjectsInQueue:^(id object, BOOL *stop) {
			count++;
			if ([(NSString *)object isEqualToString:@"4"]) *stop = YES;
		}];
		
		expect(count == 4).to.beTruthy();
	});
});

describe(@"-enqueue", ^{
	it(@"shoudn't enqueue nil", ^{
		CWQueue *queue = [[CWQueue alloc] init];
		
		expect([queue count] == 0).to.beTruthy();
		
		id obj = nil;
		[queue enqueue:obj];
		
		expect([queue count] == 0).to.beTruthy();
		
		NSArray *anArray = [[NSArray alloc] init];
		[queue enqueueObjectsFromArray:anArray];
		
		expect([queue count] == 0).to.beTruthy();
	});
});

describe(@"-isEmpty", ^{
	it(@"should correctly return when a queue is empty", ^{
		CWQueue *queue = [CWQueue new];
		
		expect(queue.isEmpty).to.beTruthy();
		
		[queue enqueue:@"Test"];
		expect(queue.isEmpty).to.beFalsy();
		[queue enqueue:@"Test"];
		expect(queue.isEmpty).to.beFalsy();
		[queue dequeue];
		expect(queue.isEmpty).to.beFalsy();
		[queue dequeue];
		
		expect(queue.isEmpty).to.beTruthy();
	});
});

describe(@"-isEqualToQueue", ^{
	it(@"should correclty return if it is equal to another queue", ^{
		NSArray *array = @[ @"Hypnotoad" ];
		CWQueue *queue1 = [[CWQueue alloc] initWithObjectsFromArray:array];
		CWQueue *queue2 = [[CWQueue alloc] initWithObjectsFromArray:array];
		
		expect([queue1 isEqualToQueue:queue2]).to.beTruthy();
		
		CWQueue *queue3 = [[CWQueue alloc] initWithObjectsFromArray:@[ @"Nibbler" ]];
		
		expect([queue3 isEqualToQueue:queue1]).to.beFalsy();
	});
});

it(@"should serialize multithreaded access", ^{
	CWQueue *queue = [[CWQueue alloc] init];
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		[queue enqueue:@"Hello"];
	});
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[queue enqueue:@" World"];
	});
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		[queue enqueue:@"!"];
	});
	
	expect(queue.count == 3).will.beTruthy();
	expect([queue containsObject:@"Hello"]).to.beTruthy();
	expect([queue containsObject:@" World"]).to.beTruthy();
	expect([queue containsObject:@"!"]).to.beTruthy();
});

SpecEnd
