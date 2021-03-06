//
//  EVReflectionTests.swift
//
//  Created by Edwin Vermeer on 4/29/15.
//  Copyright (c) 2015. All rights reserved.
//

import XCTest

/**
Testing EVReflection
*/
class EVReflectionTests: XCTestCase {

    /**
    For now nothing to setUp
    */
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EVReflection.setBundleIdentifier(TestObject)
    }

    /**
    For now nothing to tearDown
    */
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /**
    Get the string name for a clase and then generate a class based on that string
    */
    func testClassToAndFromString() {
        // Test the EVReflection class - to and from string
        let theObject = TestObject()
        let theObjectString: String = EVReflection.swiftStringFromClass(theObject)
        NSLog("swiftStringFromClass = \(theObjectString)")

        let nsobject = EVReflection.swiftClassFromString(theObjectString)
        NSLog("object = \(nsobject)")
        XCTAssert(nsobject != nil, "Pass")

        let theObject2 = subObject()
        let theObject2String: String = EVReflection.swiftStringFromClass(theObject2)
        NSLog("swiftStringFromClass = \(theObject2String)")
        
        let nsobject2 = EVReflection.swiftClassFromString(theObject2String)
        NSLog("object = \(nsobject2)")
        XCTAssert(nsobject != nil, "Pass")
        
        
        let nsobject3 = EVReflection.swiftClassFromString("NSObject")
        XCTAssertNotNil(nsobject3, "Pass")

        let nsobject4 = EVReflection.swiftClassFromString("NotExistingClassName")
        XCTAssertNil(nsobject4, "Pass")
        
    }

    class subObject: NSObject {
        var field: String?
    }
    
    
    
    /**
    Create a dictionary from an object where each property has a key and then create an object and set all objects based on that directory.
    */
    func testClassToAndFromDictionary() {
        let theObject = TestObject2()
        let theObjectString: String = EVReflection.swiftStringFromClass(theObject)
        theObject.objectValue = "testing"
        let (toDict, _) = EVReflection.toDictionary(theObject)
        NSLog("toDictionary = \(toDict)")
        let nsobject = EVReflection.fromDictionary(toDict, anyobjectTypeString: theObjectString) as? TestObject2
        NSLog("object = \(nsobject), objectValue = \(nsobject?.objectValue)")
        XCTAssert(theObject == nsobject, "Pass")
    }

    func testNSObjectFromDictionary() {
        let x = TestObject2c(dictionary: ["objectValue": "tst", "default":"default"])
        XCTAssertEqual(x.objectValue, "tst", "objectValue should have been set")
        XCTAssertEqual(x._default, "default", "default should have been set")
        
        let y = EVReflection.fromDictionary(["a":"b"], anyobjectTypeString: "NotExistingClassName")
        XCTAssertNil(y, "Class is unknow, so we should not have an instance")
    }

    func testNSObjectArrayFromJson() {
        let x:[TestObject2c] = TestObject2c.arrayFromJson("[{\"objectValue\":\"tst\"},{\"objectValue\":\"tst2\"}]")
        XCTAssertEqual(x.count, 2, "There should have been 2 elements")
        if x.count == 2 {
            XCTAssertEqual(x[0].objectValue, "tst", "objectValue should have been set")
            XCTAssertEqual(x[1].objectValue, "tst2", "objectValue should have been set")            
        }
    }

    
    /**
    Create 2 objects with the same property values. Then they should be equal. If you change a property then the objects are not equeal anymore.
    */
    func testEquatable() {
        let theObjectA = TestObject2()
        theObjectA.objectValue = "value1"
        let theObjectB = TestObject2()
        theObjectB.objectValue = "value1"
        XCTAssert(theObjectA == theObjectB, "Pass")

        theObjectB.objectValue = "value2"
        XCTAssert(theObjectA != theObjectB, "Pass")

        let theObjectA2 = TestObject2b()
        theObjectA2.objectValue = "value1"
        
        XCTAssert(!theObjectA.isEqual(theObjectA2), "Pass")
    }
    
    /**
    Just get a hash from an object
    */
    func testHashable() {
        let theObject = TestObject2()
        theObject.objectValue = "value1"
        let hash = theObject.hash
        NSLog("hash = \(hash)")
    }

    /**
    Print an object with all its properties.
    */
    func testPrintable() {
        let theObject = TestObject2()
        theObject.objectValue = "value1"
        NSLog("theObject = \(theObject)")
        EVReflection.logObject(theObject)
    }

    /**
    Archive an object with NSKeyedArchiver and read it back with NSKeyedUnarchiver. Both objects should be equal
    */
    func testNSCoding() {
        let theObject = TestObject2()
        theObject.objectValue = "value1"

        let filePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp.dat")

        // Write object to file
        NSKeyedArchiver.archiveRootObject(theObject, toFile: filePath)

        // Read object from file
        let result = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? TestObject2

        // Test if the objects are the same
        XCTAssert(theObject == result, "Pass")
    }

    func testNSCodingConvenience() {
        let theObject = TestObject2()
        theObject.objectValue = "value1"
        
        theObject.saveToTemp("temp.dat")
        let result = TestObject2(fileNameInTemp: "temp.dat")
        
        XCTAssert(theObject == result, "Pass")
        
        theObject.saveToDocuments("temp2.dat")
        let result2 = TestObject2(fileNameInDocuments: "temp2.dat")
        
        XCTAssert(theObject == result2, "Pass")
    }
    
    /**
    Create a dictionary from an object that contains a nullable type. Then read it back. We are using the workaround in TestObject3 to solve the setvalue for key issue in Swift 1.2
    */
    func testClassToAndFromDictionaryWithNullableType() {
        let theObject = TestObject3()
        let theObjectString: String = EVReflection.swiftStringFromClass(theObject)
        theObject.objectValue = "testing"
        theObject.nullableType = 3
        let (toDict, _) = EVReflection.toDictionary(theObject)
        NSLog("toDictionary = \(toDict)")
        let nsobject = EVReflection.fromDictionary(toDict, anyobjectTypeString: theObjectString) as? TestObject3
        NSLog("object = \(nsobject), objectValue = \(nsobject?.objectValue)")
        XCTAssert(theObject == nsobject, "Pass")
    }

    /**
    Archive an object that contains a nullable type with NSKeyedArchiver and read it back with NSKeyedUnarchiver. Both objects should be equal. We are using the workaround in TestObject3 to solve the setvalue for key issue in Swift 1.2

    */
    func testNSCodingWithNullableType() {
        let theObject = TestObject3()
        theObject.objectValue = "value1"
        theObject.nullableType = 3

        let filePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent("temp.dat")

        // Write object to file
        NSKeyedArchiver.archiveRootObject(theObject, toFile: filePath)

        // Read object from file
        let result = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? TestObject3
        NSLog("unarchived result object = \(result)")

        // Test if the objects are the same
        XCTAssert(theObject == result, "Pass")
    }

    /**
    Test the convenience methods for getting a dictionary and creating an object based on a dictionary.
    */
    func testClassToAndFromDictionaryConvenienceMethods() {
        let theObject = TestObject2()
        theObject.objectValue = "testing"
        let toDict = theObject.toDictionary()
        NSLog("toDictionary = \(toDict)")
        let result = TestObject2(dictionary: toDict)
        XCTAssert(theObject == result, "Pass")
    }

    /**
    Get a dictionary from an object, then create an object of a diffrent type and set the properties based on the dictionary from the first object. You can initiate a diffrent type. Only the properties with matching dictionary keys will be set.
    */
    func testClassToAndFromDictionaryDiffrentType() {
        let theObject = TestObject3()
        theObject.objectValue = "testing"
        theObject.nullableType = 3
        let toDict = theObject.toDictionary()
        NSLog("toDictionary = \(toDict)")
        let result = TestObject2(dictionary: toDict)
        XCTAssert(theObject != result, "Pass") // The objects are not the same
    }

    
    /**
    Get a dictionary from an object, then create an object of a diffrent type and set the properties based on the dictionary from the first object. You can initiate a diffrent type. Only the properties with matching dictionary keys will be set.
    */
    func testClassToAndFromDictionaryDiffrentTypeAlt() {
        let theObject = TestObject4()
        theObject.myString = "string"
        theObject.myInt = 4
        let toDict = theObject.toDictionary()
        NSLog("toDictionary = \(toDict)")
        let result = TestObject3(dictionary: toDict)
        XCTAssert(theObject != result, "Pass") // The objects are not the same
    }
    
    /**
    Test the conversion from string to number and from number to string
    */
    func testTypeDict() {
        let i:Int32 = 1
        let s:String = "2"
        let dictOriginal: NSMutableDictionary = NSMutableDictionary()
        dictOriginal.setValue(s, forKey: "myInt")
        dictOriginal.setValue(NSNumber(int:i), forKey: "myString")
        let a = TestObject4(dictionary: dictOriginal)
        XCTAssertEqual(a.myString, "1", "myString should contain 1")
        XCTAssertEqual(a.myInt, 2, "myInt should contain 2")
    }
    
    func testTypeDictAllString() {
        let dict = ["myString":"1", "myInt":"2", "myFloat":"2.1", "myBool":"1", "myNSNumber":"bogus"]
        let a = TestObject4(dictionary: dict)
        XCTAssertEqual(a.myString, "1", "myString should contain 1")
        XCTAssertEqual(a.myInt, 2, "myInt should contain 2")
        XCTAssertEqual(a.myFloat, 2.1, "myFloat should contain 2.1")
        XCTAssertEqual(a.myBool, true, "myBool should contain true")
        XCTAssertEqual(a.myNSNumber, 0, "myNSNumber should contain 2")
    }
    
    func testTypeDict2AllNumeric() {
        let dict = ["myString":1, "myInt":2, "myFloat":2.1, "myBool":1]
        let a = TestObject4(dictionary: dict)
        XCTAssertEqual(a.myString, "1", "myString should contain 1")
        XCTAssertEqual(a.myInt, 2, "myInt should contain 2")
        XCTAssertEqual(a.myFloat, 2.1, "myFloat should contain 2.1")
        XCTAssertEqual(a.myBool, true, "myBool should contain true")
    }
    
    func testObjectWithArray() {
        let json = "{\"myString\":\"str\", \"list\":[{\"myString\":\"str1\"}]}"
        let a = TestObject4(json: json)
        XCTAssertEqual(a.myString, "str", "myString should be str")
        XCTAssertEqual(a.list.count, 1, "We should have 1 item in the list")

        let json2 = "{\"myString\":\"str\", \"list\":{\"myString\":\"str1\"}}"
        let b = TestObject4(json: json2)
        XCTAssertEqual(b.myString, "str", "myString should be str")
        XCTAssertEqual(b.list.count, 1, "We should have 1 item in the list")
    }

    
    /**
    Test various large number conversions to NSNumber
    */
    func testNSNumber() {
        let test1 = NSNumber(double: Double(Int.max))
        let (value1, _) = EVReflection.valueForAny("", key: "", anyValue: test1)
        XCTAssert(value1 as? NSNumber == NSNumber(double: Double(Int.max)), "Values should be same for type NSNumber")
        
        let test2:Float = 458347978508
        let (value2, _) = EVReflection.valueForAny("", key: "", anyValue: test2)
        XCTAssert(value2 as? NSNumber == NSNumber(float: 458347978508), "Values should be same for type Float")

        let test3:Double = 458347978508
        let (value3, _) = EVReflection.valueForAny("", key: "", anyValue: test3)
        XCTAssert(value3 as? NSNumber == NSNumber(double: 458347978508), "Values should be same for type Double")

        let test4:Int64 = Int64.max
        let (value4, _) = EVReflection.valueForAny("", key: "", anyValue: test4)
        XCTAssert(value4 as? NSNumber == NSNumber(longLong: Int64.max), "Values should be same for type Int64")

        let test5:Int32 = Int32.max
        let (value5, _) = EVReflection.valueForAny("", key: "", anyValue: test5)
        XCTAssert(value5 as? NSNumber == NSNumber(int: Int32.max), "Values should be same for type Int32")

        let test6:Int = Int.max
        let (value6, _) = EVReflection.valueForAny("", key: "", anyValue: test6)
        XCTAssert(value6 as? NSNumber == NSNumber(integer: Int.max), "Values should be same for type Int64")
    }
    
    func testCustomPropertyMapping() {
        let dict = ["Name":"just a field", "dummyKeyInJson":"will be ignored", "keyInJson":"value for propertyInObject", "ignoredProperty":"will not be read or written"]
        let a = TestObject5(dictionary: dict)
        XCTAssertEqual(a.Name, "just a field", "Name should containt 'just a field'")
        XCTAssertEqual(a.propertyInObject, "value for propertyInObject", "propertyInObject should containt 'value for propertyInObject'")
        XCTAssertEqual(a.ignoredProperty, "", "ignoredProperty should containt ''")
        
        let toDict = a.toDictionary(true)
        let dict2 = ["name":"just a field","key_in_json":"value for propertyInObject"]
        XCTAssertEqual(toDict, dict2, "export dictionary should only contain a name and key_in_json")
    }
    
    func testCamelCaseToUndersocerMapping() {
        XCTAssertEqual(EVReflection.camelCaseToUnderscores("swiftIsGreat"), "swift_is_great", "Cammelcase to underscore mapping was incorrect")
        XCTAssertEqual(EVReflection.camelCaseToUnderscores("SwiftIsGreat"), "swift_is_great", "Cammelcase to underscore mapping was incorrect")
        
    }
    
    func testEnumAssociatedValues() {
        let parameters:[usersParameters] = [.number(19), .authors_only(false)]
        let y = WordPressRequestConvertible.MeLikes("XX", Dictionary(associated: parameters))
        // Now just extract the label and associated values from this enum
        let label = y.associated.label
        let (token, param) = y.associated.value as! (String, [String:Any]?)

        XCTAssertEqual("MeLikes", label, "The label of the enum should be MeLikes")
        XCTAssertEqual("XX", token, "The token associated value of the enum should be XX")
        XCTAssertEqual(19, param?["number"] as? Int, "The number param associated value of the enum should be 19")
        XCTAssertEqual(false, param?["authors_only"] as? Bool, "The authors_only param associated value of the enum should be false")
        
        print("\(label) = {token = \(token), params = \(param)")
    }
}



// See http://github.com/evermeer/EVWordPressAPI for a full functional usage of associated values
enum WordPressRequestConvertible: EVAssociated {
    case Users(String, Dictionary<String, Any>?)
    case Suggest(String, Dictionary<String, Any>?)
    case Me(String, Dictionary<String, Any>?)
    case MeLikes(String, Dictionary<String, Any>?)
    case Shortcodes(String, Dictionary<String, Any>?)
}

public enum usersParameters: EVAssociated {
    case context(String)
    case http_envelope(Bool)
    case pretty(Bool)
    case meta(String)
    case fields(String)
    case callback(String)
    case number(Int)
    case offset(Int)
    case order(String)
    case order_by(String)
    case authors_only(Bool)
    case type(String)
}










