//
//  mirrorAPPApp.swift
//  mirrorAPP
//
//  Created by adilmustafayilmaz on 12.02.2026.
//

import SwiftUI
import AppKit
import ServiceManagement

@main
struct mirrorAPPApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

// MARK: - AppDelegate

class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private let cameraManager = CameraManager()

    // Login item durumu
    private var launchAtLogin: Bool {
        SMAppService.mainApp.status == .enabled
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Login item olarak kaydet (ilk calistirmada)
        registerLaunchAtLoginIfNeeded()

        // Menu bar ikonu olustur
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "camera.fill", accessibilityDescription: "Mirror")
            button.target = self
            button.action = #selector(togglePopover)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Popover ayarlari
        popover = NSPopover()
        popover.contentSize = NSSize(width: 480, height: 360)
        popover.behavior = .transient
        popover.delegate = self
        popover.contentViewController = NSHostingController(rootView: ContentView(cameraManager: cameraManager))
    }

    // MARK: - Menu Bar Aksiyonlari

    @objc func togglePopover(_ sender: NSStatusBarButton?) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            toggleCameraPopover()
        }
    }

    private func toggleCameraPopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
            cameraManager.stopSession()
        } else {
            cameraManager.startSession()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    private func showContextMenu() {
        let menu = NSMenu()

        // Giris'te Baslat toggle
        let launchItem = NSMenuItem(
            title: "Giris'te Baslat",
            action: #selector(toggleLaunchAtLogin),
            keyEquivalent: ""
        )
        launchItem.target = self
        launchItem.state = launchAtLogin ? .on : .off
        menu.addItem(launchItem)

        menu.addItem(NSMenuItem.separator())

        // Cikis
        let quitItem = NSMenuItem(
            title: "Cikis",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        // Menu kapandiktan sonra tekrar popover calissin
        statusItem.menu = nil
    }

    // MARK: - Launch at Login

    private func registerLaunchAtLoginIfNeeded() {
        let hasLaunchedKey = "hasRegisteredLaunchAtLogin"

        if !UserDefaults.standard.bool(forKey: hasLaunchedKey) {
            do {
                try SMAppService.mainApp.register()
                UserDefaults.standard.set(true, forKey: hasLaunchedKey)
            } catch {
                print("Login item kaydedilemedi: \(error.localizedDescription)")
            }
        }
    }

    @objc func toggleLaunchAtLogin() {
        do {
            if launchAtLogin {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            print("Login item degistirilemedi: \(error.localizedDescription)")
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Popover Delegate

    func popoverDidClose(_ notification: Notification) {
        cameraManager.stopSession()
    }
}
