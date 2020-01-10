//
//  Validator.swift
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

class Validator {

    static func validate(targetMembership: TargetMembership, specs: [MemberSpec]) -> Bool {
        var result = true
        specs.forEach {
            if !validate(targetMembership: targetMembership, spec: $0) {
                result = false
            }
        }

        return result
    }

    private static func validate(targetMembership: TargetMembership, spec: MemberSpec) -> Bool {
        guard targetMembership.targetNames.contains(spec.targetName) else {
            print("Error: Project does not contain a target named \"\(spec.targetName)\"", to: &stderr)
            return false
        }

        do {
            let projectFiles = Set(targetMembership.paths(forTargetName: spec.targetName).map { $0.absolute() })
            let specFiles = Set(try spec.sourcePaths().map { $0.absolute() })

            if projectFiles == specFiles {
                return true
            }

            let notInSpec = projectFiles.subtracting(specFiles)
            if !notInSpec.isEmpty {
                print("Unexpected files in target \"\(spec.targetName)\":", to: &stderr)
                print(formatted(paths: notInSpec), to: &stderr)
            }

            let notInProject = specFiles.subtracting(projectFiles)
            if !notInProject.isEmpty {
                print("Missing files expected in target \"\(spec.targetName)\":", to: &stderr)
                print(formatted(paths: notInProject), to: &stderr)
            }
        }
        catch {
            print("Error: \(error)")
        }

        return false
    }

    private static func formatted<T>(paths: T) -> String where T: Sequence, T.Element == Path {
        return paths.sorted().map({ path -> String in
            "  \(path)"
        })
        .joined(separator: "\n")
    }
}
