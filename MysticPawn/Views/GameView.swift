import SwiftUI

struct GameView: View {
    @ObservedObject var game: ChessGame
    @Binding var currentView: AppView
    @State private var showQuitConfirmation: Bool = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        ZStack {
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
                                .opacity(game.isGameActive && !game.isCountingDown && game.selectedGameMode == .visual ? 1 : 0)
                                .animation(.easeInOut(duration: 0.5), value: game.isCountingDown)
                                .scaleEffect(game.isGameActive && !game.isCountingDown && game.selectedGameMode == .visual ? 1 : 0.5)
                            
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
                                // Échiquier - conditionné selon le mode
                                if game.selectedGameMode == .coordinates {
                                    // Mode Saisie : échiquier non-interactif mais visuellement normal
                                    ChessboardView(game: game)
                                        .frame(width: geometry.size.width, height: geometry.size.width)
                                        .allowsHitTesting(false) // Désactive les interactions sans effet visuel flou
                                    
                                    // Surbrillance de la case cible
                                    let squareSize = geometry.size.width / 8
                                    Rectangle()
                                        .fill(Color(hex: game.selectedTheme.highlightColor).opacity(0.5))
                                        .frame(width: squareSize, height: squareSize)
                                        .position(
                                            x: CGFloat(game.targetPosition.file) * squareSize + squareSize/2,
                                            y: CGFloat(7 - game.targetPosition.rank) * squareSize + squareSize/2
                                        )
                                } else {
                                    // Mode Visuel : échiquier interactif, désactivé pendant le compte à rebours
                                    ChessboardView(game: game)
                                        .frame(width: geometry.size.width, height: geometry.size.width)
                                        .disabled(!game.isGameActive || game.isCountingDown)
                                }
                                
                                // Affichage du compte à rebours (commun aux deux modes)
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
                        .frame(height: UIScreen.main.bounds.width)
                        .padding(.horizontal, 0)
                        
                        // Interface de saisie des coordonnées
                        if game.selectedGameMode == .coordinates {
                            VStack(spacing: 15) {
                                Text("Entrez les coordonnées")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textDark)
                                
                                // Boutons des lettres (A-H)
                                HStack(spacing: 8) {
                                    ForEach(["A", "B", "C", "D", "E", "F", "G", "H"], id: \.self) { letter in
                                        Button(action: {
                                            if game.userInput.isEmpty || game.userInput.count == 2 {
                                                game.userInput = letter
                                            } else {
                                                // Si une lettre est déjà sélectionnée, on la remplace
                                                game.userInput = letter
                                            }
                                        }) {
                                            Text(letter)
                                                .font(.system(size: 20, weight: .medium))
                                                .frame(width: 35, height: 35)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(game.userInput.prefix(1) == letter ? 
                                                              AppColors.woodMedium : 
                                                              Color(hex: "E8DECD"))
                                                )
                                                .foregroundColor(game.userInput.prefix(1) == letter ? 
                                                               AppColors.textLight : 
                                                               AppColors.accent)
                                        }
                                        .disabled(!game.isGameActive)
                                    }
                                }
                                
                                // Boutons des chiffres (1-8)
                                HStack(spacing: 8) {
                                    ForEach(["1", "2", "3", "4", "5", "6", "7", "8"], id: \.self) { number in
                                        Button(action: {
                                            if game.userInput.count == 1 {
                                                // Si une lettre est déjà sélectionnée, on ajoute le chiffre
                                                game.userInput += number
                                                game.checkAnswer(game.targetPosition)
                                                // Réinitialiser après un court délai
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                    game.userInput = ""
                                                }
                                            } else if game.userInput.count == 2 {
                                                // Si un chiffre est déjà sélectionné, on le remplace
                                                game.userInput = String(game.userInput.prefix(1)) + number
                                            }
                                        }) {
                                            Text(number)
                                                .font(.system(size: 20, weight: .medium))
                                                .frame(width: 35, height: 35)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(game.userInput.count == 2 && game.userInput.suffix(1) == number ? 
                                                              AppColors.woodMedium : 
                                                              Color(hex: "E8DECD"))
                                                )
                                                .foregroundColor(game.userInput.count == 2 && game.userInput.suffix(1) == number ? 
                                                               AppColors.textLight : 
                                                               AppColors.accent)
                                        }
                                        .disabled(!game.isGameActive)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                        }
                        
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
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                    }
                    .padding(0)
                }
            }
            .edgesIgnoringSafeArea(.top)
            
            // Overlay d'abandon de partie
            if showQuitConfirmation {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                
                QuitConfirmationView(
                    isPresented: $showQuitConfirmation,
                    onQuit: {
                        game.endGame()
                        withAnimation {
                            currentView = .home
                        }
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showQuitConfirmation)
    }
}

// Vue de confirmation d'abandon de partie
struct QuitConfirmationView: View {
    @Binding var isPresented: Bool
    let onQuit: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Abandonner la partie ?")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.textLight)
                .multilineTextAlignment(.center)
            
            Text("Votre progression sera perdue.")
                .font(.system(size: 18))
                .foregroundColor(AppColors.textLight.opacity(0.9))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                // Bouton Annuler
                Button(action: {
                    isPresented = false
                }) {
                    HStack {
                        Image(systemName: "xmark")
                            .font(.system(size: 16))
                        Text("Annuler")
                            .font(.headline)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(AppColors.woodLight)
                    .foregroundColor(AppColors.textLight)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 2)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Bouton Abandonner
                Button(action: {
                    onQuit()
                }) {
                    HStack {
                        Image(systemName: "door.left.hand.open")
                            .font(.system(size: 16))
                        Text("Confirmer")
                            .font(.headline)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.8))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 10)
        }
        .padding(30)
        .background(Color.black.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.5), radius: 10)
        .padding(20)
    }
}
