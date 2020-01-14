//
//  TargetMembership.swift
//  XcodeProjLint
//
//  Copyright (c) 2020 Rocket Insights, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import Foundation
import PathKit
import XcodeProj

/**
 A data structure containing the targets found in the project and a list of paths associated with each target.
 */
class TargetMembership: Encodable, CustomDebugStringConvertible {

    private let storage: [String: [Path]]

    convenience init(projectPath: Path) throws {
        try self.init(sourceRoot: projectPath.parent(), project: try XcodeProj(path: projectPath))
    }

    private convenience init(sourceRoot: Path, project: XcodeProj) throws {
        var storage: [String: [Path]] = [:]

        try project.pbxproj.nativeTargets.forEach { target in
            storage[target.name] = []

            try target.buildPhases.forEach { buildPhase in
                try buildPhase.files?.forEach { buildFile in
                    if let fullPath = try buildFile.file?.fullPath(sourceRoot: sourceRoot), Constants.includeExtensions.contains(fullPath.extension) {
                        storage[target.name]?.append(fullPath)
                    }
                }
            }
        }

        self.init(storage: storage)
    }

    init(storage: [String: [Path]]) {
        self.storage = storage
    }

    func paths(forTargetName targetName: String) -> [Path] {
        return (storage[targetName] ?? []).sorted()
    }

    var targetNames: [String] {
        return storage.keys.sorted()
    }

    var debugDescription: String {
        return targetNames.map {
            OutputFormatter.format(prefix: "[Membership]", target: $0, paths: paths(forTargetName: $0))
        }
        .joined(separator: "\n")
    }
}
