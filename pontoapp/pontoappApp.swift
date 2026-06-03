//
//  pontoappApp.swift
//  pontoapp
//
//  Created by Joao Carlos Lima on 05/11/24.
//

import SwiftUI

@main
struct PontoApp: App {

    @State private var showSplash = true
    @State private var contentOpacity: Double = 0

    @StateObject private var registrationViewModel = RegistrationViewModel()
    @StateObject private var eventsViewModel = EventsViewModel()

    init(){
        //para inicializar o bluetoothManager antes de iniciar o app
        _ = BluetoothManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // ContentView faz fade in enquanto splash sai
                ContentView()
                    .environmentObject(registrationViewModel)
                    .environmentObject(eventsViewModel)
                    .opacity(contentOpacity)

                if showSplash {
                    SplashScreenViewWrapper(
                        registrationViewModel: registrationViewModel,
                        onFinish: {
                            // 1. ContentView aparece
                            withAnimation(.easeOut(duration: 0.4)) {
                                contentOpacity = 1
                            }
                            // 2. Remove a splash do ZStack depois do fade
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                showSplash = false
                            }
                        }
                    )
                    .zIndex(1)
                }
            }
        }
    }
}

// MARK: - Wrapper para controlar o ciclo de vida da splash
struct SplashScreenViewWrapper: View {

    let registrationViewModel: RegistrationViewModel
    let onFinish: () -> Void

    @State private var exitScale: CGFloat = 1.0
    @State private var exitOpacity: Double = 1.0
    @State private var labelOpacity: Double = 0
    @State private var labelOffset: CGFloat = 12
    @State private var topPieceVisible    = false
    @State private var bottomPieceVisible = false
    @State private var impactScale: CGFloat = 1.0
    @AppStorage("studentId") private var studentId: String = ""
    @AppStorage("hasSelectedMemoji") private var hasSelectedMemoji: Bool = false

    var body: some View {
        ZStack {
            Color.bg950.ignoresSafeArea()

            ZStack {
                Image("Logo azul")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .opacity(topPieceVisible ? 1 : 0)
                    .offset(
                        x: topPieceVisible ? 0 : -120,
                        y: topPieceVisible ? 0 : -120
                    )

                Image("Logo amarelo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .opacity(bottomPieceVisible ? 1 : 0)
                    .offset(
                        x: bottomPieceVisible ? 0 :  120,
                        y: bottomPieceVisible ? 0 :  120
                    )
            }
            .frame(width: 200, height: 200)
            .scaleEffect(impactScale * exitScale)
            .offset(y: -40)

            VStack(spacing: 6) {
                Spacer()
                VStack(spacing: 6) {
                    Text("STEMP")
                        .font(.system(size: 26, weight: .bold))
                        .tracking(2)
                        .foregroundColor(Color(hex: "#0A4D9A"))

                    Text("Apple Developer Academy")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(Color(hex: "#999999"))
                        .textCase(.uppercase)
                }
                .opacity(labelOpacity)
                .offset(y: labelOffset)
                .padding(.bottom, 100)
            }
        }
        .opacity(exitOpacity)
        .onAppear {
            startEntrance()
            
            registrationViewModel.loadInitialData()

            if !hasSelectedMemoji {
                VideoPreloader.shared.preload(videoName: "memojiVideo2", videoType: "mp4")
            }
            
            // Dispara a saída depois de 2.8s
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                playExit()
            }
        }
    }

    // MARK: - Animação de entrada
    private func startEntrance() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.7).delay(0.3)) {
            topPieceVisible = true
        }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.7).delay(0.45)) {
            bottomPieceVisible = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            withAnimation(.spring(response: 0.18, dampingFraction: 0.4)) { impactScale = 0.93 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.45)) { impactScale = 1.07 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) { impactScale = 1.0 }
                }
            }
        }
        withAnimation(.easeOut(duration: 0.6).delay(1.55)) {
            labelOpacity = 1
            labelOffset  = 0
        }
    }

    // MARK: - Animação de saída
    private func playExit() {
        // Logo escala e some
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            exitScale = 1.3
        }
        // Label desce e some
        withAnimation(.easeIn(duration: 0.3)) {
            labelOpacity = 0
            labelOffset  = 20
        }
        // Tela toda faz fade out
        withAnimation(.easeIn(duration: 0.45).delay(0.1)) {
            exitOpacity = 0
        }
        // Avisa o PontoApp que acabou
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            onFinish()
        }
    }
}
