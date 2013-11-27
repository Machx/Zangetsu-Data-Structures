/*
//  CWTrieTests.m
//  Zangetsu
//
//  Created by Colin Wheeler on 4/15/12.
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

#import "CWTrie.h"

static CWTrie *trie = nil;

SpecBegin(CWTrie)

beforeAll(^{
	trie = [CWTrie new];
});

it(@"should be able to set & retrieve values for keys", ^{	
	NSString *aKey = @"Hello";
	NSString *aValue = @"World";
	[trie setObjectValue:aValue forKey:aKey];
	
	//find key that does exist
	NSString *foundValue = [trie objectValueForKey:aKey];
	expect(foundValue).to.equal(aValue);
	
	//return nil for key that doesn't exist
	expect([trie objectValueForKey:@"Foodbar"]).to.beNil();
	expect([trie objectValueForKey:nil]).to.beNil();
});

it(@"shouldn't distinguish between uppercase & lowercase if set to", ^{
	trie.caseSensitive = NO;
	[trie setObjectValue:@"Bender" forKey:@"Fry"];
	
	expect([trie objectValueForKey:@"Fry"]).to.equal(@"Bender");
	expect([trie objectValueForKey:@"FRY"]).to.equal(@"Bender");
	expect([trie objectValueForKey:@"fRy"]).to.equal(@"Bender");
});

describe(@"removing values", ^{
	it(@"should remove values for keys", ^{
		[trie setObjectValue:@"Bender" forKey:@"Fry"];
		
		expect([trie objectValueForKey:@"Fry"]).to.equal(@"Bender");
		
		[trie removeObjectValueForKey:@"Fry"];
		
		expect([trie objectValueForKey:@"Fry"]).to.beNil();
	});
	
	it(@"-removeObject... should have the same effect as setObjectValue:nil", ^{
		[trie setObjectValue:@42 forKey:@"MagicNumber"];
		
		expect([trie objectValueForKey:@"MagicNumber"]).to.equal(@42);
		
		[trie setObjectValue:nil forKey:@"MagicNumber"];
		
		expect([trie objectValueForKey:@"MagicNumber"]).to.beNil();
	});
});

SpecEnd
