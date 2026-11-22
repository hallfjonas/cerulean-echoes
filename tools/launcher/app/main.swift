// Cerulean Echoes: the player in its own window, no browser. One double-click starts the player (the server in
// tools/trajectory, which starts SuperCollider when a track plays) and shows it in a window (WKWebView). The red close
// button only hides the window (the music goes on; a click on the Dock icon shows it again); Quit (Cmd-Q, Dock: Quit)
// stops the player and SuperCollider. A force quit or crash stops them too (launch.sh start --watch).
// The work is done by tools/launcher/launch.sh; tools/launcher/build.sh compiles this file into "Cerulean Echoes.app".
// The window shows the page only: MIDI goes from the Launch Controls to SuperCollider, never through the window, so if
// the window hangs or reloads, the music and the controllers keep running. WKWebView has no Web MIDI: Strudel tracks
// get no controllers here (auto-perform still works); SC tracks are unaffected.
import Cocoa
import WebKit

// <repo>/Cerulean Echoes.app → <repo>/tools/launcher/launch.sh
let launchSh = Bundle.main.bundleURL.deletingLastPathComponent().appendingPathComponent("tools/launcher/launch.sh").path
// the launcher's test: no window (as no browser tab before)
let headless = ProcessInfo.processInfo.environment["CE_NO_BROWSER"] == "1"

struct Result { let code: Int32; let out: String; let err: String }
func launch(_ args: [String]) -> Result {
	let p = Process(), out = Pipe(), err = Pipe()
	p.executableURL = URL(fileURLWithPath: "/bin/bash")
	p.arguments = [launchSh] + args
	p.standardOutput = out; p.standardError = err; p.standardInput = FileHandle.nullDevice
	do { try p.run() } catch { return Result(code: 127, out: "", err: "\(error)") }
	let o = out.fileHandleForReading.readDataToEndOfFile(), e = err.fileHandleForReading.readDataToEndOfFile()
	p.waitUntilExit()
	let text = { (d: Data) in String(decoding: d, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines) }
	return Result(code: p.terminationStatus, out: text(o), err: text(e))
}

final class App: NSObject, NSApplicationDelegate, NSWindowDelegate, WKUIDelegate, WKNavigationDelegate {
	var window: NSWindow!
	var web: WKWebView!
	var address: URL?
	var aliveTimer: Timer?
	var stopping = false
	// no App Nap and no timer throttling while the player runs (the page's clock, Strudel audio)
	var activity: NSObjectProtocol?

	func applicationDidFinishLaunching(_ note: Notification) {
		activity = ProcessInfo.processInfo.beginActivity(options: [.userInitiated, .latencyCritical],
			reason: "Cerulean Echoes plays live")
		buildMenu()
		buildWindow()
		status("Starting the player …")
		DispatchQueue.global().async { self.start() }
	}

