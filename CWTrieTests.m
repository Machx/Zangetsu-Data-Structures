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

SpecBegin(CWTrie)

it(@"should store and retreieve a object", ^{
    CWTrie *trie = [[CWTrie alloc] init];
    
    [trie setObjectValue:@"World!" forKey:@"Hello"];
    
    expect([trie objectValueForKey:@"Hello"]).to.equal(@"World!");
});

it(@"should return nil for objects it doesn't contain", ^{
    CWTrie *trie = [[CWTrie alloc] init];
    
    expect([trie objectValueForKey:@"Hypnotoad"]).to.beNil();
});

describe(@"case sensitive", ^{
    it(@"should return different values if case sensitive", ^{
        CWTrie *trie = [[CWTrie alloc] initWithCaseSensitiveKeys:YES];
        
        [trie setObjectValue:@5 forKey:@"Yes"];
        [trie setObjectValue:@4 forKey:@"yes"];
        
        expect([trie objectValueForKey:@"Yes"]).to.equal(@5);
        expect([trie objectValueForKey:@"yes"]).to.equal(@4);
    });
    
    it(@"should return the same value if not case sensitive", ^{
        CWTrie *trie = [[CWTrie alloc] initWithCaseSensitiveKeys:NO];
        
        [trie setObjectValue:@5 forKey:@"Yes"];
        [trie setObjectValue:@4 forKey:@"yes"];
        
        expect([trie objectValueForKey:@"yes"]).to.equal(@4);
    });
});

describe(@"-containsKey", ^{
    it(@"should detect if a key has been set", ^{
        CWTrie *trie = [CWTrie new];
        
        expect([trie containsKey:@"Hypnotoad"]).to.beFalsy();
        
        [trie setObjectValue:@4 forKey:@"Hypnotoad"];
        
        expect([trie containsKey:@"Hypnotoad"]).to.beTruthy();
    });
    
    it(@"should detect when a node exists, but not a stored value", ^{
        /*
         This detects that there is a stored value in a node and not that the
         node simply exists. I.e. If we set the key "hello" we should be able to
         detect that the nodes for "he" exist, but that there is no stored value
         which corresponds to that key
         */
        CWTrie *trie = [CWTrie new];
        
        [trie setObjectValue:@4 forKey:@"hello"];
        
        expect([trie containsKey:@"he"]).to.beFalsy();
        expect([trie containsKey:@"hello"]).to.beTruthy();
    });
});

describe(@"cache tests", ^{
    it(@"make sure the correct result is returned after using containsKey", ^{
        CWTrie *trie = [CWTrie new];
        
        [trie setObjectValue:@4 forKey:@"Hypnotoad"];
        
        //-containsKey should store the value @4 in the cache
        /* normally you'd use this like
         if([trie containsKey:key]) {
         id value = [trie objectValueForKey:key];
         }*/
        expect([trie containsKey:@"Hypnotoad"]).to.beTruthy();
        expect([trie objectValueForKey:@"Hypnotoad"]).to.equal(@4);
    });
});

SpecEnd
