import SwiftUI

struct SettingsView: View {
    @ObservedObject var game: ChessGame
    @Binding var currentView: AppView
    
    var body: some View {
        VStack(spacing: 0) {
            // Barre de navigation - positionnée tout en haut
            NavigationBar(
                title: "Paramètres",
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
            
            // Contenu des paramètres
            ScrollView {
                VStack(spacing: 30) {
                    // Titre
                    Text("Options du jeu")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.accent)
                        .padding(.top, 30)
                    
                    // Section synthèse vocale
                    VStack(spacing: 20) {
                        // Option pour activer/désactiver la synthèse vocale
                        Toggle(isOn: Binding(
                            get: { game.isSpeechEnabled },
                            set: { newValue in
                                game.isSpeechEnabled = newValue
                                // Sauvegarder le paramètre
                                UserDefaults.standard.set(newValue, forKey: "isSpeechEnabled")
                            }
                        )) {
                            HStack {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(AppColors.accent)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Synthèse vocale")
                                        .font(.headline)
                                        .foregroundColor(AppColors.accent)
                                    
                                    Text("Annonce vocale de la position cible")
                                        .font(.subheadline)
                                        .foregroundColor(AppColors.accent.opacity(0.7))
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.7))
                        )
                        .toggleStyle(SwitchToggleStyle(tint: AppColors.woodMedium))
                        
                        // Option pour choisir le type de voix
                        Toggle(isOn: Binding(
                            get: { game.useFemaleVoice },
                            set: { newValue in
                                game.useFemaleVoice = newValue
                                // Sauvegarder le paramètre
                                UserDefaults.standard.set(newValue, forKey: "useFemaleVoice")
                            }
                        )) {
                            HStack {
                                Image(systemName: game.useFemaleVoice ? "person.fill" : "person")
                                    .font(.system(size: 22))
                                    .foregroundColor(AppColors.accent)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Type de voix")
                                        .font(.headline)
                                        .foregroundColor(AppColors.accent)
                                    
                                    Text(game.useFemaleVoice ? "Voix féminine" : "Voix masculine")
                                        .font(.subheadline)
                                        .foregroundColor(AppColors.accent.opacity(0.7))
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.7))
                        )
                        .toggleStyle(SwitchToggleStyle(tint: AppColors.woodMedium))
                        .disabled(!game.isSpeechEnabled) // Désactiver si la synthèse vocale est désactivée
                        .opacity(game.isSpeechEnabled ? 1.0 : 0.5) // Réduire l'opacité si désactivé
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "E8DECD"))
                    )
                    .padding(.horizontal, 20)
                    
                    // Section thèmes
                    VStack(spacing: 15) {
                        // Titre de la section
                        Text("Thème de l'échiquier")
                            .font(.headline)
                            .foregroundColor(AppColors.accent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 10)
                            .padding(.top, 5)
                        
                        // Liste des thèmes disponibles
                        ForEach(ChessboardTheme.allCases) { theme in
                            ThemeOptionButton(
                                theme: theme,
                                isSelected: game.selectedTheme == theme,
                                action: {
                                    game.setTheme(theme)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "E8DECD"))
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
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

struct ThemeOptionButton: View {
    let theme: ChessboardTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Aperçu du thème (mini échiquier 2x2)
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color(hex: theme.lightSquareColor))
                            .frame(width: 20, height: 20)
                        Rectangle()
                            .fill(Color(hex: theme.darkSquareColor))
                            .frame(width: 20, height: 20)
                    }
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color(hex: theme.darkSquareColor))
                            .frame(width: 20, height: 20)
                        Rectangle()
                            .fill(Color(hex: theme.lightSquareColor))
                            .frame(width: 20, height: 20)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(hex: theme.borderColor), lineWidth: 2)
                )
                .padding(4)
                
                Text(theme.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.accent)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.woodMedium)
                        .font(.system(size: 22))
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.7))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? AppColors.woodMedium : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
} 