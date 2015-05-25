//
//  FileRegion.swift
//  SwiftLint
//
//  Created by Aaron Daub on 2015-05-25.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import SourceKittenFramework

public struct FileRegion {
  public let file: File
  public let commands: [ConfigurationCommand]
}