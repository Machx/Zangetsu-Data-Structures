/*
//  CWTrie.m
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

#ifndef CWLog
#define CWLog(args...) NSLog(@"%s %i: %@",__PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:args]);
#endif

#ifndef CWConditionalLog
#define CWConditionalLog(cond,args...) \
do { \
	if((cond)){ \
		NSLog(@"%s L#%i: %@",__PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:args]); \
	} \
} while(0);
#endif

BOOL CWTrieNodeHasErrorForCharacter(NSString *character);

//Log = 1, no logging = 0
#define CWTRIE_VERBOSE_LOGGING 1

@interface CWTrieNode : NSObject
@property(copy) NSString *key;
@property(retain) id value;
@property(retain) NSMutableSet *children;
@end

@implementation CWTrieNode

/**
 This should be the designated initializer 99.99% of the time
 */
- (instancetype)initWithKey:(NSString *)nodeKey {
	self = [super init];
	if (self == nil) return nil;
	
	_key = nodeKey;
	_value = nil;
	_children = [NSMutableSet set];
	
	return self;
}

- (instancetype)init {
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

- (instancetype)init {
    self = [super init];
    if (self == nil) return nil;
	
	_rootNode = [[CWTrieNode alloc] init];
	_caseSensitive = YES;
	
    return self;
}

-(NSString *)description {
	return [NSString stringWithFormat:@"Trie (\nCase Sensitive: %@\nNodes: %@)",
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
		CWConditionalLog(CWTRIE_VERBOSE_LOGGING,
						 @"Character to be looked up is nil");
		return YES;
	}
	if (character.length == 0) {
		CWConditionalLog(CWTRIE_VERBOSE_LOGGING,
						 @"Character to be looked up is an empty string");
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
		CWConditionalLog(CWTRIE_VERBOSE_LOGGING,
						 @"Nil or 0 length key. Returning nil");
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
		CWConditionalLog(CWTRIE_VERBOSE_LOGGING,
						 @"Key is 0 length or nil, cannot set value");
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
