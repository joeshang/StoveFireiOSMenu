//Copyright (c) 2012 The Board of Trustees of The University of Alabama
//All rights reserved.
//
//Redistribution and use in source and binary forms, with or without
//modification, are permitted provided that the following conditions
//are met:
//
//1. Redistributions of source code must retain the above copyright
//notice, this list of conditions and the following disclaimer.
//2. Redistributions in binary form must reproduce the above copyright
//notice, this list of conditions and the following disclaimer in the
//documentation and/or other materials provided with the distribution.
//3. Neither the name of the University nor the names of the contributors
//may be used to endorse or promote products derived from this software
//without specific prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
//FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
//THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
//HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
//STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
//OF THE POSSIBILITY OF SUCH DAMAGE.


#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define OMDateFormat @"yyyy-MM-dd'T'HH:mm:ss.SSS"
#define OMTimeZone @"UTC"


typedef NS_ENUM(NSInteger, CAPSDataType) {
    CAPSDataTypeJSON,
    CAPSDataTypeXML,
    CAPSDataTypeSOAP
};

@interface NSObject (ObjectMap)

// Universal Method
-(NSDictionary *)propertyDictionary;
-(NSString *)nameOfClass;


#pragma mark - Init Methods
/**
 Initializes an instance of a new object using JSON.
 
 @param data The JSON data to deserialize into the returned object.
 
 @return The newly-initialized object.
 */
- (instancetype)initWithJSONData:(NSData *)data;


/**
 Initializes an instance of a new object using XML.
 
 @param data The XML data to deserialize into the returned object.
 
 @return The newly-initialized object.
 */
- (instancetype)initWithXMLData:(NSData *)data;


/**
 Initializes an instance of a new object using SOAP.
 
 @param data The SOAP data to deserialize into the returned object.
 
 @return The newly-initialized object.
 */
- (instancetype)initWithSOAPData:(NSData *)data;


/**
 Initializes an instance of a new object using unspecified object data and a specified type.
 
 @param data The unspecified data to deserialize into the returned object.
 @param type The type of unspecified data to deserialize.
 
 @return The newly-initialized object.
 */
- (instancetype)initWithObjectData:(NSData *)data type:(CAPSDataType)type;



#pragma mark - Top Level Array from JSON
/**
 Initializes an array of objects that are of a certain class from JSON data.
 
 @param objectClass The type of object to deserialize into.
 @param data The JSON data to deserialize into the array.
 
 @return The newly-initialized array.
 */
+ (NSArray *)arrayOfType:(Class)objectClass FromJSONData:(NSData *)data;



#pragma mark - Serialized Data/Strings from Objects
-(NSData *)JSONData;
-(NSString *)JSONString;
-(NSData *)XMLData;
-(NSString *)XMLString;
-(NSData *)SOAPData;
-(NSString *)SOAPString;
-(NSDictionary *)objectDictionary;


#pragma mark - New Object with properties of another Object
-(id)initWithObject:(NSObject *)oldObject error:(NSError **)error;

#pragma mark - Base64 Encode/Decode
+(NSString *)encodeBase64WithData:(NSData *)objData;
+(NSData *)base64DataFromString:(NSString *)string;

@end

@interface SOAPObject : NSObject
@property (nonatomic, retain) id Header;
@property (nonatomic, retain) id Body;
@end