import Foundation

/// The text of `key`, looked up in the language bundle next to the app.
///
/// The key is the English text itself, so a missing translation falls back to
/// English instead of showing a raw key. SwiftUI localizes `Text("…")` by
/// itself; this is for the strings that travel through plain `String` values
/// (titles, toasts, error messages) and for the code that builds them.
func L(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}

/// `L(_:)` for text with placeholders: each `%@` in the translation is
/// replaced, in order, by the arguments, so translations can put them in any
/// order the language needs.
func LF(_ key: String, _ args: String...) -> String {
    var text = NSLocalizedString(key, comment: "")
    for arg in args {
        guard let range = text.range(of: "%@") else { break }
        text.replaceSubrange(range, with: arg)
    }
    return text
}
