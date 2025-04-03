import SwiftUI

struct GameOverView: View {
    @ObservedObject var game: ChessGame
    @Binding var currentView: AppView
    
    var body: some View {
        VStack {
            Text("Game Over!")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(AppColors.textLight)
            Text("Final Score: \(game.score)")
                .font(.title)
                .foregroundColor(AppColors.textLight)
                .padding(.top, 10)
            
            // Formulaire de saisie du nom du joueur (visible uniquement si score > 0)
            if game.showNameInput {
                VStack(spacing: 15) {
                    Text("Enregistrer votre score")
                        .font(.headline)
                        .foregroundColor(AppColors.textLight)
                    
                    TextField("Entrez votre nom", text: $game.playerName)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(8)
                        .foregroundColor(AppColors.textDark)
                    
                    // Indication que le nom est pré-rempli
                    if !game.playerName.isEmpty {
                        Text("Nom pré-rempli avec votre dernier score")
                            .font(.caption)
                            .foregroundColor(AppColors.textLight.opacity(0.8))
                    }
                    
                    Button(action: {
                        game.saveScore()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 18))
                            Text("Enregistrer")
                                .font(.headline)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(AppColors.woodMedium)
                        .foregroundColor(AppColors.textLight)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(radius: 2)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(game.playerName.isEmpty)
                    .opacity(game.playerName.isEmpty ? 0.6 : 1)
                }
                .padding(.vertical, 20)
            }
            
            HStack(spacing: 20) {
                // Bouton pour retourner à l'accueil
                Button(action: {
                    withAnimation {
                        currentView = .home
                    }
                }) {
                    HStack {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18))
                        Text("Menu")
                            .font(.headline)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .background(AppColors.woodMedium)
                    .foregroundColor(AppColors.textLight)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 2)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Bouton pour jouer à nouveau
                Button(action: {
                    withAnimation {
                        currentView = .timerSelection
                    }
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.system(size: 18))
                        Text("Play Again")
                            .font(.headline)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 15)
                    .background(AppColors.woodMedium)
                    .foregroundColor(AppColors.textLight)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(radius: 2)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 30)
        }
        .padding(40)
        .background(Color.black.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
} 