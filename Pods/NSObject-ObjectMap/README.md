NSObject+ObjectMap
=============

This is a drop-in category of NSObject that makes it easy to initialize custom objects from JSON or XML (SOAP included), and to serialize those objects back into JSON/XML. It only requires a little bit of set-up - and then you never have to fuss with creating your own serialization and initialization methods for each custom NSObject ever again.

**Version:** 2.0

![ScreenShot](https://raw.github.com/uacaps/NSObject-ObjectMap/master/Screenshots/screen1-01.png)

--------------------
## Set-Up ##

The only step is to add NSObject+ObjectMap.{h,m} into your project. That's really it.

--------------------
## Working with JSON ##

**Creating your Objects**

This step requires knowing what the JSON coming back will look like. Examine your data source and create your custom NSObject classes to match this. For instance, say you have JSON coming back like this:

```
{
  Username : "Big Al",
  Password : "r0llt1d3",
	Color : "Crimson",
	Location : "Tuscaloosa, AL",
	Championships: 15
}
```

If this were the case, you would create your custom NSObject where its properties match this:

```objc
@property (nonatomic, retain) NSString *Username;
@property (nonatomic, retain) NSString *Password;
@property (nonatomic, retain) NSString *Color;
@property (nonatomic, retain) NSString *Location;
@property (nonatomic, retain) NSNumber *Championships;
```

The beautiful thing about this class is that, beyond basic Objective-C classes like NSString and NSNumber, it can handle any object that you create as well. Let's call the previous class definition <code>User</code> - and now let's make an object that has a User class object for a property.

```objc
// JSON snippet
{
	Name : "Bryant-Denny",
	CreatedByUser : {
		Username : "Big Al",
		Password : "r0llt1d3",
		Color : "Crimson",
		Location : "Tuscaloosa, AL",
		Championships: 15
	}
}

// Place.h
@property (nonatomic, retain) NSString *Name;
@property (nonatomic, retain) User *CreatedByUser;
```

<code>NSObject+ObjectMap</code> works by deserializing the JSON and matching the various keys in the JSON packet with the various properties of your objects you want to map to. The caveat of this design is that you must name your properties the exact same as the keys coming back or that property will be left uninitialized (nil) when the deserialization is done.

**Working with Arrays**

Unfortunately with JSON you're flying blind with regards to the type of objects encased in arrays, one more set up step is necessary for JSON deserialization to an NSObject. If your custom NSObject contains one or more NSArray(s), you need to create a custom init method for this object (or include the following code in your already created custom init). This method is creating an NSDictionary called <code>propertyArrayMap</code> with key/value pairs that match the property name (key) with the type of object you want the NSArray to contain (value). When the object is created from your JSON packet, and the property it is working on is an NSArray, it will check this dictionary to find what kind of objects it needs to create inside the array. Here's an example of setting it up:

```objc
// JSON snippet
{
	Name : "Billy",
	FavoriteColors : ["Red","Blue","Tangerine"],
	FavoritePeople : [{
		Name : "Jenny",
		FavoriteColors: [@"Orange","Black"],
		FavoritePeople: []
	},{
		Name : "Ben",
		FavoriteColors: ["Silver","Emerald","Aquamarine"],
		FavoritePeople: []
	}]
}


// Person.h
@property (nonatomic, retain) NSString *Name;
@property (nonatomic, retain) NSArray *FavoriteColors;
@property (nonatomic, retain) NSArray *FavoritePeople;


// Person.m
-(id)init {
	self = [super init];
	if (self) {
		[self setValue:@"NSString" forKeyPath:@"propertyArrayMap.FavoriteColors"];
		[self setValue:@"Person" forKeyPath:@"propertyArrayMap.FavoritePeople"];
	}
	return self;
}
```

So in this example, we have a JSON string that represents a Person. This Person has a name and two array properties, FavoriteColors and FavoritePeople. FavoriteColors is an array of strings and FavoritePeople is an array of Person objects. As you can tell, the custom init method we created for Person.m sets the <code>propertyArrayMap</code> up to handle what type of object should be contained (in the setValue) and what key to match it to (forKeyPath). As with the other properties and keys mentioned earlier, make sure that these are spelled correctly for proper deserialization and object creation.

**Going from JSON to Object**

At this point, you should have your custom NSObjects created and your JSON data returning from a webservice, ready to be turned directly into those objects. Now for the easy part. Use the built in NSJSONSerialization methods to turn your JSON data into an NSDictionary or an NSArray, then we're going to pass that into a method that will return your custom NSObject from that. We're going to use the Person JSON snippet from earlier to illustrate this:

```objc
// JSON snippet
{
	Name : "Billy",
	FavoriteColors : ["Red","Blue","Tangerine"],
	FavoritePeople : [{
		Name : "Jenny",
		FavoriteColors: [@"Orange","Black"],
		FavoritePeople: []
	},{
		Name : "Ben",
		FavoriteColors: ["Silver","Emerald","Aquamarine"],
		FavoritePeople: []
	}]
}

// Turn that JSON into an NSDictionary, then into your Person object
// - jsonData is the NSData equivalent of the JSON snippet above.
NSData *jsonData;

// Now to create the Person object
Person *newPerson = [[Person alloc] initWithJSONData:jsonData];
```

Using an array almost the exact same, but instead of an NSDictionary returning from the JSON deserialization, you've received an NSArray. If this NSArray contains a bunch of Person objects, use the following method to create this array:

```objc
NSArray *peopleArray = [NSObject arrayOfType:[Person class] fromJSONData:jsonData];
```

**Serializing Object to JSON**

Most modern web services and APIs use JSON post data to pass objects that can be handled server-side. Using this class to create your JSON data could not be easier.

```objc
Person *newPerson = [[Person alloc] init];
NSData *jsonData = [newPerson JSONData];
```

To see a string representation of what that JSON packet would look like, use the <code>[NSObject JSONString]</code> method that returns an NSString instead of NSData. You can make sure this is valid JSON by using any number of validation tools online like jsonlint.com.

**Troubleshooting**

Because of the caveats listed earlier, here's a list of items to check and consider if the class isn't working like it should:

* Properties of objects are named the *exact* same as the corresponding keys in your JSON
* Your JSON object is actually an NSDictionary (or NSArray), and didn't fail in deserialization
* If your NSObjects contain NSArray properties, you used the custom init method to set up the <code>propertyArrayMap</code> keys/values and named those correctly
* Your OMDateFormat/OMTimeZone defines were set to the correct format

--------------------
## Working with XML (and SOAP) ##

**Creating your Objects**

This step requires knowing what the XML coming back will look like. Examine your data source and create your custom NSObject classes to match this. For instance, say you have XML coming back like this:

```
<MyObject>
	<Username>Big Al</Username>
	<Password>r0llt1d3</Password>
	<Color>Crimson</Color>
	<Location>Tuscaloosa, AL</Location>
	<Championships>15</Championships>
<MyObject>
```

If this were the case, you would create your custom NSObject named <code>MyObject</code> where its properties match this:

```objc
@property (nonatomic, retain) NSString *Username;
@property (nonatomic, retain) NSString *Password;
@property (nonatomic, retain) NSString *Color;
@property (nonatomic, retain) NSString *Location;
@property (nonatomic, retain) NSNumber *Championships;
```

**Serialization/Deserialization**

Just like the JSON side of things, nested complex objects are supported in XML. Also, there is no need to specify array types, so working with XML is arguably more simple. To serialize an object to XML, simply do the following:

```objc
MyObject *object = [[MyObject alloc] init];

//*** Fill in object properties with data here ***

NSData *xmlData = [object XMLData];

//*** Send data over web ***
```

Deserializing back from XML is just as easy:

```objc
// XML String of Object
NSString *xmlString = @"<MyObject>
	<Username>Big Al</Username>
	<Password>r0llt1d3</Password>
	<Color>Crimson</Color>
	<Location>Tuscaloosa, AL</Location>
	<Championships>15</Championships>
<MyObject>";

// XML Data
NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];

// Create MyObject
MyObject *customObject = [[MyObject alloc] initWithXMLData:xmlData];
```

**Note on SOAP:** At this point, only simple, tag-driven SOAP is supported. Support for more complex namespace and attribute handling will come if the need arises. Feel free to make a pull request if you find a great way to handle more complex SOAP.

--------------------
## Working with NSDates ##

In the <code>NSObject+ObjectMap.h</code> file there are two #define constants representing the format/timezone information for NSDate deserialization. Match these to the JSON/XML you are getting back so that NSDateFormatter creates the NSDate objects correctly. These properties are:

* OMDateFormat
* OMTimeZone

--------------------
## Demos ##

To see NSObject+ObjectMap in action, check out one of our many sample Xcode projects under the <code>Demos</code> folder in the top-level. The **Google Places** demo illustrates NSObject+ObjectMap's JSON handling while the **Weather** demo takes care of XML. Make sure to check out their READMEs to figure out any setup work before running.

![screenshot](https://raw.github.com/uacaps/NSObject-ObjectMap/master/Screenshots/google_screen.png)   ![screenshot](https://raw.github.com/uacaps/NSObject-ObjectMap/master/Screenshots/weather_screen.png)

--------------------
## Unit Tests ##

We have an entire new Unit Testing suite to make sure ObjectMap is actually working after any changes to it. You can run this by opening the <code>UnitTests.xcodeproj</code> under the Tests folder. Just hit <code>Cmd - U</code> on the keyboard to run them and watch to see if it says "Tests Succeeded" on screen. Sometimes it will say "Tests Failed", but if you look in each of the TestCase classes, you will see green or red diamonds by each method. A green diamond means it passed, and a red diamond means it failed.

--------------------
## Cocoapods ##

Cocoapods is a dependency manager for Objective-C code, and is wonderful for setting up your projects from the start and maintaing them through different versions. When NSObject+ObjectMap.{h,m} updates, you can always get the newest version by changing your podspec file to include the following line to make sure your project stays up to date:

<code>pod 'NSObject-ObjectMap', '~> 2.0'</code>

--------------------
## License ##

Copyright (c) 2012 The Board of Trustees of The University of Alabama
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. Neither the name of the University nor the names of the contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.
