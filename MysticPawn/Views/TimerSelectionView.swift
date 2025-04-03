import SwiftUI

struct TimerSelectionView: View {
    @ObservedObject var game: ChessGame
    @Binding var currentView: AppView
    @State private var selectedDuration: Int = 40  // Durée par défaut
    
    var body: some View {
        ZStack {
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
                ScrollView {
                    VStack(spacing: 25) {
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
                                                      Color(hex: "E8DECD") : 
                                                      Color.white.opacity(0.7))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(game.selectedGameMode == mode ? 
                                                      AppColors.woodMedium : Color.clear, 
                                                      lineWidth: 2)
                                        )
                                        .foregroundColor(AppColors.accent)
                                    }
                                }
                            }
                        }
                        
                        // Position des dames
                        VStack(spacing: 15) {
                            Text("Position des dames")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.accent)
                                .padding(.top, 20)
                            
                            // Options de position des dames
                            VStack(spacing: 10) {
                                ForEach(QueenPosition.allCases) { position in
                                    Button(action: {
                                        game.setQueenPosition(position)
                                    }) {
                                        HStack {
                                            if position == .whiteOnBottom {
                                                // Dame blanche en bas
                                                Image("white_queen")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 24, height: 24)
                                                Text("Dame Blanche en bas")
                                                    .font(.system(size: 16, weight: .medium))
                                            } else if position == .blackOnBottom {
                                                // Dame noire en bas
                                                Image("black_queen")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 24, height: 24)
                                                Text("Dame Noire en bas")
                                                    .font(.system(size: 16, weight: .medium))
                                            } else {
                                                // Mode aléatoire
                                                Image(systemName: "dice")
                                                    .font(.system(size: 20))
                                                Text("Aléatoire")
                                                    .font(.system(size: 16, weight: .medium))
                                            }
                                            
                                            Spacer()
                                            
                                            if game.selectedQueenPosition == position {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(AppColors.woodMedium)
                                            }
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 15)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(game.selectedQueenPosition == position ? 
                                                    Color(hex: "E8DECD") : 
                                                    Color.white.opacity(0.7))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(game.selectedQueenPosition == position ? 
                                                    AppColors.woodMedium : Color.clear, 
                                                    lineWidth: 2)
                                        )
                                        .foregroundColor(AppColors.accent)
                                    }
                                }
                            }
                            .padding(.horizontal, 15)
                        }
                        .padding(.horizontal, 15)
                        
                        // Sélection du temps
                        VStack(spacing: 15) {
                            Text("Durée de la partie")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.accent)
                                .padding(.top, 20)
                            
                            // Options de temps
                            HStack(spacing: 10) {
                                TimerOptionButton(duration: 20, isSelected: selectedDuration == 20) {
                                    selectedDuration = 20
                                }
                                
                                TimerOptionButton(duration: 40, isSelected: selectedDuration == 40) {
                                    selectedDuration = 40
                                }
                                
                                TimerOptionButton(duration: 60, isSelected: selectedDuration == 60) {
                                    selectedDuration = 60
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 100) // Ajout d'un espace pour éviter que le bouton ne cache le contenu
                }
                .background(
                    AppColors.background
                        .overlay(
                            WoodGrainOverlay()
                                .opacity(0.1)
                        )
                )
            }
            .edgesIgnoringSafeArea(.top)
            
            // Bouton Jouer fixe en bas de l'écran
            VStack {
                Spacer()
                Button(action: {
                    startGameWithDuration(selectedDuration)
                }) {
                    Text("Jouer")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.woodMedium)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
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
    var isSelected: Bool = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(durationLabel)
                    .font(.system(size: 20, weight: .bold))
                
                HStack(spacing: 3) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    
                    Text("\(duration)s")
                        .font(.system(size: 14, weight: .medium))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? 
                        Color(hex: "E8DECD") : 
                        Color.white.opacity(0.7))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? 
                        AppColors.woodMedium : Color.clear, 
                        lineWidth: 2)
            )
            .foregroundColor(AppColors.accent)
            
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var durationLabel: String {
        switch duration {
        case 20:
            return "Rapide"
        case 40:
            return "Normal"
        case 60:
            return "Détendu"
        default:
            return "\(duration)"
        }
    }
} 
