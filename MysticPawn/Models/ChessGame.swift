import Foundation
import Combine
import AVFoundation

// Définir les thèmes d'échiquier disponibles
enum ChessboardTheme: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case blackWhite = "Noir & Blanc"
    case tournament = "Tournament"
    case metro = "Metro"
    
    var id: String { rawValue }
    
    // Couleurs pour les cases blanches
    var lightSquareColor: String {
        switch self {
        case .classic:
            return "F0D9B5" // Beige clair classique
        case .blackWhite:
            return "FFFFFF" // Blanc pur
        case .tournament:
            return "EEEED2" // Vert olive très clair
        case .metro:
            return "FFFFFF" // Blanc pur
        }
    }
    
    // Couleurs pour les cases noires
    var darkSquareColor: String {
        switch self {
        case .classic:
            return "B58863" // Marron classique
        case .blackWhite:
            return "000000" // Noir pur
        case .tournament:
            return "769656" // Vert olive
        case .metro:
            return "58AC8A" // Turquoise
        }
    }
    
    // Couleurs pour la bordure
    var borderColor: String {
        switch self {
        case .classic:
            return "8B4513" // Marron
        case .blackWhite:
            return "333333" // Gris foncé
        case .tournament:
            return "4B5320" // Vert olive foncé
        case .metro:
            return "333333" // Gris foncé
        }
    }
}

struct ChessPosition: Equatable {
    let file: Int // 0-7 (A-H)
    let rank: Int // 0-7 (1-8)
    
    var notation: String {
        let files = ["A", "B", "C", "D", "E", "F", "G", "H"]
        return "\(files[file])\(rank + 1)"
    }
    
    static func from(notation: String) -> ChessPosition? {
        let files = ["A", "B", "C", "D", "E", "F", "G", "H"]
        guard notation.count == 2,
              let file = files.firstIndex(of: notation.prefix(1).uppercased()),
              let rank = Int(notation.suffix(1)),
              rank >= 1 && rank <= 8 else {
            return nil
        }
        return ChessPosition(file: file, rank: rank - 1)
    }
}

class ChessGame: ObservableObject {
    @Published var targetPosition: ChessPosition
    @Published var score: Int = 0
    @Published var message: String = ""
    @Published var isCorrect: Bool = false
    @Published var timeRemaining: Int = 20
    @Published var isGameActive: Bool = false
    @Published var currentDuration: Int = 20  // Mémoriser la durée choisie
    @Published var isCountingDown: Bool = false
    @Published var countdownValue: Int = 3
    @Published var isSpeechEnabled: Bool = true  // Activer ou désactiver la synthèse vocale
    @Published var useFemaleVoice: Bool = true   // Choisir entre voix masculine et féminine
    @Published var selectedTheme: ChessboardTheme = .blackWhite // Thème d'échiquier sélectionné
    @Published var hasGameEnded: Bool = false  // Indique si la partie est terminée (temps écoulé ou abandon)
    
    private var timer: AnyCancellable?
    private var countdownTimer: AnyCancellable?
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    init() {
        self.targetPosition = ChessGame.generateRandomPosition()
        
        // Charger les préférences utilisateur
        loadUserPreferences()
        
        // Précharger la synthèse vocale en arrière-plan
        DispatchQueue.global(qos: .background).async {
            // Créer une petite utterance silencieuse pour initialiser le système
            let preloadUtterance = AVSpeechUtterance(string: " ")
            if self.useFemaleVoice {
                let femaleVoices = [
                    "com.apple.ttsbundle.Amelie-compact",
                    "com.apple.voice.compact.fr-FR.Aurelie"
                ]
                
                for voiceID in femaleVoices {
                    if let voice = AVSpeechSynthesisVoice(identifier: voiceID) {
                        preloadUtterance.voice = voice
                        break
                    }
                }
                
                if preloadUtterance.voice == nil {
                    preloadUtterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
                }
            } else {
                preloadUtterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Thomas-compact")
                if preloadUtterance.voice == nil {
                    preloadUtterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
                }
            }
            
            // Initialiser le système de synthèse vocale
            self.speechSynthesizer.speak(preloadUtterance)
        }
    }
    
    // Charger les préférences de l'utilisateur
    private func loadUserPreferences() {
        if let speechEnabled = UserDefaults.standard.object(forKey: "isSpeechEnabled") as? Bool {
            isSpeechEnabled = speechEnabled
        } else {
            // Définir la valeur par défaut si elle n'existe pas encore
            UserDefaults.standard.set(true, forKey: "isSpeechEnabled")
        }
        
        if let femaleVoice = UserDefaults.standard.object(forKey: "useFemaleVoice") as? Bool {
            useFemaleVoice = femaleVoice
        } else {
            // Définir la valeur par défaut si elle n'existe pas encore
            UserDefaults.standard.set(true, forKey: "useFemaleVoice")
        }
        
        if let themeName = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = ChessboardTheme(rawValue: themeName) {
            selectedTheme = theme
        } else {
            // Définir la valeur par défaut si elle n'existe pas encore
            UserDefaults.standard.set(ChessboardTheme.blackWhite.rawValue, forKey: "selectedTheme")
        }
    }
    
    // Sauvegarder les préférences de l'utilisateur
    private func saveUserPreferences() {
        UserDefaults.standard.set(isSpeechEnabled, forKey: "isSpeechEnabled")
        UserDefaults.standard.set(useFemaleVoice, forKey: "useFemaleVoice")
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
    }
    
