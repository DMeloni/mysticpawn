import SwiftUI

struct HighScoresView: View {
    @ObservedObject var game: ChessGame
    @Binding var currentView: AppView
    @State private var selectedMode: GameMode = .visual
    
    var body: some View {
        VStack(spacing: 0) {
            // Barre de navigation - positionnée tout en haut
            NavigationBar(
                title: "Meilleurs scores",
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
            
            // Sélecteur de mode de jeu
            Picker("Mode de jeu", selection: $selectedMode) {
                ForEach(GameMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)
            
            // Filtrer les scores par mode sélectionné
            let filteredScores = game.highScores.filter { $0.gameMode == selectedMode.rawValue }
            
            // Contenu principal
            if filteredScores.isEmpty {
                VStack {
                    Spacer()
                    
                    Image(systemName: "trophy")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.woodMedium)
                        .padding(.bottom, 20)
                    
                    Text("Pas encore de scores enregistrés\npour le mode \(selectedMode.rawValue)")
                        .font(.title2)
                        .foregroundColor(AppColors.textDark)
                        .multilineTextAlignment(.center)
                    
                    Text("Jouez et enregistrez votre score pour apparaître ici")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textDark.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 5)
                    
                    Spacer()
                }
            } else {
                List {
                    ForEach(filteredScores) { score in
                        HStack {
                            // Rang (calculé dynamiquement)
                            if let index = filteredScores.firstIndex(where: { $0.id == score.id }) {
                                Text("\(index + 1)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(index < 3 ? AppColors.woodMedium : AppColors.textDark)
                                    .frame(width: 30)
                            }
                            
                            // Nom du joueur
                            Text(score.playerName)
                                .font(.system(size: 18))
                                .foregroundColor(AppColors.textDark)
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                // Score
                                Text("\(score.score)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppColors.accent)
                                
                                // Date formattée
                                Text(formattedDate(score.date))
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textDark.opacity(0.6))
                            }
                            
                            // Durée de la partie
                            Text("\(score.duration)s")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.textDark.opacity(0.6))
                                .frame(width: 40, alignment: .trailing)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(PlainListStyle())
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
    
    // Fonction pour formater la date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
} 