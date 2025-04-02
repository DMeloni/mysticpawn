import SwiftUI

struct GameView: View {
    @ObservedObject var game: ChessGame
    @Binding var currentView: AppView
    @State private var showQuitConfirmation: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Barre de navigation - positionnée tout en haut
            NavigationBar(
                title: "MysticPawn",
                leftAction: {
                    // Si une partie est en cours, demander confirmation
                    if game.isGameActive || game.isCountingDown {
                        showQuitConfirmation = true
                    } else {
                        // Sinon, retourner à l'accueil
                        withAnimation {
                            currentView = .home
                        }
                    }
                },
                leftIcon: "house.fill",
                rightIcon: "questionmark.circle", 
                rightAction: {}
            )
            
            // Contenu de l'application
            ZStack {
                // Arrière-plan texturé spécifique au contenu
                AppColors.background
                    .overlay(
                        WoodGrainOverlay()
                            .opacity(0.1)
                    )
                
                VStack(spacing: 10) {
                    HStack {
                        // Position cible sans le "Target:"
                        Text(game.targetPosition.notation)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(AppColors.textDark)
                            .opacity(game.isGameActive && !game.isCountingDown ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5), value: game.isCountingDown)
                            .scaleEffect(game.isGameActive && !game.isCountingDown ? 1 : 0.5)
                        
                        Spacer()
                        
                        // Timer - visible uniquement quand le jeu est actif (pas pendant le compte à rebours)
                        HStack(spacing: 5) {
                            Image(systemName: "clock")
                                .font(.system(size: 22))
                            Text("\(game.timeRemaining)")
                                .font(.system(size: 26, weight: .bold))
                        }
                        .foregroundColor(game.timeRemaining > 5 ? AppColors.textDark : .red)
                        .opacity(game.isGameActive && !game.isCountingDown ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5), value: game.isCountingDown)
                        .scaleEffect(game.isGameActive && !game.isCountingDown ? 1 : 0.5)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    
                    // Échiquier agrandi
                    GeometryReader { geometry in
                        ZStack {
                            ChessboardView(game: game)
                                .frame(width: geometry.size.width, height: geometry.size.width)
                                .opacity(game.isGameActive || game.isCountingDown ? 1 : 0.7)
                            
                            // Affichage du compte à rebours
                            if game.isCountingDown {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.7))
                                        .frame(width: 120, height: 120)
                                    
                                    Circle()
                                        .stroke(Color(hex: game.selectedTheme.borderColor), lineWidth: 6)
                                        .frame(width: 120, height: 120)
                                    
                                    Text("\(game.countdownValue)")
                                        .font(.system(size: 80, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    .frame(height: UIScreen.main.bounds.width) // Définir une hauteur fixe
                    .padding(.horizontal, 0)
                    
                    // Barre de score et bouton
                    HStack {
                        // Score
                        Text("Score: \(game.score)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppColors.textDark)
                        
                        Spacer()
                        
                        // Bouton Start/Restart
                        Button(action: {
                            if game.isGameActive || game.isCountingDown {
                                game.restartGame()
                            } else {
                                // Démarrer directement avec la durée actuelle
                                game.startGame(duration: game.currentDuration)
                            }
                        }) {
                            Text((game.isGameActive || game.isCountingDown) ? "Restart" : "Start")
                                .font(.headline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AppColors.woodMedium)
                                .foregroundColor(AppColors.textLight)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(radius: 2)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
                .padding(0)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .alert(isPresented: $showQuitConfirmation) {
            Alert(
                title: Text("Abandonner la partie ?"),
                message: Text("Votre partie en cours sera perdue. Voulez-vous vraiment quitter ?"),
                primaryButton: .destructive(Text("Abandonner")) {
                    // Arrêter la partie mais ne pas afficher le menu immédiatement
                    game.endGame()
                    
                    // Petite attente pour montrer l'écran de Game Over
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            // Le GameOverView sera automatiquement affiché par le ContentView
                            // car game.isGameActive est maintenant false et timeRemaining est 0
                            
                            // Après un court délai, retourner à l'accueil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation {
                                    currentView = .home
                                }
                            }
                        }
                    }
                },
                secondaryButton: .cancel(Text("Continuer"))
            )
        }
    }
} 