//
//  main.swift
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

func main(args: [String]) throws -> Int32 {
    guard args.count == 3 else {
        let bin = (args[0] as NSString).lastPathComponent
        print("Usage: \(bin) <project> <spec-file>", to: &stderr)
        return 1
    }
    
    return
        Validator.validate(targetMembership: try TargetMembership(projectPath: Path(args[1])),
                           specs: try MemberSpec.read(from: Path(args[2])))
            ? 0 : 1
}

do {
    exit(try main(args: CommandLine.arguments))
}
catch {
    print("Error: \(error)", to: &stderr)
    exit(1)
}