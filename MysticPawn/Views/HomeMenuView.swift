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
                        .frame(width: 320)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 3)
                }
                .padding(.top, 40)
                .padding(.bottom, 20)
                
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
                    // Bouton pour démarrer une partie
                    Button(action: {
                        withAnimation {
                            currentView = .timerSelection
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                                .font(.system(size: 20))
                            Text("Jouer")
                                .font(.headline)
                        }
                        .frame(width: 200)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(Color(hex: "D3A536"))
                        .foregroundColor(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Bouton pour le classement
                    Button(action: {
                        withAnimation {
                            // Naviguer vers la vue des meilleurs scores
                            currentView = .highScores
                        }
                    }) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 20))
                            Text("Classement")
                                .font(.headline)
                        }
                        .frame(width: 200)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(Color(hex: "E8DECD"))
                        .foregroundColor(AppColors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 2)
                    }
                    
                    // Bouton pour les paramètres
                    Button(action: {
                        withAnimation {
                            currentView = .settings
                        }
                    }) {
                        HStack {
                            Image(systemName: "gear")
                                .font(.system(size: 20))
                            Text("Paramètres")
                                .font(.headline)
                        }
                        .frame(width: 200)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(Color(hex: "E8DECD"))
                        .foregroundColor(AppColors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 2)
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .background(
            AppColors.background
                .overlay(
                    WoodGrainOverlay()
                        .opacity(0.1)
                )
        )
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
