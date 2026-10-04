import AppKit

if let exportIndex = CommandLine.arguments.firstIndex(of: "--export-icon-dir"),
   CommandLine.arguments.indices.contains(exportIndex + 1) {
    exportSealIcons(to: CommandLine.arguments[exportIndex + 1])
    exit(0)
}

UserDefaults.standard.set(100, forKey: "NSInitialToolTipDelay")
let app = NSApplication.shared
app.applicationIconImage = sealIcon(size: 512, template: false)
let delegate = AppDelegate()
app.delegate = delegate
app.run()
