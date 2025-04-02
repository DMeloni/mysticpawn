import SwiftUI

struct TimerSelectionView: View {
    @ObservedObject var game: ChessGame
    @Binding var currentView: AppView
    
    var body: some View {
        VStack(spacing: 0) {
            // Barre de navigation - positionnée tout en haut
            NavigationBar(
                title: "Configuration de la partie",
                leftAction: {
                    withAnimation {
                        currentView = .home
                    }
                },
                leftIcon: "house.fill",
                rightIcon: "xmark",
                rightAction: {
                    withAnimation {
                        currentView = .home
                    }
                }
            )
            
            // Contenu de la sélection
            VStack(spacing: 30) {
                // Sélection du mode de jeu
                VStack(spacing: 15) {
                    Text("Mode de jeu")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.accent)
                        .padding(.top, 30)
                    
                    HStack(spacing: 20) {
                        ForEach(GameMode.allCases) { mode in
                            Button(action: {
                                game.setGameMode(mode)
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: mode == .visual ? "eye.fill" : "keyboard.fill")
                                        .font(.system(size: 30))
                                    
                                    Text(mode.rawValue)
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .frame(width: 120)
                                .padding(.vertical, 15)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(game.selectedGameMode == mode ? 
                                              AppColors.woodMedium : 
                                              Color(hex: "E8DECD"))
                                )
                                .foregroundColor(game.selectedGameMode == mode ? 
                                               AppColors.textLight : 
                                               AppColors.accent)
                            }
                        }
                    }
                }
                
                // Sélection du temps
                VStack(spacing: 15) {
                    Text("Durée de la partie")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.accent)
                        .padding(.top, 20)
                    
                    // Options de temps
                    VStack(spacing: 25) {
                        TimerOptionButton(duration: 20) {
                            startGameWithDuration(20)
                        }
                        
                        TimerOptionButton(duration: 40) {
                            startGameWithDuration(40)
                        }
                        
                        TimerOptionButton(duration: 60) {
                            startGameWithDuration(60)
                        }
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(
                AppColors.background
                    .overlay(
                        WoodGrainOverlay()
                            .opacity(0.1)
                    )
            )
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    // Fonction pour démarrer le jeu avec la durée sélectionnée
    func startGameWithDuration(_ duration: Int) {
        game.startGame(duration: duration)
        withAnimation {
            currentView = .game
        }
    }
}

struct TimerOptionButton: View {
    let duration: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 24))
                    
                    Text("\(duration) secondes")
                        .font(.system(size: 24, weight: .semibold))
                }
                
                if duration == 20 {
                    Text("(Rapide)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textLight.opacity(0.9))
                } else if duration == 40 {
                    Text("(Normal)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textLight.opacity(0.9))
                } else {
                    Text("(Détendu)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.textLight.opacity(0.9))
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 30)
            .background(AppColors.woodMedium)
            .foregroundColor(AppColors.textLight)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
        }
    }
} 
