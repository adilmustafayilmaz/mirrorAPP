//
//  CameraManager.swift
//  mirrorAPP
//
//  Created by adilmustafayilmaz on 12.02.2026.
//

import AVFoundation
import AppKit
import Combine

/// Kamera oturumunu yoneten sinif.
/// AVCaptureSession baslatir ve CameraPreviewView'a baglanir.
@MainActor
class CameraManager: NSObject, ObservableObject {
    let captureSession = AVCaptureSession()
    @Published var isRunning = false
    @Published var permissionGranted = false

    override init() {
        super.init()
        checkPermission()
    }

    // MARK: - Izin Kontrolu

    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    self?.permissionGranted = granted
                    if granted {
                        self?.setupSession()
                    }
                }
            }
        default:
            permissionGranted = false
        }
    }

    // MARK: - Oturum Kurulumu

    private func setupSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .medium

        guard let camera = AVCaptureDevice.default(for: .video) else {
            print("Kamera bulunamadi")
            captureSession.commitConfiguration()
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Kamera girisi eklenemedi: \(error.localizedDescription)")
        }

        captureSession.commitConfiguration()
    }

    // MARK: - Baslat / Durdur

    func startSession() {
        guard permissionGranted else {
            checkPermission()
            return
        }

        if !captureSession.isRunning {
            let session = captureSession
            nonisolated(unsafe) let weakSelf = self
            Task.detached {
                session.startRunning()
                await MainActor.run {
                    weakSelf.isRunning = true
                }
            }
        }
    }

    func stopSession() {
        if captureSession.isRunning {
            let session = captureSession
            nonisolated(unsafe) let weakSelf = self
            Task.detached {
                session.stopRunning()
                await MainActor.run {
                    weakSelf.isRunning = false
                }
            }
        }
    }
}
