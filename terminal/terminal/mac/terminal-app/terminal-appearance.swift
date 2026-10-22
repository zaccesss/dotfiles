// Switches Terminal.app between a dark and a light profile whenever macOS changes between dark and
// light appearance. Terminal.app has no light and dark pair of its own, so this small agent fills
// the gap. It only runs while following the system is turned on, which `zt auto` in the dotfiles
// does; the two profile names come from its arguments and default to the Zacess Deep Contrast pair.
//
// Only tabs already on one of the two profiles or on the earlier High Contrast pair are switched.
// A tab deliberately put on another profile is left alone. Runs as a LaunchAgent.

import Foundation

let arguments = CommandLine.arguments
let darkProfile = arguments.count > 1 ? arguments[1] : "Zacess Deep Contrast Dark"
let lightProfile = arguments.count > 2 ? arguments[2] : "Zacess Deep Contrast Light"
// tabs still on the profiles the Zacess pair replaced move over on the next switch
let earlierProfiles = ["High Contrast Dark", "High Contrast Light"]

func systemIsDark() -> Bool {
    // the global AppleInterfaceStyle key only exists while dark mode is on
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
    task.arguments = ["read", "-g", "AppleInterfaceStyle"]
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = FileHandle.nullDevice
    do { try task.run() } catch { return false }
    task.waitUntilExit()
    let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
    return output.trimmingCharacters(in: .whitespacesAndNewlines) == "Dark"
}

func run(_ executable: String, _ arguments: [String]) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: executable)
    task.arguments = arguments
    task.standardOutput = FileHandle.nullDevice
    task.standardError = FileHandle.nullDevice
    try? task.run()
    task.waitUntilExit()
}

func terminalIsRunning() -> Bool {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/pgrep")
    task.arguments = ["-x", "Terminal"]
    task.standardOutput = FileHandle.nullDevice
    try? task.run()
    task.waitUntilExit()
    return task.terminationStatus == 0
}

func apply() {
    let wanted = systemIsDark() ? darkProfile : lightProfile
    let other = wanted == darkProfile ? lightProfile : darkProfile

    guard terminalIsRunning() else {
        // while Terminal.app is closed its preferences can be written directly; the next window
        // it opens uses them
        run("/usr/bin/defaults", ["write", "com.apple.Terminal", "Default Window Settings", wanted])
        run("/usr/bin/defaults", ["write", "com.apple.Terminal", "Startup Window Settings", wanted])
        return
    }

    let switchFrom = ([other] + earlierProfiles).map { "\"\($0)\"" }.joined(separator: ", ")
    let script = """
    tell application "Terminal"
        set default settings to settings set "\(wanted)"
        set startup settings to settings set "\(wanted)"
        repeat with w in windows
            repeat with t in tabs of w
                if name of current settings of t is in {\(switchFrom)} then
                    set current settings of t to settings set "\(wanted)"
                end if
            end repeat
        end repeat
    end tell
    """
    run("/usr/bin/osascript", ["-e", script])
}

apply()
DistributedNotificationCenter.default().addObserver(
    forName: Notification.Name("AppleInterfaceThemeChangedNotification"), object: nil, queue: .main
) { _ in
    // the appearance key is written a moment after the notification arrives
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { apply() }
}
RunLoop.main.run()
