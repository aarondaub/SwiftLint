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
