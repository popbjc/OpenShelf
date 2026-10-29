/// The wheels that can be summoned during a drag.
enum WheelKind: CaseIterable, Hashable {
    case convert
    case tools
    case actions

    var title: String {
        switch self {
        case .convert: L("Convert wheel")
        case .tools: L("Tools wheel")
        case .actions: L("Actions wheel")
        }
    }
}

/// An entry on the Actions wheel.
enum FileAction: CaseIterable {
    case newShelf
    case addToShelf
    case airDrop
    case copy
    case move
    case copyPath
    case terminal

    var title: String {
        switch self {
        case .newShelf: L("Shelf")
        case .addToShelf: L("Add to Shelf")
        case .airDrop: "AirDrop"
        case .copy: L("Copy")
        case .move: L("Move")
        case .copyPath: L("Copy Path")
        case .terminal: L("Terminal")
        }
    }

    var systemImage: String {
        switch self {
        case .newShelf: "tray.and.arrow.down"
        case .addToShelf: "tray.full"
        case .airDrop: "airplayaudio"
        case .copy: "doc.on.doc"
        case .move: "folder"
        case .copyPath: "link"
        case .terminal: "terminal"
        }
    }
}

/// What dropping on a wedge does.
enum WheelCommand: Hashable {
    case action(FileAction)
    case convert(OutputFormat)
    case tool(FileTool)
}

/// One wedge on a wheel.
struct WheelItem: Identifiable, Hashable {
    let command: WheelCommand
    let title: String
    /// Text-only wedges (output formats) show a larger label instead of an icon.
    let systemImage: String?
    /// The app that saves this format (Pages, Numbers, Keynote), whose icon
    /// the wedge shows above its label.
    var appIconPath: String? = nil

    var id: WheelCommand { command }

    static func action(_ action: FileAction) -> WheelItem {
        WheelItem(command: .action(action), title: action.title, systemImage: action.systemImage)
    }

    static func convert(_ format: OutputFormat) -> WheelItem {
        WheelItem(command: .convert(format), title: format.title, systemImage: nil, appIconPath: format.iWorkFormat?.installedAppURL?.path)
    }

    static func tool(_ tool: FileTool) -> WheelItem {
        WheelItem(command: .tool(tool), title: tool.title, systemImage: tool.systemImage)
    }
}
