//
//  ConfigurationCommand.swift
//  SwiftLint
//
//  Created by Aaron Daub on 2015-05-25.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import SourceKittenFramework

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
      return map(command(line.content)) {
        ($0, line.index)
      }
    }
    
    return nil
  }
  
  static func command(string: String) -> ConfigurationCommand? {
    return .NoOp
  }
}