//
//  ContentView.swift
//  mirrorAPP
//
//  Created by adilmustafayilmaz on 12.02.2026.
//

import SwiftUI
import AVFoundation
import AppKit

// MARK: - Ana Arayuz

struct ContentView: View {
    @ObservedObject var cameraManager: CameraManager
    @State private var edgeLightEnabled = false
    @State private var lightIntensity: Double = 0.85
    @State private var lightColor: Color = .white

    private let lightColors: [(String, Color)] = [
        ("Beyaz", .white),
        ("Sicak", Color(red: 1.0, green: 0.9, blue: 0.7)),
        ("Soguk", Color(red: 0.8, green: 0.9, blue: 1.0)),
    ]

    var body: some View {
        ZStack {
            Color.black

            if cameraManager.permissionGranted {
                CameraPreviewRepresentable(captureSession: cameraManager.captureSession)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "camera.badge.ellipsis")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    Text("Kamera izni gerekli")
                        .foregroundColor(.white)
                        .font(.headline)
                    Text("Sistem Ayarlari > Gizlilik > Kamera\nbolumunde mirrorAPP'a izin verin.")
                        .foregroundColor(.gray)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                    Button("Ayarlari Ac") {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }

            // Kenar Isigi Efekti
            if edgeLightEnabled {
                EdgeLightView(color: lightColor, intensity: lightIntensity)
                    .allowsHitTesting(false)
            }

            // Ust bar — kontroller
            VStack {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption)
                    Text("Mirror")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption)
                        .fontWeight(.medium)

                    Spacer()

                    // Isik rengi secici (sadece isik acikken gorunur)
                    if edgeLightEnabled {
                        HStack(spacing: 4) {
                            ForEach(lightColors, id: \.0) { name, color in
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        lightColor = color
                                    }
                                }) {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 10, height: 10)
                                        .overlay(
                                            Circle()
                                                .stroke(lightColor == color ? Color.white : Color.clear, lineWidth: 1.5)
                                        )
                                }
                                .buttonStyle(.plain)
                                .help(name)
                            }
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.black.opacity(0.4))
                        .clipShape(Capsule())
                    }

                    // Kenar Isigi toggle butonu
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            edgeLightEnabled.toggle()
                        }
                    }) {
                        Image(systemName: edgeLightEnabled ? "light.max" : "light.min")
                            .foregroundColor(edgeLightEnabled ? .yellow : .white.opacity(0.6))
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.plain)
                    .help("Kenar Isigi")

                    // Kapat butonu
                    Button(action: {
                        NSApplication.shared.terminate(nil)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                Spacer()

                // Alt bar — isik siddeti slider (sadece isik acikken)
                if edgeLightEnabled {
                    HStack(spacing: 8) {
                        Image(systemName: "light.min")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.system(size: 10))

                        Slider(value: $lightIntensity, in: 0.3...1.0)
                            .tint(lightColor)
                            .frame(maxWidth: 160)

                        Image(systemName: "light.max")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.system(size: 10))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(.black.opacity(0.5))
                    .clipShape(Capsule())
                    .padding(.bottom, 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .frame(width: 480, height: 360)
    }
}

// MARK: - Kenar Isigi Efekti

struct EdgeLightView: View {
    let color: Color
    let intensity: Double

    @State private var animateGlow = false

    var body: some View {
        ZStack {
            // Sol kenar
            LinearGradient(
                gradient: Gradient(colors: [color.opacity(intensity), .clear]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 60)
            .frame(maxHeight: .infinity)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Sag kenar
            LinearGradient(
                gradient: Gradient(colors: [.clear, color.opacity(intensity)]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 60)
            .frame(maxHeight: .infinity)
            .frame(maxWidth: .infinity, alignment: .trailing)

            // Ust kenar
            LinearGradient(
                gradient: Gradient(colors: [color.opacity(intensity), .clear]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity, alignment: .top)

            // Alt kenar
            LinearGradient(
                gradient: Gradient(colors: [.clear, color.opacity(intensity)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity, alignment: .bottom)

            // Koselerden parlama efekti
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(intensity * 0.6), lineWidth: animateGlow ? 3 : 2)
                .blur(radius: animateGlow ? 12 : 8)
                .padding(2)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animateGlow = true
            }
        }
    }
}

// MARK: - Kamera Onizleme (NSViewRepresentable)

struct CameraPreviewRepresentable: NSViewRepresentable {
    let captureSession: AVCaptureSession

    func makeNSView(context: Context) -> CameraPreviewNSView {
        let view = CameraPreviewNSView()
        view.previewLayer.session = captureSession
        return view
    }

    func updateNSView(_ nsView: CameraPreviewNSView, context: Context) {
        nsView.previewLayer.session = captureSession
    }
}

/// AVCaptureVideoPreviewLayer barindiran NSView.
/// Goruntu ayna gibi (mirrored) gosterilir.
class CameraPreviewNSView: NSView {
    let previewLayer = AVCaptureVideoPreviewLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayer()
    }

    private func setupLayer() {
        wantsLayer = true

        previewLayer.videoGravity = .resizeAspectFill

        // Ayna efekti — goruntuyu yatay cevirir (gercek ayna gibi)
        previewLayer.transform = CATransform3DMakeScale(-1, 1, 1)

        layer?.addSublayer(previewLayer)
    }

    override func layout() {
        super.layout()
        previewLayer.frame = bounds
    }
}