    // Changer l'état de la synthèse vocale
    func toggleSpeech() {
        isSpeechEnabled.toggle()
        saveUserPreferences()
    }
    
    // Changer le type de voix
    func toggleVoiceGender() {
        useFemaleVoice.toggle()
        saveUserPreferences()
    }
    
    // Changer le thème de l'échiquier
    func setTheme(_ theme: ChessboardTheme) {
        selectedTheme = theme
        saveUserPreferences()
    }
    
    static func generateRandomPosition() -> ChessPosition {
        ChessPosition(
            file: Int.random(in: 0...7),
            rank: Int.random(in: 0...7)
        )
    }
    
    func startGame(duration: Int = 20) {
        // Mémoriser la durée pour les redémarrages futurs
        currentDuration = duration
        
        // Réinitialiser le jeu
        score = 0
        timeRemaining = duration
        hasGameEnded = false  // Réinitialiser l'état de fin de partie
        
        // Démarrer le compte à rebours
        startCountdown()
    }
    
    private func startCountdown() {
        // Réinitialiser le compte à rebours
        countdownValue = 3
        isCountingDown = true
        
        // Annoncer le départ du compte à rebours
        speakCountdown(countdownValue)
        
        countdownTimer?.cancel()
        countdownTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.countdownValue > 1 {
                    self.countdownValue -= 1
                    // Annoncer chaque chiffre du compte à rebours
                    self.speakCountdown(self.countdownValue)
                } else {
                    // Fin du compte à rebours, démarrer le jeu
                    self.isCountingDown = false
                    self.countdownTimer?.cancel()
                    self.actuallyStartGame()
                }
            }
    }
    
    // Fonction pour vocaliser le compte à rebours
    private func speakCountdown(_ number: Int) {
        // Ne pas parler si la fonctionnalité est désactivée
        guard isSpeechEnabled else { return }
        
        let utterance = AVSpeechUtterance(string: "\(number)")
        configureVoice(utterance, isGameplay: false)
        
        speechSynthesizer.speak(utterance)
    }
    
    // Configure les paramètres de voix en fonction du contexte
    private func configureVoice(_ utterance: AVSpeechUtterance, isGameplay: Bool) {
        // Sélectionner la voix en fonction du paramètre
        if useFemaleVoice {
            // Différentes options de voix féminines françaises
            let femaleVoices = [
                "com.apple.ttsbundle.Amelie-compact",
                "com.apple.voice.compact.fr-FR.Aurelie"
            ]
            
            // Essayer de définir une des voix féminines
            var voiceFound = false
            for voiceID in femaleVoices {
                if let voice = AVSpeechSynthesisVoice(identifier: voiceID) {
                    utterance.voice = voice
                    voiceFound = true
                    break
                }
            }
            
            // Fallback si aucune voix spécifique n'est disponible
            if !voiceFound {
                utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
            }
        } else {
            // Voix masculine française
            utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Thomas-compact")
            // Fallback si la voix spécifique n'est pas disponible
            if utterance.voice == nil {
                utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
            }
        }
        
        if isGameplay {
            // Paramètres pour le jeu - plus rapide mais toujours naturel
            utterance.rate = 0.55       // Vitesse légèrement plus rapide pour le gameplay
            utterance.pitchMultiplier = 1.05 // Pitch presque normal pour garder le côté naturel
        } else {
            // Paramètres pour le compte à rebours - plus lent et clair
            utterance.rate = 0.45       // Vitesse plus lente pour le compte à rebours
            utterance.pitchMultiplier = 1.1  // Légèrement plus aigu pour une meilleure clarté
        }
        
        utterance.volume = 1.0     // Volume maximum dans tous les cas
    }
    
    private func actuallyStartGame() {
        isGameActive = true
        targetPosition = ChessGame.generateRandomPosition()
        
        // Lire vocalement la position cible
        speakTargetPosition()
        
        // Démarrer le timer principal
        timer?.cancel()
        timeRemaining = currentDuration // S'assurer que le temps est bien réinitialisé
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.endGame()
                }
            }
    }
    
    // Fonction pour lire vocalement la position cible
    private func speakTargetPosition() {
        // Ne pas parler si la fonctionnalité est désactivée
        guard isSpeechEnabled else { return }
        
        let utterance = AVSpeechUtterance(string: targetPosition.notation)
        configureVoice(utterance, isGameplay: true)
        
        speechSynthesizer.speak(utterance)
    }
    
    // Fonction pour redémarrer le jeu avec la durée mémorisée
    func restartGame() {
        startGame(duration: currentDuration)
    }
    
    func endGame() {
        isGameActive = false
        timer?.cancel()
        timer = nil
        
        // Marquer la partie comme terminée
        hasGameEnded = true
        
        // Ne pas réinitialiser le score pour permettre l'affichage du Game Over
        // Le score sera réinitialisé lors du prochain démarrage de jeu
    }
    
    func checkAnswer(_ position: ChessPosition) {
        guard isGameActive else { return }
        
        if position == targetPosition {
            score += 1
            message = "Correct!"
            isCorrect = true
            
            // Délai avant de générer une nouvelle position
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.message = ""
                self.targetPosition = ChessGame.generateRandomPosition()
                self.speakTargetPosition() // Lire la nouvelle position
            }
        } else {
            // Réduire le score de 1, permettre les scores négatifs
            score -= 1
            message = "Try again!"
            isCorrect = false
            
            // Effacer le message d'erreur après un délai
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.message = ""
            }
        }
    }
} 