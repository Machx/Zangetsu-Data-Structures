/*
//  CWTrie.m
//  Zangetsu
//
//  Created by Colin Wheeler on 4/15/12.
//  Copyright (c) 2012. All rights reserved.
//
 
 Copyright (c) 2012 Colin Wheeler
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "CWTrie.h"

#ifndef CWLog
#define CWLog(args...) NSLog(@"%s %i: %@",__PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:args]);
#endif

//Log = 1, no logging = 0
 #define CWTRIE_VERBOSE_LOGGING 1

@interface CWTrieNode : NSObject
@property(retain) NSString *key;
@property(retain) id value;
@property(retain) NSMutableSet *children;
@end

@implementation CWTrieNode

/**
 This should be the designated initializer 99.99% of the time
 */
- (id)initWithKey:(NSString *)nodeKey {
	self = [super init];
	if (self == nil) return nil;
	
	_key = nodeKey;
	_value = nil;
	_children = [NSMutableSet set];
	
	return self;
}

- (id)init {
    self = [super init];
    if (self == nil) return nil;
    
	_key = nil;
	_value = nil;
	_children = [NSMutableSet set];
	
	return self;
}

-(NSString *)description {
	return [NSString stringWithFormat:@"CWTrieNode (\nKey: '%@'\nValue: %@\nChildren: %@\n)",
			self.key,self.value,self.children];
}

@end

@interface CWTrie()
@property(retain) CWTrieNode *rootNode;
@end

@implementation CWTrie

- (id)init {
    self = [super init];
    if (self == nil) return nil;
	
	_rootNode = [[CWTrieNode alloc] init];
	_caseSensitive = YES;
	
    return self;
}

-(NSString *)description {
	return [NSString stringWithFormat:@"Trie (\nCase Sensitive: %@\nNodes: %@",
			(self.caseSensitive ? @"YES" : @"NO"),self.rootNode];
}

/**
 * Private API
 * Performs validation for node character lookups, and returns a BOOL
 * if the string passes as valid or not. If the character is not valid
 * this method will Log a reason why before exiting.
 *
 * @param character NSString to be examined for invalid states
 * @return YES if valid, NO if not
 */
BOOL CWTrieNodeHasErrorForCharacter(NSString *character) {
	if (character == nil) {
		#if CWTRIE_VERBOSE_LOGGING == 1
		CWLog(@"Character to be looked up is nil");
		#endif
		return YES;
	}
	if (character.length == 0) {
		#if CWTRIE_VERBOSE_LOGGING == 1
		CWLog(@"Character to be looked up is an empty string");
		#endif
		return YES;
	}
	return NO;
}

+(CWTrieNode *)nodeForCharacter:(NSString *)chr 
						 inNode:(CWTrieNode *)aNode {
	if (CWTrieNodeHasErrorForCharacter(chr)) return nil;
	
	NSString *aChar = (chr.length == 1 ? chr : [chr substringToIndex:1]);
	__block CWTrieNode *node = nil;
	[aNode.children enumerateObjectsUsingBlock:^(CWTrieNode *currentNode, BOOL *stop) {
		if ([currentNode.key isEqualToString:aChar]) {
			node = currentNode;
			*stop = YES;
		}
	}];
	return node;
}

-(id)objectValueForKey:(NSString *)aKey {
	if (aKey.length == 0) {
		#if CWTRIE_VERBOSE_LOGGING == 1
		CWLog(@"Nil or 0 length key. Returning nil");
		#endif
		return nil;
	}
	
	CWTrieNode *currentNode = self.rootNode;
	const char *key = (self.caseSensitive ? [aKey UTF8String] : [[aKey lowercaseString] UTF8String]);
	while (*key) {
		NSString *aChar = [[NSString alloc] initWithBytes:key
												   length:1
												 encoding:NSUTF8StringEncoding];
		CWTrieNode *node = [CWTrie nodeForCharacter:aChar
											 inNode:currentNode];
		if (node) {
			currentNode = node;
			key++;
		} else {
			return nil;
		}
	}
	return currentNode.value;
}

-(void)setObjectValue:(id)aObject 
			   forKey:(NSString *)aKey {
	if(aKey.length == 0) {
		#if CWTRIE_VERBOSE_LOGGING == 1
		CWLog(@"Key is 0 length or nil, cannot set value");
		#endif
		return;
	}
	
	CWTrieNode *currentNode = self.rootNode;
	const char *key = (self.caseSensitive ? [aKey UTF8String] : [[aKey lowercaseString] UTF8String]);
	
	while (*key) {
		NSString *aChar = [[NSString alloc] initWithBytes:key
												   length:1
												 encoding:NSUTF8StringEncoding];
		CWTrieNode *node = [CWTrie nodeForCharacter:aChar
											 inNode:currentNode];
		if (node) {
			currentNode = node;
		} else {
			CWTrieNode *aNode = [[CWTrieNode alloc] initWithKey:aChar];
			[currentNode.children addObject:aNode];
			currentNode = aNode;
		}
		key++;
	}
	if (![currentNode isEqual:self.rootNode]) currentNode.value = aObject;
}

-(void)removeObjectValueForKey:(NSString *)aKey {
	[self setObjectValue:nil
				  forKey:aKey];
}

@end
