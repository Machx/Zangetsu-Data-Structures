/*
//  CWTree.m
//  Zangetsu
//
//  Created by Colin Wheeler on 7/12/11.
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

#import "CWTree.h"
#import "CWQueue.h" // enumeration support

@interface CWTreeNode()
@property(readwrite, strong) NSMutableArray *children;
@end

@implementation CWTreeNode

/**
 Initializes and creates a new CWTreenode Object
 
 @return a CWTreeNode object with no value
 */
-(id)init {
    self = [super init];
    if (self == nil) return nil;
	
	_value = nil;
	_children = [NSMutableArray array];
	_parent = nil;
	_allowsDuplicates = YES;
	
    return self;
}

-(id)initWithValue:(id)aValue {
    self = [super init];
    if (self == nil) return nil;
	
	_value = aValue;
	_children = [NSMutableArray array];
	_parent = nil;
	
    return self;
}

/**
 Returns a NSString with the description of the receiving CWTreeNode Object
 
 @return a NSString with debug information on the receiving CWTreeNode Object
 */
-(NSString *)description {
	__typeof(self.parent) __strong  strongParent = self.parent;
	return [NSString stringWithFormat:@"%@ Node\nValue: %@\nParent: %@\nChildren: %@\nAllows Duplicates: %@",
			NSStringFromClass([self class]),
			[self.value description],
			[strongParent description],
			[self.children description],
			(self.allowsDuplicates ? @"YES" : @"NO")];
}


-(void)addChild:(CWTreeNode *)node {
	if(node == nil) return;
	if (self.allowsDuplicates) {
		node.parent = self;
		[self.children addObject:node];
	} else {
		if (![self.children containsObject:node]) {
			__block BOOL anyNodeContainsValue = NO;
			[self.children enumerateObjectsUsingBlock:^(CWTreeNode *obj, NSUInteger idx, BOOL *stop) {
				if ([obj.value isEqual:node.value]) {
					anyNodeContainsValue = YES;
					*stop = YES;
				}
			}];
			if (!anyNodeContainsValue) {
				node.parent = self;
				node.allowsDuplicates = NO;
				[self.children addObject:node];
			}
		}
	}
}


-(void)removeChild:(CWTreeNode *)node {
	if(![self.children containsObject:node]) return;
	node.parent = nil;
	[self.children removeObject:node];
}

-(BOOL)isEqualToNode:(CWTreeNode *)node {
	__typeof(self.parent) __strong selfParent = self.parent;
	__typeof(node.parent) __strong nodeParent = node.parent;
	if ([node.value isEqual:self.value]   &&
		(selfParent == nodeParent || [nodeParent isEqual:selfParent]) &&
		[node.children isEqual:self.children]) {
		return YES;
	}
    return NO;
}

-(BOOL)isNodeValueEqualTo:(CWTreeNode *)node {
    return [node.value isEqual:self.value];
}

-(NSUInteger)nodeLevel {
    NSUInteger level = 1;
    CWTreeNode *currentNode = self.parent;
    while (currentNode) {
        level++;
        currentNode = currentNode.parent;
    }
    return level;
}

@end

@implementation CWTree

-(id)initWithRootNodeValue:(id)value {
    self = [super init];
    if (self == nil) return nil;
    
    _rootNode = [[CWTreeNode alloc] initWithValue:value];
    
    return self;
}

-(BOOL)isEqualToTree:(CWTree *)tree {
	return [self.rootNode isEqualToNode:tree.rootNode];
}

-(void)enumerateTreeWithBlock:(void (^)(id nodeValue, id node, BOOL *stop))block {
	if(self.rootNode == nil) return;
	
	CWQueue *queue = [[CWQueue alloc] init];
	BOOL shouldStop = NO;
	
	[queue enqueue:self.rootNode];
	while (queue.count > 0) {
		CWTreeNode *node = (CWTreeNode *)[queue dequeue];
		block(node.value, node, &shouldStop);
		if(shouldStop) break;
		if (node.children.count > 0) {
			for (CWTreeNode *childNode in node.children) {
				[queue enqueue:childNode];
			}
		}
	}
}

-(BOOL)containsObject:(id)object {
	__block BOOL contains = NO;
	[self enumerateTreeWithBlock:^(id nodeValue, id node, BOOL *stop) {
		if ([object isEqual:nodeValue]) {
			contains = YES;
			*stop = YES;
		}
	}];
	return contains;
}

-(BOOL)containsObjectWithBlock:(BOOL(^)(id obj))block {
	__block BOOL contains = NO;
	[self enumerateTreeWithBlock:^(id nodeValue, id node, BOOL *stop) {
		if (block(nodeValue)) {
			contains = YES;
			*stop = YES;
		}
	}];
	return contains;
}

@end
