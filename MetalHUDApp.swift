import Cocoa
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var window: NSWindow!
    var isEnabled: Bool = false {
        didSet {
            updateButtonState()
        }
    }
    
    let button = NSButton()
    let statusLabel = NSTextField()
    var visualEffectView: NSVisualEffectView!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        createWindow()
        setupUI()
        loadInitialState()
    }
    
    func shell(_ command: String) -> String {
    	let task = Process()
    	let pipe = Pipe()
    
    	task.standardOutput = pipe
    	task.standardError = pipe
    	task.arguments = ["-c", command]
    	task.launchPath = "/bin/zsh"
    	task.standardInput = nil
    	task.launch()
    
    	let data = pipe.fileHandleForReading.readDataToEndOfFile()
    	let output = String(data: data, encoding: .utf8)!
    
    	return output
	}

    func createWindow() {
        let screenSize = NSScreen.main!.frame.size
        window = NSWindow(
            contentRect: NSRect(x: (screenSize.width - 300) / 2, y: (screenSize.height - 200) / 2, width: 300, height: 200),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false)
        
        window.isReleasedWhenClosed = false
        window.title = "Metal HUD"
        window.backgroundColor = NSColor.clear
        window.isOpaque = false
        window.level = .floating
        window.makeKeyAndOrderFront(nil)
        
        window.delegate = self
        
        visualEffectView = NSVisualEffectView(frame: window.contentView!.bounds)
        visualEffectView.autoresizingMask = [.width, .height]
        visualEffectView.material = .popover
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        window.contentView?.addSubview(visualEffectView)
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }

    func setupUI() {
        statusLabel.stringValue = "Metal HUD"
        statusLabel.font = NSFont.systemFont(ofSize: 24, weight: .bold)
        statusLabel.alignment = .center
        statusLabel.isBordered = false
        statusLabel.backgroundColor = .clear
        statusLabel.sizeToFit()
        statusLabel.frame = NSRect(x: 0, y: 100, width: 300, height: 50)
        
        button.title = "OFF"
        button.frame = NSRect(x: 50, y: 50, width: 200, height: 40)
        button.wantsLayer = true
        button.layer?.cornerRadius = 10
        button.layer?.backgroundColor = NSColor.darkGray.cgColor
        button.target = self
        button.action = #selector(toggleHUD)
        
        button.addTrackingArea(NSTrackingArea(rect: button.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil))
        
        window.contentView?.addSubview(visualEffectView)
        window.contentView?.addSubview(statusLabel)
        window.contentView?.addSubview(button)
    }
    
    func getEnvironmentVar(_ name: String) -> String? {
    	guard let rawValue = getenv(name) else { return nil }
    	return String(utf8String: rawValue)
	}
    
    func loadInitialState() {
        if let value = getEnvironmentVar("MTL_HUD_ENABLED"), let intValue = Int(value) {
            isEnabled = intValue == 1
            updateButtonState()
        }
    }
    
    @objc func toggleHUD() {
        isEnabled.toggle()
        let newValue = isEnabled ? 1 : 0

        let sh = shell("/bin/launchctl setenv MTL_HUD_ENABLED \(newValue)")
        print(sh)
        print("set MTL_HUD_ENABLED to \(newValue)")
    }
    
    func updateButtonState() {
        button.title = isEnabled ? "ON" : "OFF"
        button.layer?.backgroundColor = isEnabled ? NSColor.green.cgColor : NSColor.red.cgColor
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.1
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.button.layer?.backgroundColor = self.isEnabled ? NSColor.green.withAlphaComponent(0.8).cgColor : NSColor.red.withAlphaComponent(0.8).cgColor
        }) {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.1
                self.button.layer?.backgroundColor = self.isEnabled ? NSColor.green.cgColor : NSColor.red.cgColor
            })
        }
    }
}

let appDelegate = AppDelegate()
NSApplication.shared.delegate = appDelegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
