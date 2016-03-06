//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

var emptyArray: [String] = []

var x = 0
for i in 1..<10
{
//    emptyArray.insert(String(i), atIndex: x)
    emptyArray.append(String(i));
    x++
}

print(emptyArray)


let lengthFormatter = NSLengthFormatter()
lengthFormatter.forPersonHeightUse = true
let meters = 1.6
print(lengthFormatter.stringFromMeters(meters)) // "3.107 mi"
print(lengthFormatter.stringFromValue(meters, unit: .Foot))