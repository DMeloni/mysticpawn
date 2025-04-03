import SwiftUI

struct ContentView: View {
    @StateObject private var game = ChessGame()
    @State private var animationAmount: CGFloat = 0
    @State private var currentView: AppView = .home // Commencer par l'écran d'accueil
    
    var body: some View {
        ZStack {
            // Arrière-plan texturé
            AppColors.background
                .overlay(
                    WoodGrainOverlay()
                        .opacity(0.1)
                )
                .ignoresSafeArea()
            
            // Contenu principal selon la vue active
            if currentView == .home {
                HomeMenuView(game: game, currentView: $currentView)
            } else if currentView == .game {
                GameView(game: game, currentView: $currentView)
            } else if currentView == .timerSelection {
                TimerSelectionView(game: game, currentView: $currentView)
            } else if currentView == .settings {
                SettingsView(game: game, currentView: $currentView)
            } else if currentView == .highScores {
                HighScoresView(game: game, currentView: $currentView)
            }
            
            // Effet visuel de brillance en cas de succès/échec
            if !game.message.isEmpty && currentView == .game {
                Color(game.isCorrect ? .green : .red)
                    .opacity(0.2 + (animationAmount * 0.4))
                    .ignoresSafeArea()
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.1)) {
                            animationAmount = 1
                        }
                        
                        // Réinitialiser l'animation pour la prochaine fois
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeIn(duration: 0.1)) {
                                animationAmount = 0
                            }
                        }
                    }
            }
            
            // Overlay pour fin de partie
            if game.hasGameEnded && currentView == .game {
                GameOverView(game: game, currentView: $currentView)
            }
        }
    }
}

// Preview pour iOS 16
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
