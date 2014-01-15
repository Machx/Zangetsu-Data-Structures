/*
 //  CWTrie.m
 //  Zangetsu Data Structures
 //
 //  Created by Colin Wheeler on 12/31/13.
 //  Copyright (c) 2013 Colin Wheeler. All rights reserved.
 //
 
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
#import <libkern/OSAtomic.h>
#import "CWAssertionMacros.h"

#define kCWTrieCacheLimit 2

#define CWTrieKey() self.caseSensitive ? [key UTF8String] : [[key uppercaseString] UTF8String]

@interface CWTrieNode : NSObject
@property(assign) char key;
@property(strong) id storedValue;
@property(copy) NSMutableSet *children;
@end

@implementation CWTrieNode

+(CWTrieNode *)nodeWithKey:(char)ch
                   andValue:(id)aVal {
    CWTrieNode *node = [self new];
    node.key = ch;
    node.storedValue = aVal;
    return node;
}

-(instancetype)init {
    self = [super init];
    if(!self) return nil;
    
    _key = (char)NULL;
    _storedValue = nil;
    _children = [NSMutableSet set];
    
    return self;
}

/**
 Creates a new node, sets its key to ch, adds the node to children & returns it
 
 This is a convenience method to help with adding keys in a trie
 
 @return the CWTrieNode added to the receivers children
 */
-(CWTrieNode *)setNodeForKeyValue:(char)ch {
    CWTrieNode *node = [CWTrieNode new];
    node.key = ch;
    [self.children addObject:node];
    return node;
}

/**
 Searches the nodes children for the value ch and returns it or nil
 
 @param ch the character value to search for in the children
 @return the node whose key is ch or nil if no such node could be found
 */
-(CWTrieNode *)nodeForKeyValue:(char)ch {
    CWTrieNode *result = nil;
    for (CWTrieNode *node in self.children) {
        if (node.key == ch) {
            result = node;
            break;
        }
    }
    return result;
}

@end

@interface CWTrie ()
@property(assign) BOOL caseSensitive;
@property(strong) CWTrieNode *root;
@property(strong) dispatch_queue_t queue;
@property(strong) NSCache *cache; //for holding the last value looked up by -containsKey
@end

static int64_t queue_counter = 0;

@implementation CWTrie

-(instancetype)init {
    self = [super init];
    if(!self) return self;
    
    _root = [CWTrieNode new];
    _caseSensitive = NO;
    _cache = [NSCache new];
    [_cache setCountLimit:kCWTrieCacheLimit];
    _queue = ({
        NSString *label = [NSString stringWithFormat:@"%@%lli",
                           NSStringFromClass([self class]),
                           OSAtomicIncrement64(&queue_counter)];
        dispatch_queue_t aQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
        aQueue;
    });
    
    return self;
}

-(instancetype)initWithCaseSensitiveKeys:(BOOL)caseSensitive {
    self = [super init];
    if(!self) return self;
    
    _root = [CWTrieNode new];
    _cache = [NSCache new];
    [_cache setCountLimit:kCWTrieCacheLimit];
    _caseSensitive = caseSensitive;
    _queue = ({
        NSString *label = [NSString stringWithFormat:@"%@%lli",
                           NSStringFromClass([self class]),
                           OSAtomicIncrement64(&queue_counter)];
        dispatch_queue_t aQueue = dispatch_queue_create([label UTF8String], DISPATCH_QUEUE_SERIAL);
        aQueue;
    });
    
    return self;
}

-(void)setObjectValue:(id)value
               forKey:(NSString *)key {
    CWAssert(value != nil);
    CWAssert((key != nil) && (key.length >= 1));
    
    __weak CWTrieNode *weakRoot = self.root;
    __weak NSCache *weakCache = self.cache;
    dispatch_async(self.queue, ^{
        const char *keyValue = CWTrieKey();
        CWTrieNode *search = weakRoot;
        NSCache *scache = weakCache;
        
        while (*keyValue) {
            char sc = *keyValue;
            CWTrieNode *nextNode = [search nodeForKeyValue:sc];
            search = nextNode ?: [search setNodeForKeyValue:sc];
            keyValue++;
        }
        search.storedValue = value;
        [scache setObject:value forKey:key];
    });
}

-(void)removeObjectValueForKey:(NSString *)key {
    CWAssert((key != nil) && (key.length >= 1));
    //remove object from cache if it exists
    [self.cache removeObjectForKey:key];
    /*
     this is slightly different than setObjectValue:forKey: as it stops upon
     encountering nil (in other words trying to remove a value for a key that
     doesn't exist in the trie instance.) If it reaches its intended node it
     sets the storedValue to nil, otherwise its just sending a message to nil.
     */
    __weak CWTrieNode *weakRoot = self.root;
    dispatch_async(self.queue, ^{
        const char *keyValue = CWTrieKey();
        CWTrieNode *search = weakRoot;
        while (*keyValue && (search != nil)) {
            search = [search nodeForKeyValue:*keyValue];
            keyValue++;
        }
        search.storedValue = nil;
    });
}

-(BOOL)containsKey:(NSString *)key {
    CWAssert((key != nil) && (key.length >= 1));
    
    __block BOOL contains = YES;
    __weak CWTrieNode *weakRoot = self.root;
    __weak CWTrie *weakSelf = self;
    dispatch_sync(self.queue, ^{
        CWTrie *sself = weakSelf;
        CWTrieNode *node = weakRoot;
        const char *theKey = CWTrieKey();
        while (*theKey) {
            node = [node nodeForKeyValue:*theKey];
            if(node == nil) {
                contains = NO;
                break;
            }
            theKey++;
        }
        /*
         we know that the key exists here in that we've enumerated over the
         chars in the string we were given and they exist, but that doesn't
         necessarily mean there is a node stored here. i.e. if someone stores
         an object for the key @"hello" does the key @"he" exist? the nodes for
         it exist but we need to check for a node value
         */
        if(node && (node.storedValue != nil)) {
            /* this is convenient so you can do
             if([trie containsKey:key]) {
             id obj = [trie objectValueForKey:key];
             ...
             }
             and we won't have to lookup the same value twice
             */
            [sself.cache setObject:node.storedValue forKey:key];
        } else {
            contains = NO;
        }
    });
    return contains;
}

-(id)objectValueForKey:(NSString *)key {
    CWAssert((key != nil) && (key.length >= 1));
    
    __block id result = nil;
    __weak CWTrieNode *wroot = self.root;
    __weak NSCache *weakCache = self.cache;
    
    dispatch_sync(self.queue, ^{
        NSCache *trieCache = weakCache;
        //check the cache first
        id obj = [trieCache objectForKey:key];
        if (obj) {
            result = obj;
            return;
        }
        
        //object not in the cache... do the normal search...
        CWTrieNode *node = wroot;
        const char *keystr = CWTrieKey();
        while (*keystr && (node != nil)) {
            node = [node nodeForKeyValue:*keystr];
            keystr++;
        }
        result = node.storedValue;
    });
    
    return result;
}

@end
