//
//  Linter.swift
//  SwiftLint
//
//  Created by JP Simard on 2015-05-16.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import Foundation
import SwiftXPC
import SourceKittenFramework

public struct FileRegion {
  public let file: File
  public let commands: [ConfigurationCommand]
}

extension NSRange {
  var end: Int {
    return self.location + self.length
  }
}

extension File {
  func subfile(range: NSRange) -> File? {
    if range.end < self.contents.lines().count {
      let stringLines = self.contents.lines().map { $0.content }
      let linesToKeep = Array<String>(stringLines[range.location..<range.end])
      return File(contents: "\n".join(linesToKeep))
    }
    return nil
  }
  
  public var configuredRegions: [FileRegion] {
    let regionRanges = contents.rangesDelimitedBy("// swift-lint:begin-context", end: "// swift-lint:end-context")
  
    let topLevelCommands = ConfigurationCommand.commandsIn(self).filter { (command: (ConfigurationCommand, Int)) -> Bool in
      none(regionRanges.map { NSLocationInRange(command.1, $0)})
    }
    let subfiles = flatten(regionRanges.map { self.subfile($0) } )
    
    return [FileRegion(file: self, commands: topLevelCommands.map { $0.0 })] + subfiles.flatMap { $0.configuredRegions }
  }
}

extension String {
  func trim(charactersInSet: NSCharacterSet = NSCharacterSet.whitespaceCharacterSet()) -> String {
    return "".join(self.componentsSeparatedByCharactersInSet(charactersInSet))
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

func flatten<T>(xs: [T?]) -> [T] {
  return xs.reduce([]) {
    if let e = $1 {
      return $0 + [e]
    }
    
    return $0
  }
}

func any(xs: [Bool]) -> Bool {
  return xs.reduce(false) {
    $0 || $1
  }
}

func none(xs: [Bool]) -> Bool {
  return !any(xs)
}

public enum ConfigurationCommand {
  case EnableRule(String)
  case DisableRule(String)
  case NoOp
  
  static func commandsIn(file: File) -> [(ConfigurationCommand, Int)] {
    let optionals = map(file.contents.lines()) { ConfigurationCommand.command($0) }
    return flatten(optionals)
  }
  
  static func command(line: Line) -> (ConfigurationCommand, Int)? {
    let commandPrefix = "// swift-lint:"
    if line.content.trim() == commandPrefix {
      return (NoOp, line.index)
    }
    
    return nil
  }
}

public struct Linter {
    private let file: File

    public var styleViolations: [StyleViolation] {
        return reduce(
            [
                LineLengthRule().validateFile(file),
                LeadingWhitespaceRule().validateFile(file),
                TrailingWhitespaceRule().validateFile(file),
                TrailingNewlineRule().validateFile(file),
                ForceCastRule().validateFile(file),
                FileLengthRule().validateFile(file),
                TodoRule().validateFile(file),
                ColonRule().validateFile(file),
                TypeNameRule().validateFile(file),
                VariableNameRule().validateFile(file),
                TypeBodyLengthRule().validateFile(file),
                FunctionBodyLengthRule().validateFile(file),
                NestingRule().validateFile(file)
            ], [], +)
    }

    /**
    Initialize a Linter by passing in a File.

    :param: file File to lint.
    */
    public init(file: File) {
        self.file = file
    }
}
