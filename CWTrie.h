/*
 //  CWTrie.h
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

#import <Foundation/Foundation.h>

/**
 CWTrie
 
 CWTrie is a Trie Data Structure that is built with pure Objective-C and is
 thread safe. It uses a serial dispatch_queue_t to perform all operations to
 ensure that they are executed serially. The set method is asynchronous, but all
 get methods (objectValueForKey,containsKey,etc.) are synchronous. Optionally
 it can be set so that the keys are case sensitive, but by default they are not.
 */

@interface CWTrie : NSObject

/**
 Initializes & returns a new CWTrie instance
 
 @return An initialized CWTrie instance
 */
-(instancetype)init;

/**
 Initializes & returns a new CWTrie instance
 
 @param caseSensitive sets if the trie instace should use case sensitive keys
 @return An initialized CWTrie instance
 */
-(instancetype)initWithCaseSensitiveKeys:(BOOL)caseSensitive;

/**
 Sets a key value pair in the trie
 
 @param value the value for key. Must not be nil.
 @param key the key for value. Must not be nil.
 */
-(void)setObjectValue:(id)value forKey:(NSString *)key;

/**
 Returns the object corresponding to key or nil if no such key is set
 
 @param key the key to be used to see if something exists. Must not be nil.
 */
-(id)objectValueForKey:(NSString *)key;

/**
 Returns if the key passed in is contained in the receiver
 
 @return a BOOL value indicating if the key is in the receiver. Must not be nil.
 */
-(BOOL)containsKey:(NSString *)key;

/**
 Removes the object value corresponding to key in the receiver
 
 This method will try to find the key passed in, if at any time the trie can't
 find it (it doesn't exist) then this method simply returns. Otherwise it
 will simply set the value corresponding with key to nil and return.
 
 @param key The key whose corresponding value should be removed. Must not be nil
 */
-(void)removeObjectValueForKey:(NSString *)key;

@end