	func start() {
		let check = launch(["check"])
		if check.code != 0 { return fail("Cerulean Echoes cannot start", check.err.isEmpty ? check.out : check.err) }
		if check.out == "install" {
			DispatchQueue.main.async { self.status("First start: installing the player's helpers, about 1-2 minutes …") }
			let install = launch(["install"])
			if install.code != 0 { return fail("Cerulean Echoes cannot start", install.err) }
		}
		let started = launch(["start", "--no-browser", "--watch", String(ProcessInfo.processInfo.processIdentifier)])
		if started.code != 0 { return fail("Cerulean Echoes cannot start", started.err) }
		let url = launch(["url"]).out
		DispatchQueue.main.async {
			self.address = URL(string: url)
			if let a = self.address { self.web.load(URLRequest(url: a)) }
			// every 5 s: did the player end by itself? (alive: 1 = ended, 3 = not ours, e.g. one that already ran)
			self.aliveTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
				DispatchQueue.global().async {
					if launch(["alive"]).code == 1 {
						self.fail("The player stopped", "Start Cerulean Echoes again. Details: ~/Library/Logs/cerulean-echoes.log")
					}
				}
			}
		}
	}

	// an alert, then quit (from any thread)
	func fail(_ title: String, _ text: String) {
		DispatchQueue.main.async {
			if self.stopping { return }
			self.aliveTimer?.invalidate()
			let alert = NSAlert()
			alert.alertStyle = .critical; alert.messageText = title; alert.informativeText = text
			alert.runModal()
			NSApp.terminate(nil)
		}
	}

	func status(_ text: String) {
		let html = """
		<html><body style="margin:0;height:100vh;display:flex;align-items:center;justify-content:center;
		font:15px -apple-system,sans-serif;color:#888;background:#111">\(text)</body></html>
		"""
		web.loadHTMLString(html, baseURL: nil)
	}

	func buildWindow() {
		let config = WKWebViewConfiguration()
		config.mediaTypesRequiringUserActionForPlayback = []   // audio may start without a click (Strudel tracks)
		config.preferences.setValue(true, forKey: "developerExtrasEnabled")   // right click: Inspect Element
		web = WKWebView(frame: .zero, configuration: config)
		web.uiDelegate = self; web.navigationDelegate = self
		window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1400, height: 900),
			styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
		window.title = "Cerulean Echoes"
		window.contentView = web
		window.collectionBehavior = [.fullScreenPrimary]
		window.isReleasedWhenClosed = false
		window.delegate = self
		window.center()
		window.setFrameAutosaveName("PlayerWindow")   // size, place and monitor are kept between starts
		window.backgroundColor = .black
		if !headless { window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true) }
	}

	func buildMenu() {
		let main = NSMenu()
		func menu(_ title: String, _ items: [NSMenuItem]) {
			let item = NSMenuItem(); let sub = NSMenu(title: title)
			items.forEach(sub.addItem); item.submenu = sub; main.addItem(item)
		}
		func item(_ title: String, _ action: Selector?, _ key: String, _ mods: NSEvent.ModifierFlags = .command) -> NSMenuItem {
			let i = NSMenuItem(title: title, action: action, keyEquivalent: key); i.keyEquivalentModifierMask = mods; return i
		}
		menu("Cerulean Echoes", [item("Hide Cerulean Echoes", #selector(NSApplication.hide(_:)), "h"),
			.separator(), item("Quit Cerulean Echoes", #selector(NSApplication.terminate(_:)), "q")])
		// text fields in the page need these for copy and paste
		menu("Edit", [item("Undo", Selector(("undo:")), "z"), item("Redo", Selector(("redo:")), "Z"), .separator(),
			item("Cut", #selector(NSText.cut(_:)), "x"), item("Copy", #selector(NSText.copy(_:)), "c"),
			item("Paste", #selector(NSText.paste(_:)), "v"), item("Select All", #selector(NSText.selectAll(_:)), "a")])
		menu("View", [item("Reload", #selector(reload), "r"),
			item("Enter Full Screen", #selector(NSWindow.toggleFullScreen(_:)), "f", [.command, .control])])
		menu("Window", [item("Minimize", #selector(NSWindow.miniaturize(_:)), "m"),
			item("Show Player", #selector(showWindow), "1")])
		NSApp.mainMenu = main
	}

	@objc func reload() { if let a = address { web.load(URLRequest(url: a)) } }
	@objc func showWindow() { window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true) }

	// the close button hides the window; the player keeps playing
	func windowShouldClose(_ sender: NSWindow) -> Bool { sender.orderOut(nil); return false }
	func applicationShouldHandleReopen(_ app: NSApplication, hasVisibleWindows: Bool) -> Bool {
		if !hasVisibleWindows && !headless { showWindow() }
		return true
	}

	// Quit: stop the player (and SuperCollider) first; launch.sh stop waits up to 10 s
	func applicationShouldTerminate(_ app: NSApplication) -> NSApplication.TerminateReply {
		if stopping { return .terminateCancel }   // already stopping (Cmd-Q twice)
		stopping = true
		aliveTimer?.invalidate()
		DispatchQueue.global().async {
			_ = launch(["stop"])
			DispatchQueue.main.async { NSApp.reply(toApplicationShouldTerminate: true) }
		}
		return .terminateLater
	}

	// page not there (yet, or the server restarted): try again
	func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) { if !self.stopping { self.reload() } }
	}

	// links that open a new window (target=_blank, window.open): the default browser
	func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
		for action: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
		if let url = action.request.url { NSWorkspace.shared.open(url) }
		return nil
	}

	// alert / confirm / prompt and file pickers: WKWebView shows none of them by itself
	func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
		initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
		let a = NSAlert(); a.messageText = message; a.runModal(); completionHandler()
	}
	func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
		initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
		let a = NSAlert(); a.messageText = message; a.addButton(withTitle: "OK"); a.addButton(withTitle: "Cancel")
		completionHandler(a.runModal() == .alertFirstButtonReturn)
	}
	func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?,
		initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
		let a = NSAlert(); a.messageText = prompt; a.addButton(withTitle: "OK"); a.addButton(withTitle: "Cancel")
		let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24)); field.stringValue = defaultText ?? ""
		a.accessoryView = field
		completionHandler(a.runModal() == .alertFirstButtonReturn ? field.stringValue : nil)
	}
	func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters,
		initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
		let panel = NSOpenPanel()
		panel.allowsMultipleSelection = parameters.allowsMultipleSelection
		panel.canChooseDirectories = parameters.allowsDirectories
		completionHandler(panel.runModal() == .OK ? panel.urls : nil)
	}
}

let app = NSApplication.shared
let delegate = App()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
