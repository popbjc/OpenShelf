import Foundation

/// Turns tool and file-system failures into messages a person can act on,
/// without raw tool output or temporary paths.
enum FailureMessage {
    /// The error to show for a failed conversion of `source`. Errors that are
    /// already user-facing pass through unchanged.
    static func describe(_ error: Error, source: URL) -> Error {
        if error is CancellationError || error is ConversionError || error is MissingToolError { return error }
        let kind = FileKind(url: source)
        let text = (error as? ProcessFailure)?.message ?? error.localizedDescription

        if let message = message(forToolOutput: text, source: source, kind: kind) {
            return ConversionError.failed(message)
        }
        let folder = source.deletingLastPathComponent()
        if !FileManager.default.isWritableFile(atPath: folder.path) {
            return ConversionError.failed(permissionMessage(for: folder))
        }
        if error is ProcessFailure {
            return ConversionError.failed(LF("“%@” couldn’t be converted: %@", String(describing: source.lastPathComponent), String(describing: sanitized(text))))
        }
        return error
    }

    /// A plain explanation for known failure text from a tool or the system,
    /// or nil when nothing specific applies.
    static func message(forToolOutput text: String, source: URL, kind: FileKind) -> String? {
        let lowered = text.lowercased()
        let name = source.lastPathComponent
        func mentions(_ phrases: String...) -> Bool { phrases.contains { lowered.contains($0) } }

        if mentions("permission denied", "operation not permitted", "read-only file system", "cannot open output file", "don’t have permission", "don't have permission") {
            return permissionMessage(for: source.deletingLastPathComponent())
        }
        if mentions("no space left") {
            return L("There isn’t enough free space to save the result.")
        }
        if kind == .archive {
            if mentions("password", "encryption key", "passphrase", "encrypted") {
                return LF("“%@” is password-protected; OpenShelf can’t open encrypted archives.", String(describing: name))
            }
            if mentions("pkzip signature", "unrecognized archive format", "not in gzip format", "damaged", "truncated",
                        "central directory", "unexpected end", "invalid", "error reading") {
                return LF("“%@” is damaged or isn’t an archive OpenShelf can open.", String(describing: name))
            }
        }
        if mentions("invalid data found", "moov atom not found", "could not find codec", "end of file", "unknown format") {
            return LF("“%@” is damaged or in a format OpenShelf can’t read.", String(describing: name))
        }
        return nil
    }

    static func permissionMessage(for folder: URL) -> String {
        LF("You don’t have permission to save in “%@”.", String(describing: folder.lastPathComponent))
    }

    /// Tool output with temporary paths replaced and the tool's name prefix removed.
    static func sanitized(_ text: String) -> String {
        var result = text.replacingOccurrences(
            of: #"'?(/private)?/(var/folders|tmp|private/var/folders)/[^\s']*'?"#,
            with: L("a temporary file"),
            options: .regularExpression
        )
        result = result.replacingOccurrences(of: #"^[A-Za-z0-9_-]+:\s*"#, with: "", options: .regularExpression)
        result = result.replacingOccurrences(of: L("Error!"), with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        return result.isEmpty ? L("the tool reported an error.") : result
    }
}
