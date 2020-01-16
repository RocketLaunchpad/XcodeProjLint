//
//  MemberSpec.swift
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

struct MemberSpec: Codable, CustomDebugStringConvertible {

    var targetName: String

    var sourceRoots: [String]

    private func sourceRootPaths(relativeTo specRoot: Path) -> [Path] {
        return sourceRoots.map {
            return specRoot + Path($0)
        }
    }

    func sourcePaths(relativeTo specRoot: Path) throws -> [Path] {
        return try sourceRootPaths(relativeTo: specRoot).flatMap {
            return try $0.recursiveChildren()
        }
        .filter {
            if $0.isDirectory {
                // Only include xcasset directories
                return $0.extension == "xcassets"
            }
            return true
        }
        .filter {
            return Constants.includeExtensions.contains($0.extension)
        }
    }

    static func read(from path: Path) throws -> [MemberSpec] {
        return try JSONDecoder().decode([MemberSpec].self, from: try Data(contentsOf: path.url))
    }

    var debugDescription: String {
        return OutputFormatter.format(prefix: "[Spec]", target: targetName, paths: sourceRoots.map { Path($0) })
    }
}
