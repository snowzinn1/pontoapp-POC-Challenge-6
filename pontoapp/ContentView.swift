import SwiftUI

// MARK: - Etapas do onboarding (agora com .welcome)
enum OnboardingStep: Int {
    case welcome  = 0
    case location = 1
    case login    = 2
    case contacts = 3
    case completed
}

struct ContentView: View {
    @AppStorage("appleID") var userId: String?
    @AppStorage("email") var email: String?
    @AppStorage("hasSelectedMemoji") var hasSelectedMemoji: Bool = false
    @AppStorage("hasSeenWelcome") var hasSeenWelcome: Bool = false
    @ObservedObject var locationManager = LocationManager.shared

    private var currentStep: OnboardingStep {
        // App completo
        if userId != nil && locationManager.userLocation != nil && hasSelectedMemoji {
            return .completed
        }
        // Perfil pendente
        if userId != nil && locationManager.userLocation != nil {
            return .contacts
        }
        // Login pendente
        if locationManager.userLocation != nil && !hasSeenWelcome {
            return .welcome
        }
        if locationManager.userLocation != nil {
            return .login
        }
        // Localização pendente
        if !hasSeenWelcome {
            return .welcome
        }
        return .location
    }

    private var stepIndex: Int {
        switch currentStep {
        case .welcome:   return 0
        case .location:  return 1
        case .login:     return 2
        case .contacts:  return 3
        case .completed: return 4
        }
    }

    private var showStepIndicator: Bool {
        currentStep != .completed
    }

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.bg900)
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        ZStack {
            Color.bg950.ignoresSafeArea()

            Group {
                switch currentStep {
                case .welcome:
                    WelcomeView {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            hasSeenWelcome = true
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

                case .location:
                    LocationRequestView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                case .login:
                    LoginView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))

                case .contacts:
                    ProfileSetupView(userEmailApple: email ?? "")
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))

                case .completed:
                    AppTabBarView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.5), value: currentStep)

            // Indicador de progresso — flutua no topo durante o onboarding
            if showStepIndicator {
                VStack {
                    OnboardingStepIndicator(totalSteps: 4, currentStep: stepIndex)
                        .padding(.top, 30)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - AppTabBarView (sem alterações)
struct AppTabBarView: View {
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @EnvironmentObject private var eventsViewModel: EventsViewModel

    var body: some View {
        TabView {
            NavigationStack {
                RegisterView()
                    .environmentObject(registrationViewModel)
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .tabItem {
                Image(systemName: "person.fill.checkmark")
                Text("Registros")
            }

            DashboardView()
                .toolbarColorScheme(.dark, for: .navigationBar)
                .tabItem {
                    Image(systemName: "rectangle.3.offgrid")
                    Text("Dashboard")
                }

            EventsView()
                .badge(eventsViewModel.newEventsCount)
                .environmentObject(eventsViewModel)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Eventos")
                }
            
            NavigationStack{
                SettingsView()
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .tabItem {
                Image(systemName: "person.fill")
                Text("Perfil")
            }
        }
        .accentColor(Color.gradientStart)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
