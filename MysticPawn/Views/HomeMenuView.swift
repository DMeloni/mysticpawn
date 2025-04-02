import SwiftUI

struct HomeMenuView: View {
    @ObservedObject var game: ChessGame
    @Binding var currentView: AppView
    
    var body: some View {
        ZStack {
            // Arrière-plan texturé
            AppColors.background
                .overlay(
                    WoodGrainOverlay()
                        .opacity(0.1)
                )
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Logo/Titre
                VStack(spacing: 10) {
                    Image("logo_menu")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 280)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 3)
                
                }
                .padding(.top, 60)
                
                // Petit échiquier décoratif
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: game.selectedTheme.borderColor).opacity(0.8),
                                    Color(hex: game.selectedTheme.borderColor).opacity(0.9)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 3)
                    
                    // Mini échiquier 4x4
                    VStack(spacing: 0) {
                        ForEach(0...3, id: \.self) { row in
                            HStack(spacing: 0) {
                                ForEach(0...3, id: \.self) { col in
                                    Rectangle()
                                        .fill((row + col) % 2 == 1 ? 
                                              Color(hex: game.selectedTheme.lightSquareColor) : 
                                              Color(hex: game.selectedTheme.darkSquareColor))
                                        .frame(width: 25, height: 25)
                                }
                            }
                        }
                    }
                    .padding(5)
                }
                .padding(.bottom, 50)
                
                // Boutons du menu principal
                VStack(spacing: 20) {
                    MenuButtonView(title: "Jouer", icon: "play.fill") {
                        withAnimation {
                            currentView = .timerSelection
                        }
                    }
                    
                    MenuButtonView(title: "Paramètres", icon: "gear") {
                        withAnimation {
                            currentView = .settings
                        }
                    }
                    
                    MenuButtonView(title: "Classement", icon: "trophy.fill") {
                        withAnimation {
                            // Action pour le classement (à implémenter)
                        }
                    }
                    
                    MenuButtonView(title: "Quitter", icon: "power") {
                        // Quitter l'application
                        #if os(iOS)
                        exit(0)
                        #endif
                    }
                }
                
                Spacer()
                
                // Version de l'application
                Text("v1.0")
                    .font(.caption)
                    .foregroundColor(AppColors.accent.opacity(0.5))
                    .padding(.bottom, 10)
            }
            .padding(.horizontal, 30)
        }
    }
}

struct MenuButtonView: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .frame(width: 30, height: 30)
                    .foregroundColor(AppColors.textLight)
                
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppColors.textLight)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textLight.opacity(0.7))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppColors.woodMedium,
                        AppColors.woodDark
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 3)
        }
    }
} 
