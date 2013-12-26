/*
//  CWStackTests.m
//  Zangetsu
//
//  Created by Colin Wheeler on 5/30/11.
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

//so we can test subscript access
#ifndef CWSTACK_PEEKING
#define CWSTACK_PEEKING
#endif

#import "CWStack.h"

//TODO: these unit tests can be improved a lot more

SpecBegin(CWStackTests)

describe(@"-push", ^{
	it(@"should add objects to the stack", ^{
		NSArray *array = @[ @"This", @"is", @"a", @"sentence" ];
		CWStack *stack = [[CWStack alloc] init];
		
		[stack push:array[0]];
		expect(stack.count == 1).to.beTruthy();
		expect(stack.topOfStackObject).to.equal(@"This");
		
		[stack push:array[1]];
		expect(stack.count == 2).to.beTruthy();
		expect(stack.topOfStackObject).to.equal(@"is");
		
		[stack push:array[2]];
		expect(stack.count == 3).to.beTruthy();
		expect(stack.topOfStackObject).to.equal(@"a");
		
		[stack push:array[3]];
		expect(stack.count == 4).to.beTruthy();
		expect(stack.topOfStackObject).to.equal(@"sentence");
	});
	
	it(@"should not accept pushing nil onto the stack", ^{
		CWStack *testStack = [[CWStack alloc] initWithObjectsFromArray:@[ @"Nibbler" ]];
		expect(testStack.count == 1).to.beTruthy();
		expect(testStack.topOfStackObject).to.equal(@"Nibbler");
		
		[testStack push:nil];
		expect(testStack.count == 1).to.beTruthy();
		expect(testStack.topOfStackObject).to.equal(@"Nibbler");
	});
});

describe(@"-popToObject:withBlock:", ^{
	it(@"should pop objects in the sequence expected", ^{
		NSArray *array = @[ @"This", @"is", @"a", @"sentence" ];
		CWStack *stack = [[CWStack alloc] initWithObjectsFromArray:array];
		__block NSInteger index = 0;
		
		[stack popToObject:@"This" withBlock:^(id obj) {
			if (index == 0) {
				expect(obj).to.equal(@"sentence");
			} else if (index == 1) {
				expect(obj).to.equal(@"a");
			} else if (index == 2) {
				expect(obj).to.equal(@"is");
			} else {
				XCTFail(@"We have enumerated past the expected bounds");
			}
			index++;
		}];
	});
});

#ifdef CWSTACK_PEEKING
describe(@"subscript access aka peeking", ^{
    CWStack *stack = [[CWStack alloc] initWithObjectsFromArray:@[@1,@2,@3,@4,@5]];
    
    it(@"should access the correct elements", ^{
        expect(stack[0]).to.equal(@1);
    });
});
#endif

describe(@"-clearStack", ^{
	it(@"should clear all the objects off a stack", ^{
		CWStack *stack1 = [[CWStack alloc] initWithObjectsFromArray:@[@"one",@"and",@"two"]];
		
		expect(stack1.count == 3).to.beTruthy();
		
		[stack1 clearStack];
		
		expect(stack1.count == 0).to.beTruthy();
        
        CWStack *emptyStack = [[CWStack alloc] init];
        
		expect([stack1 isEqualToStack:emptyStack]).to.beTruthy();
	});
});

describe(@"bottomOfStackObject", ^{
	it(@"should find the correct object at the bottom of a stack", ^{
		CWStack *stack = [[CWStack alloc] initWithObjectsFromArray:@[@"This",@"is",@"a",@"sentence"]];
		expect(stack.bottomOfStackObject).to.equal(@"This");
	});
	
	it(@"should return nil when there are no objects on the stack", ^{
		CWStack *stack = [CWStack new];
		expect(stack.bottomOfStackObject).to.beNil();
	});
});

describe(@"topOfStackObject", ^{
	it(@"should find the correct object at the top of a stack", ^{
		CWStack *stack = [[CWStack alloc] initWithObjectsFromArray:@[@"This",@"is",@"a",@"sentence"]];
		expect(stack.topOfStackObject).to.equal(@"sentence");
	});
	
	it(@"should return nil when there are no objects on the stack", ^{
		CWStack *stack = [CWStack new];
		expect(stack.topOfStackObject).to.beNil();
	});
});

describe(@"-popToBottomOfStack", ^{
	it(@"should pop all objects except the bottom object off the stack", ^{
		CWStack *stack = [[CWStack alloc] initWithObjectsFromArray:@[@"This",@"is",@"a",@"sentence"]];
		
		expect(stack.count == 4).to.beTruthy();
		
		[stack popToBottomOfStack];
		
		expect(stack.count == 1).to.beTruthy();
		
		CWStack *stack2 = [[CWStack alloc] initWithObjectsFromArray:@[@"This"]];
		
		expect([stack isEqualToStack:stack2]).to.beTruthy();
	});
});

describe(@"-popToObject", ^{
	it(@"should return nil for non existant objects", ^{
		CWStack *stack = [[CWStack alloc] initWithObjectsFromArray:@[@"Bender"]];
		NSArray *results = [stack popToObject:@"Zapf"];
		
		expect(results).to.beNil();
	});
});

describe(@"-isEmpty", ^{
	it(@"should correctly return when the stack is empty", ^{
		CWStack *stack = [CWStack new];
		
		expect(stack.isEmpty).to.beTruthy();
		
		[stack push:@"All Glory to the Hypnotoad"];
		
		expect(stack.isEmpty).to.beFalsy();
	});
});

describe(@"-containsObject", ^{
	it(@"should correctly return when the stack does contain an object", ^{
		CWStack *stack = [[CWStack alloc] initWithObjectsFromArray:@[@"Hello",@"World"]];
		
		expect([stack containsObject:@"Hello"]).to.beTruthy();
		expect([stack containsObject:@"Planet Express"]).to.beFalsy();
	});
});

describe(@"-containsObjectWithBlock", ^{
	it(@"should correctly return if an object says the stack contains an object", ^{
		CWStack *stack = [[CWStack alloc] initWithObjectsFromArray:@[@"Hello",@"World"]];
		BOOL result = [stack containsObjectWithBlock:^BOOL(id object) {
			if ([(NSString *)object isEqualToString:@"World"]) return YES;
			return NO;
		}];
		
		expect(result).to.beTruthy();
		
		BOOL result2 = [stack containsObjectWithBlock:^BOOL(id object) {
			if ([(NSString *)object isEqualToString:@"Hypnotoad"]) return YES;
			return NO;
		}];
		
		expect(result2).to.beFalsy();
	});
});

it(@"should be able to serialize work being done concurrently", ^{
	CWStack *stack = [[CWStack alloc] init];

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		[stack push:@"2"];
	});
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[stack push:@"1"];
	});
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		[stack push:@"3"];
	});
	
	expect(stack.count == 3).will.beTruthy();
	expect([stack containsObject:@"1"]).to.beTruthy();
	expect([stack containsObject:@"2"]).to.beTruthy();
	expect([stack containsObject:@"3"]).to.beTruthy();
});

SpecEnd
