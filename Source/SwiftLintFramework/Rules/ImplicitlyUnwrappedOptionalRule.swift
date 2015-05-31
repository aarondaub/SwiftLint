//
//  ImplicitlyUnwrappedOptionalRule.swift
//  SwiftLint
//
//  Created by Aaron Daub on 2015-05-30.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import SourceKittenFramework
import SwiftXPC

struct ImplicitlyUnwrappedOptionalRule: Rule {
    let identifier = "implicitly_unwrapped_optional"
  
    func validateFile(file: File) -> [StyleViolation] {
      return file.matchPattern("([a-z]|[A-Z])+!", withSyntaxKinds: [.Typeidentifier]).map { range
        in
        return StyleViolation(type: .ImplicitlyUnwrappedOptional,
                  location: Location(file: file, offset: range.location),
                  severity: .Low,
                  reason: "Implicitly unwrapped optionals should be avoided")
    }
  }
}
