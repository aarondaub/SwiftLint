//
//  String+SwiftLint.swift
//  SwiftLint
//
//  Created by JP Simard on 2015-05-16.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import Foundation
import SourceKittenFramework

extension String {
    func lines() -> [Line] {
        var lines = [Line]()
        var lineIndex = 1
        enumerateLines { line, stop in
            lines.append((lineIndex++, line))
        }
        return lines
    }

    func isUppercase() -> Bool {
        return self == uppercaseString
    }

    func countOfTailingCharactersInSet(characterSet: NSCharacterSet) -> Int {
        return String(reverse(self)).countOfLeadingCharactersInSet(characterSet)
    }
  
    func trim(charactersInSet: NSCharacterSet = NSCharacterSet.whitespaceCharacterSet()) -> String {
      return self.stringByTrimmingCharactersInSet(charactersInSet)
    }
    
    func rangesDelimitedBy(start: String, end: String? = nil) -> [NSRange] {
      var stackDepth = 0
      var initialLine: Int? = nil
      let optionalRanges = map(self.lines()) { (line: Line) -> NSRange? in
        if line.content.trim() == start {
          if stackDepth == 0 {
            initialLine = line.index
          }
          
          stackDepth++
        } else if line.content.trim() == (end ?? start) && stackDepth > 0 {
          stackDepth--
          
          if stackDepth == 0 {
            let optionalRange = map(initialLine) {
              NSMakeRange($0, line.index - $0)
            }
            
            initialLine = nil
            return optionalRange
          }
        }
        return nil
      }
      
      return flatten(optionalRanges)
    }
}

extension NSString {
    public func lineAndCharacterForByteOffset(offset: Int) -> (line: Int, character: Int)? {
        return flatMap(byteRangeToNSRange(start: offset, length: 0)) { range in
            var numberOfLines = 0
            var index = 0
            var lineRangeStart = 0
            while index < length {
                numberOfLines++
                if index <= range.location {
                    lineRangeStart = numberOfLines
                    index = NSMaxRange(self.lineRangeForRange(NSRange(location: index, length: 1)))
                } else {
                    break
                }
            }
            return (lineRangeStart, 0)
        }
    }
}
