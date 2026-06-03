import SwiftUI

enum RegisterTutorialView: Int {
    case tutorialPresence = 0
    case tutorialAbsence = 1
    case completed = 2
}

struct OnboardingOverlayView: View {
    @Binding var hasCompletedTutorial: Bool
    var sliderFrame: CGRect
    
    @State private var handOffset: CGFloat = 0
    @State private var handOpacity: Double = 1
    @State var currentTutorialStep: RegisterTutorialView = .tutorialPresence
    @State private var animationTask: Task<Void, Never>? = nil
    @State private var isExiting = false
    
    private var tutorialTitle: String {
        currentTutorialStep == .tutorialPresence ? "Registrar Presença" : "Justificar Falta"
    }
    
    private var tutorialDescription: String {
        currentTutorialStep == .tutorialPresence
        ? "Para registrar sua presença, deslize o Memoji para a direita."
        : "Para justificar uma ausência, deslize o Memoji para a esquerda."
    }
    
    private var handTargetOffset: CGFloat {
        currentTutorialStep == .tutorialPresence ? 120 : -120
    }
    
    private var arrowDirection: String {
        currentTutorialStep == .tutorialPresence ? "arrow.right" : "arrow.left"
    }
    
    private var sliderMidX: CGFloat { sliderFrame.midX }
    private var sliderMidY: CGFloat { sliderFrame.midY }
    
    private let gradientColors: LinearGradient = LinearGradient(gradient: Gradient(colors: [
            Color.gradientStart,
            Color.gradientEnd]),
            startPoint: .leading,
            endPoint: .trailing
    )
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(spacing: 12) {
                
                HStack{
                    Text("Bem-vindo ao")
                        .font(.title.bold())
                        .foregroundColor(.white)
                    Text("Stemp!")
                        .font(.title.bold())
                        .foregroundStyle(gradientColors)
                }
                
                Group {
                    Text(tutorialTitle)
                        .font(.title2.bold())
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(tutorialDescription)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .id(currentTutorialStep)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: currentTutorialStep == .tutorialPresence ? .leading : .trailing).combined(with: .opacity),
                        removal: .move(edge: currentTutorialStep == .tutorialPresence ? .trailing : .leading).combined(with: .opacity)
                    )
                )
                
            }
            .position(x: sliderMidX, y: sliderMidY - 270)
            
            // Slider simulado com animação da mão — posicionado onde o slider real fica
            ZStack {
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: sliderFrame.width, height: sliderFrame.height)
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1.5)
                    )
                
                // Ícone direita (igual ao PresenceSlider)
                HStack {
                    Spacer()
                    ZStack {
                        Circle().fill(.white.opacity(0.07)).frame(width: 62, height: 62)
                        Image(systemName: "person.fill.checkmark")
                            .resizable().scaledToFit()
                            .frame(width: 34, height: 34)
                            .foregroundColor(.white.opacity(0.75))
                    }
                }
                .frame(width: sliderFrame.width - 10, height: sliderFrame.height)
                
                // Ícone esquerda
                HStack {
                    ZStack {
                        Circle().fill(.white.opacity(0.07)).frame(width: 62, height: 62)
                        Image(systemName: "doc.text.fill")
                            .resizable().scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white.opacity(0.75))
                    }
                    Spacer()
                }
                .frame(width: sliderFrame.width - 10, height: sliderFrame.height)
                
                // Mão animada
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "hand.point.up.left.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                    
                    Image(systemName: arrowDirection)
                        .foregroundColor(.white.opacity(0.7))
                        .font(.system(size: 13, weight: .bold))
                        .offset(x: currentTutorialStep == .tutorialPresence ? 45 : -45)
                }
                .offset(x: handOffset)
                .opacity(handOpacity)
            }
            .position(x: sliderFrame.midX, y: sliderFrame.midY)
            
            // Botão abaixo do slider
            YellowButtonView(
                disabled: .constant(false),
                text: currentTutorialStep == .tutorialPresence ? "Próximo" : "Entendi!",
                iconImage: nil
            ) {
                handleNextStep()
            }
            .padding(.horizontal, 24)
            .position(x: sliderFrame.midX, y: sliderFrame.midY + 100)

        }
        .opacity(isExiting ? 0 : 1)
        .scaleEffect(isExiting ? 0.92 : 1)
        .animation(.easeOut(duration: 0.5), value: isExiting)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                startAnimation()
            }
        }
    }
    
    private func startAnimation() {
        // Cancela qualquer animação pendente antes de começar nova
        animationTask?.cancel()
        
        animationTask = Task {
            // Reset imediato
            await MainActor.run {
                handOffset = 0
                handOpacity = 1
            }
            
            // Fase 1: aguarda delay inicial
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s
            guard !Task.isCancelled else { return }
            
            // Fase 2: desliza
            await MainActor.run {
                withAnimation(.easeInOut(duration: 1.2)) {
                    handOffset = handTargetOffset
                }
            }
            
            // Fase 3: aguarda animação terminar
            try? await Task.sleep(nanoseconds: 1_200_000_000) // 1.2s
            guard !Task.isCancelled else { return }
            
            // Fase 4: fade out
            await MainActor.run {
                withAnimation(.easeIn(duration: 0.3)) {
                    handOpacity = 0
                }
                
            }
            
            // Fase 5: aguarda fade out
            try? await Task.sleep(nanoseconds: 600_000_000) // 0.3s
            guard !Task.isCancelled else { return }
            
            // Fase 6: reseta posição (invisível)
            await MainActor.run {
                handOffset = 0
            }
            
            await MainActor.run {
                withAnimation(.easeIn(duration: 0.6)) {
                    handOpacity = 1
                }
            }
            
            // Fase 8: aguarda e repete
            try? await Task.sleep(nanoseconds: 350_000_000) // 0.35s
            guard !Task.isCancelled else { return }
            
            startAnimation()
        }
    }
    
    private func handleNextStep() {
        if currentTutorialStep == .tutorialPresence {
            animationTask?.cancel()
            animationTask = nil
            
            // Reset síncrono ANTES de qualquer animação nova
            handOpacity = 0
            handOffset = 0
            
            withAnimation(.easeInOut(duration: 0.35)) {
                currentTutorialStep = .tutorialAbsence
            }
            
            // Tempo suficiente para a transição do step terminar
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                startAnimation()
            }
        } else {
            animationTask?.cancel()
            animationTask = nil

            isExiting = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                hasCompletedTutorial = true
            }
        }
    }
}

#Preview {
    
}

