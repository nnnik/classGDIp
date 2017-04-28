# classGDIp

## An object based wrapper around the gdiplus.dll written in AutoHotkey

### 1. Goals:
* What I want to achieve with this is to bring the GDIplus.dll to AutoHotkey in the way it was intended to be wrapped around.
* I also want to make the API easier to use - safer and less prone to breaking.
* I want consistent syntax, naming and usage throughout the library.
* The final result should fully wrap around the gdiplus API.
* I also want to make it possible to debug it easier by using Throw Exception()...

### 2. In order to achieve this I will set some Guidelines for new Code:
* __overloaded constructors:__ In the gdiplus.dll there are several Overloaded constructors for every type of Object. 
All of these different Constructor functions should be wrapped around by each object types constructor ( `__New` ). 
With the exception of those that make no sense in AutoHotkeys context.
* __registerObject and unregisterObject__ In order to make sure that every object get's safely deleted when the API closes you need to register the object in it's constructor and unregister it in it's destructor.
* __disconnect base__ Detatch the object from it's base in it's destructor by calling `This.base := ""` or similar.
* __class nesting__ all classes should either be nested within the class GDIp or any of it's subclasses.
* __the ptr field and getp*ObjectType*__ Any class that represents a GDIp Object should store it's objects pointer in `This.ptr`. 
It should also return this pointer upon calling `getpObjectType()` where `ObjectType` get's replaced by the Objects type ( e.g. `getpBitmap()` for Bitmaps ). 
* __parameters__ The biggest issue is making parameters both consistent and easy to use. Parameters should represent attributes that can be set e.g. Size
