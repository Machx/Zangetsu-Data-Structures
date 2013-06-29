/*
//  CWTrie.h
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

  /*
 This class should not make any use of the Zangetsu Framework API's so it can
 retain its independence and be used in other projects not making use of the
 Zangetsu Framework.
  */

#import <Foundation/Foundation.h>

static NSString *const kZangetsuTrieErrorDomain = @"com.Zangetsu.CWTrie";

@interface CWTrie : NSObject

/**
 Sets the Trie to be case sensitive or not for looking up/setting keys
 
 By default Tries are case sensitive.
 */
@property(assign) BOOL caseSensitive;

/**
 Returns the object value for a given key
 
 If a given key exists in a trie instance then this method will return
 the corresponding value for that key. Otherwise this method will
 return nil if there is no value for the corresponding key or if the
 key doesn't exist in the trie instance.
 
 @param aKey a NSString that corresponds to a key in the trie
 @return the corresponding value to a given key or nil
 */
-(id)objectValueForKey:(NSString *)aKey;

/**
 Sets a object value corresponding to the given key
 
 This stores the value in a Trie format for a given key. For example
 If we were to store the value 1 for the key "Tent" and 2 for "Tennis"
 the node layout would look like
 
 [Root] -> [T] -> [e] -> [n] -> [t(1)]
                           \ -> [n] -> [i] -> [s(2)]

 Note that this method allows nil values to be set for keys. In fact
 this is how -removeObjectValueForKey: works, by calling this method
 and passing nil or aObject for a given key.
 */
-(void)setObjectValue:(id)aObject 
			   forKey:(NSString *)aKey;

/**
 Removes a object value for a given key
 
 This method essentially calls [self setObjectValue:nil forKey:aKey]
 setting nil for a given key. This does not remove the nodes for the
 given key, it simply sets the endpoint node value to nil.
 */
-(void)removeObjectValueForKey:(NSString *)aKey;

@end
