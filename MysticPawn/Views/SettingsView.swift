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
            SettingsContent(game: game)
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

// Composant pour le contenu principal des paramètres
struct SettingsContent: View {
    @ObservedObject var game: ChessGame
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Section Gameplay
                GameplaySettingsSection(game: game)
                
                // Section Audio
                AudioSettingsSection(game: game)
                
                // Section thèmes
                ThemeSettingsSection(game: game)
                
                Spacer()
            }
        }
    }
}

// Composant pour la section gameplay des paramètres
struct GameplaySettingsSection: View {
    @ObservedObject var game: ChessGame
    
    var body: some View {
        VStack(spacing: 20) {
            // Titre de la section
            Text("Position des dames")
                .font(.headline)
                .foregroundColor(AppColors.accent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.top, 5)
            
            // Option pour la position des dames
            QueenPositionSelector(game: game)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "E8DECD"))
        )
        .padding(.horizontal, 20)
    }
}

// Sélecteur pour la position des dames
struct QueenPositionSelector: View {
    @ObservedObject var game: ChessGame
    
    var body: some View {
        VStack(spacing: 15) {
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
                            } else if position == .blackOnBottom {
                                // Dame noire en bas
                                Image("black_queen")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                Text("Dame Noire en bas")
                            } else {
                                // Mode aléatoire
                                Image(systemName: "dice")
                                    .font(.system(size: 20))
                                Text("Aléatoire")
                            }
                            
                            Spacer()
                            
                            if game.selectedQueenPosition == position {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppColors.woodMedium)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.7))
                        )
                        .foregroundColor(AppColors.accent)
                    }
                }
            }
            .padding(.horizontal, 5)
        }
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
        )
    }
}

// Composant pour la section audio des paramètres
struct AudioSettingsSection: View {
    @ObservedObject var game: ChessGame
    
    var body: some View {
        VStack(spacing: 20) {
            // Titre de la section
            Text("Audio")
                .font(.headline)
                .foregroundColor(AppColors.accent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.top, 5)
            
            // Option pour activer/désactiver les effets sonores
            SoundEffectsToggle(game: game)
            
            // Option pour activer/désactiver la synthèse vocale
            SpeechSynthesisToggle(game: game)
            
            // Option pour choisir le type de voix
            VoiceTypeToggle(game: game)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "E8DECD"))
        )
        .padding(.horizontal, 20)
    }
}

// Toggle pour les effets sonores
struct SoundEffectsToggle: View {
    @ObservedObject var game: ChessGame
    
    var body: some View {
        Toggle(isOn: Binding(
            get: { game.isSoundEnabled },
            set: { newValue in
                game.isSoundEnabled = newValue
                // Sauvegarder le paramètre
                UserDefaults.standard.set(newValue, forKey: "isSoundEnabled")
            }
        )) {
            HStack {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 22))
                    .foregroundColor(AppColors.accent)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Effets sonores")
                        .font(.headline)
                        .foregroundColor(AppColors.accent)
                    
                    Text("Sons de réussite et d'échec")
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
    }
}

// Toggle pour la synthèse vocale
struct SpeechSynthesisToggle: View {
    @ObservedObject var game: ChessGame
    
    var body: some View {
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
    }
}

// Toggle pour le type de voix
struct VoiceTypeToggle: View {
    @ObservedObject var game: ChessGame
    
    var body: some View {
        Toggle(isOn: Binding(
            get: { game.useFemaleVoice },
            set: { newValue in
                game.useFemaleVoice = newValue
                // Sauvegarder le paramètre
                UserDefaults.standard.set(newValue, forKey: "useFemaleVoice")
            }
        )) {
            HStack {
                // Conteneur pour aligner avec les autres icônes
                Text(game.useFemaleVoice ? "♕" : "♔")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(game.useFemaleVoice 
                                     ? AppColors.woodMedium 
                                     : Color(hex: "4B5320"))
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Type de voix")
                        .font(.headline)
                        .foregroundColor(AppColors.accent)
                    
                    Text(game.useFemaleVoice ? "Voix féminine (Dame)" : "Voix masculine (Roi)")
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
}

// Composant pour la section thèmes
struct ThemeSettingsSection: View {
    @ObservedObject var game: ChessGame
    
    var body: some View {
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
