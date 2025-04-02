import SwiftUI

struct TimerSelectionView: View {
    @ObservedObject var game: ChessGame
    @Binding var currentView: AppView
    
    var body: some View {
        VStack(spacing: 0) {
            // Barre de navigation - positionnée tout en haut
            NavigationBar(
                title: "Sélection du temps",
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
            
            // Contenu de la sélection du temps
            VStack(spacing: 30) {
                // Titre
                Text("Choisissez la durée de la partie")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.accent)
                    .padding(.top, 50)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
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
                .padding(.top, 30)
                
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
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppColors.woodMedium,
                        AppColors.woodDark
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .foregroundColor(AppColors.textLight)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
        }
    }
} 