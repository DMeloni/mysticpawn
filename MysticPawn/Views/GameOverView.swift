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
            }
            .padding(.top, 30)
        }
        .padding(40)
        .background(Color.black.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
} 