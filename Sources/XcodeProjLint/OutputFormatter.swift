//
//  OutputFormatter.swift
//  XcodeProjLint
//
//  Created by Calnan, Paul on 1/14/20.
//

import Foundation
import PathKit

struct OutputFormatter {
    static func formatError(message: String) -> String {
        return "error: \(message)"
    }

    static func formatError(in path: Path, line: Int, message: String) -> String {
        return "\(path): error: \(message)"
    }

    static func format(prefix: String, target: String, paths: [Path]) -> String {
        let formattedPaths = paths.map({ $0.absolute().description }).sorted().joined(separator: ",\n")
        return "\(prefix) \(target): [\n\(formattedPaths)\n]"
    }
}
