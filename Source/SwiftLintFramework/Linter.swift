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

extension NSRange {
  var end: Int {
    return self.location + self.length
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

public struct Linter {
    private let file: File
    public var styleViolations: [StyleViolation] {
      let baseRules: [Rule] =     [
        LineLengthRule(),
        LeadingWhitespaceRule(),
        TrailingWhitespaceRule(),
        TrailingNewlineRule(),
        ForceCastRule(),
        FileLengthRule(),
        TodoRule(),
        ColonRule(),
        TypeNameRule(),
        VariableNameRule(),
        TypeBodyLengthRule(),
        FunctionBodyLengthRule(),
        NestingRule()
      ]
      
      let configurations = flatMap(file.configuredRegions) {
        Configuration.generateConfiguration($0, baseRules: baseRules)
      }
      return flatMap(configurations) { self.sytleViolations($0) }
    }
  
    func sytleViolations(configuration: Configuration) -> [StyleViolation] {
      return configuration.enabledRules.flatMap {
        $0.validateFile(configuration.file)
      }
    }

    /**
    Initialize a Linter by passing in a File.

    :param: file File to lint.
    */
    public init(file: File) {
        self.file = file
    }
}
