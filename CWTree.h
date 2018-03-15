/*
//  CWTree.h
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

  /*
 This class should not make any use of the Zangetsu Framework API's so it can
 retain its independence and be used in other projects not making use of the
 Zangetsu Framework.
  */


#import <Foundation/Foundation.h>

@interface CWTreeNode : NSObject

/**
 Node value

 @return the id value the node is containing
 */
@property(strong) id value;

/**
 Parent Object which is also a CWTreeNode

 @return a weak reference to the parent of the node
 */
@property(weak) id parent;

/**
 Children Node Objects

 @return the nodes children in the tree
 */
@property(readonly, strong) NSMutableArray *children;

/**
 Key to set if a node allows duplicate children

 @return YES if duplicates are allowed, NO otherwise
 */
@property(assign) BOOL allowsDuplicates;

/**
 Initializes and create a new CWTreeNode Object initialized with aValue
 
 This is the prefeered initializer for CWTreeNode.
 
 @param aValue an Objective-C object that the CWTreeNode will retain
 @return a new CWTreeNode with aValue for the nodes data value and no children
 */
-(id)initWithValue:(id)aValue;

/**
 Adds node to the receivers children
 
 If the receiver allows duplicates it simply adds node to the receivers children
 and sets itself as the nodes parent. If the receiver does not allow duplicates 
 then the receiver checks if the node isn't already in its children. If it is 
 not then it checks the node values of its children to make sure there isn't 
 already a node with the same value there if there isn't then it proceeds and 
 adds the node to the receivers chilren and sets itself as the nodes parent.
 
 @param node a CWTreeNode object
 */
-(void)addChild:(CWTreeNode *)node;

/**
 Removes the object from the receivers children
 
 The receiver checks to make sure the node is in its children and if node is,
 then it removes itself as a parent and removes the node from its chilren.
 
 @param a CWTreeNode object
 */
-(void)removeChild:(CWTreeNode *)node;

/**
 Returns if the receivers value & node pointers are all equal to node
 
 Returns a BOOL value if nodes value is equal to the receivers and if its parent
 poiners are equal as well as its children contents. 
 
 @param node a valid CWTreeNode object
 @return YES if all the nodes values all equal
 */
-(BOOL)isEqualToNode:(CWTreeNode *)node;

/**
 Returns a bool value indicating if nodes value is equal to the receivers
 
 @param node a valid CWTreeNode object
 @return a BOOL with yes if the node values are equal, otherwise no.
 */
-(BOOL)isNodeValueEqualTo:(CWTreeNode *)node;

/**
 Returns the depth level of the node in the tree it is in
 
 @return a NSUInteger with the depth level of the node in its graph of nodes
 */
-(NSUInteger)nodeLevel;
@end

@interface CWTree : NSObject

/**
 Initializes & returns a new CWTree object with a root CWTreeNode set to value
 
 @param value any valid Objective-C object to initialize a CWTreeNode node with
 @return a CWTree object with its rootnode pointer pointing at a newly created 
 CWTreeNode object with value as its node value
 */
-(id)initWithRootNodeValue:(id)value;

/**
 Pointer to the root node of the tree of nodes
 */
@property(strong) CWTreeNode *rootNode;

/**
 Enumerates a CWTree object object on a level by level basis.
 
 Enumerates a CWTree object by starting with the root node and then visiting 
 the children. It visits eash level going from left to right and then visiting
 the next level until it has visited all nodes in the tree or until the BOOL 
 stop pointer in the block has been set to YES.
 
 Block values passed back to you are as follows
 @param nodeValue a convenience to accessing [(CWTreeNode *) node nodeValue]
 @param node a pointer to the node being enumerated over
 @param stop a BOOL pointer which you can set to YES to stop enumeration, 
 otherwise it will continue until all nodes have been enumerated over
 */
-(void)enumerateTreeWithBlock:(void (^)(id nodeValue, id node, BOOL *stop))block;

/**
 Returns a bool indicating if the tree object is equal to the receiver tree
 
 @return a BOOL if the receivers children objects are equal to tree's children
 */
-(BOOL)isEqualToTree:(CWTree *)tree;

/**
 Returns a BOOL indicating if the object argument is contained in the receiver
 
 @param object the object you wish to see if its contained in the receiver
 @return YES if object is contained in the block or NO otherwise
 */
-(BOOL)containsObject:(id)object;

/**
 Returns a BOOL indicating if the object argument is contained in the receiver
 
 @param block a block that returns a bool indicating if the object passed in is 
 a match to object
 @return YES if object is contained in the block or NO otherwise
 */
-(BOOL)containsObjectWithBlock:(BOOL(^)(id obj))block;

@end
