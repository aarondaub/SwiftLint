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
      return (command(line.content), line.index)
    }
    
    return nil
  }
  
  static func command(string: String) -> ConfigurationCommand {
    let enableRulePrefix = "// swift-lint:enable-rule"
    let disableRulePrefix = "// swift-lint:disable-rule"
    
    let trimmedString = string.trim()
    
    if trimmedString.hasPrefix(enableRulePrefix) {
      let ruleIdentifier = string.trim().stringByReplacingOccurrencesOfString(enableRulePrefix, withString: "", options: NSStringCompareOptions.allZeros, range: nil)
      return .EnableRule(ruleIdentifier)
    } else if trimmedString.hasPrefix(disableRulePrefix) {
      let ruleIdentifier = string.trim().stringByReplacingOccurrencesOfString(disableRulePrefix, withString: "", options: NSStringCompareOptions.allZeros, range: nil)
      return .DisableRule(ruleIdentifier)
    }
    
    return .NoOp
  }
}

struct Configuration {
  let enabledRules: [Rule]
  let file: File
  
  init(enabledRules: [Rule], file: File) {
    (self.enabledRules, self.file) = (enabledRules, file)
  }
  
  init?(commands: [ConfigurationCommand], baseRules: [Rule], file: File) {
    let ruleMap = Dictionary<String, Int>()
    
    commands.map { (command: ConfigurationCommand) -> Void in
      switch command {
        case .EnableRule(let identifier):
          ruleMap[identifier] == (ruleMap[identifier] ?? 0) + 1
        case .DisableRule(let identifier):
          ruleMap[identifier] == (ruleMap[identifier] ?? 0) + 1
        case .NoOp:
          break
      }
    }
    
    let rulesToEnable = baseRules.filter {
      ruleMap[$0.identifier] ?? 0 > 0
    }

    self = Configuration(enabledRules: rulesToEnable, file: file)

  }
  
    static func generateConfiguration(fileRegion: FileRegion, baseRules: [Rule]) -> [Configuration] {
      let configuration = Configuration(commands: fileRegion.commands,
                                        baseRules: baseRules,
                                        file: fileRegion.file)
  
      var enabledRules = baseRules
      map(configuration) { (configuration: Configuration) -> Void in
        enabledRules = configuration.enabledRules
      }
      
      return flatten([configuration]) + fileRegion.file.configuredRegions.flatMap {
        generateConfiguration($0, baseRules: enabledRules)
      }
    }

}