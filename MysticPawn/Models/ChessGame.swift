import Foundation
import Combine
import AVFoundation

// Définir les thèmes d'échiquier disponibles
enum ChessboardTheme: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case blackWhite = "Noir & Blanc"
    case tournament = "Tournament"
    case metro = "Metro"
    case fireOfDeath = "Feu de la mort"
    
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
        case .fireOfDeath:
            return "FFC107" // Jaune doré
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
        case .fireOfDeath:
            return "FF3D00" // Rouge feu
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
        case .fireOfDeath:
            return "BF360C" // Bordeaux foncé
        }
    }
    
    // Couleur de surbrillance pour les cases sélectionnées
    var highlightColor: String {
        switch self {
        case .classic:
            return "E8AD30" // Orange doré qui contraste avec le beige et le marron
        case .blackWhite:
            return "3482F6" // Bleu clair qui contraste bien avec le noir et blanc
        case .tournament:
            return "D35400" // Orange qui contraste avec le vert
        case .metro:
            return "FF5252" // Rouge qui contraste avec le turquoise
        case .fireOfDeath:
            return "00FFFF" // Cyan électrique qui contraste fortement avec le rouge et le jaune
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

// Définir les modes de jeu disponibles
enum GameMode: String, CaseIterable, Identifiable {
    case visual = "Visuel"
    case coordinates = "Coordonnées"
    
    var id: String { rawValue }
}

// Définir les options de position des dames
enum QueenPosition: String, CaseIterable, Identifiable {
    case whiteOnBottom = "Dame Blanche en bas"
    case blackOnBottom = "Dame Noire en bas" 
    case random = "Aléatoire"
    
    var id: String { rawValue }
}

// Structure pour représenter un score enregistré
struct SavedScore: Identifiable, Codable {
    var id = UUID()
    var playerName: String
    var score: Int
    var date: Date
    var duration: Int // Durée de la partie en secondes
    var gameMode: String // Mode de jeu (visuel ou coordonnées)
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
    @Published var isSoundEnabled: Bool = true  // Activer ou désactiver les effets sonores
    @Published var selectedGameMode: GameMode = .visual
    @Published var userInput: String = ""
    @Published var isInputActive: Bool = false
    @Published var isWhiteQueenOnTop: Bool = false  // Indique si la reine blanche est en haut (D8) ou en bas (D1)
    @Published var selectedQueenPosition: QueenPosition = .random // Option de position des dames
    
    // Propriétés pour la gestion des scores
    @Published var highScores: [SavedScore] = []
    @Published var playerName: String = ""
    @Published var showNameInput: Bool = false
    
    // Notation à afficher et à prononcer en fonction de l'orientation du plateau
    var displayNotation: String {
        if isWhiteQueenOnTop {
            // Plateau inversé, afficher les coordonnées inversées
            let invertedPosition = ChessPosition(file: 7 - targetPosition.file, rank: 7 - targetPosition.rank)
            return invertedPosition.notation
        } else {
            // Plateau normal, afficher les coordonnées directes
            return targetPosition.notation
        }
    }
    
    private var timer: AnyCancellable?
    private var countdownTimer: AnyCancellable?
    private let speechSynthesizer = AVSpeechSynthesizer()
    private var successSound: AVAudioPlayer?
    private var failureSound: AVAudioPlayer?
    
    init() {
        self.targetPosition = ChessGame.generateRandomPosition()
        
        // Charger les préférences utilisateur
        loadUserPreferences()
        
        // Charger les meilleurs scores
        loadHighScores()
        
        // Lister toutes les voix disponibles sur l'appareil pour diagnostic
        logAvailableVoices()
        
        // Précharger la synthèse vocale en arrière-plan
        DispatchQueue.global(qos: .background).async {
            // Créer une petite utterance silencieuse pour initialiser le système
            let preloadUtterance = AVSpeechUtterance(string: " ")
            
            // Utiliser la même configuration de voix que pour l'utilisation normale
            self.configureVoice(preloadUtterance, isGameplay: false)
            
            // Initialiser le système de synthèse vocale
            self.speechSynthesizer.speak(preloadUtterance)
        }
        
        // Charger les effets sonores
        loadSoundEffects()
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
        
        if let soundEnabled = UserDefaults.standard.object(forKey: "isSoundEnabled") as? Bool {
            isSoundEnabled = soundEnabled
        } else {
            // Définir la valeur par défaut si elle n'existe pas encore
            UserDefaults.standard.set(true, forKey: "isSoundEnabled")
        }
        
        if let gameMode = UserDefaults.standard.string(forKey: "selectedGameMode"),
           let mode = GameMode(rawValue: gameMode) {
            selectedGameMode = mode
        } else {
            UserDefaults.standard.set(GameMode.visual.rawValue, forKey: "selectedGameMode")
        }
        
        if let queenPosition = UserDefaults.standard.string(forKey: "selectedQueenPosition"),
           let position = QueenPosition(rawValue: queenPosition) {
            selectedQueenPosition = position
        } else {
            // Définir la valeur par défaut si elle n'existe pas encore
            UserDefaults.standard.set(QueenPosition.random.rawValue, forKey: "selectedQueenPosition")
        }
    }
    
    // Charger les effets sonores
    private func loadSoundEffects() {
        // Charger le son de réussite
        if let successSoundURL = Bundle.main.url(forResource: "success", withExtension: "wav") {
            do {
                successSound = try AVAudioPlayer(contentsOf: successSoundURL)
                successSound?.prepareToPlay()
            } catch {
                print("Impossible de charger le son de réussite: \(error)")
            }
        }
        
        // Charger le son d'échec
        if let failureSoundURL = Bundle.main.url(forResource: "failure", withExtension: "wav") {
            do {
                failureSound = try AVAudioPlayer(contentsOf: failureSoundURL)
                failureSound?.prepareToPlay()
            } catch {
                print("Impossible de charger le son d'échec: \(error)")
            }
        }
    }
    
    // Jouer le son de réussite
    private func playSuccessSound() {
        guard isSoundEnabled else { return }
        
        successSound?.currentTime = 0
        successSound?.play()
    }
    
    // Jouer le son d'échec
    private func playFailureSound() {
        guard isSoundEnabled else { return }
        
        failureSound?.currentTime = 0
        failureSound?.play()
    }
    
    // Méthode pour sauvegarder les préférences utilisateur
    private func saveUserPreferences() {
        UserDefaults.standard.set(isSpeechEnabled, forKey: "isSpeechEnabled")
        UserDefaults.standard.set(useFemaleVoice, forKey: "useFemaleVoice")
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
        UserDefaults.standard.set(isSoundEnabled, forKey: "isSoundEnabled")
        UserDefaults.standard.set(selectedGameMode.rawValue, forKey: "selectedGameMode")
        UserDefaults.standard.set(selectedQueenPosition.rawValue, forKey: "selectedQueenPosition")
    }
    
    // Changer l'état de la synthèse vocale
    func toggleSpeech() {
        isSpeechEnabled.toggle()
        saveUserPreferences()
    }
    
    // Changer le genre de la voix
    func toggleVoiceGender() {
        useFemaleVoice.toggle()
        saveUserPreferences()
    }
    
    // Changer le thème de l'échiquier
    func setTheme(_ theme: ChessboardTheme) {
        selectedTheme = theme
        saveUserPreferences()
    }
    
    // Changer l'état des effets sonores
    func toggleSound() {
        isSoundEnabled.toggle()
        saveUserPreferences()
    }
    
    // Changer le mode de jeu
    func setGameMode(_ mode: GameMode) {
        selectedGameMode = mode
        saveUserPreferences()
    }
    
    // Changer l'option de position des dames
    func setQueenPosition(_ position: QueenPosition) {
        selectedQueenPosition = position
        saveUserPreferences()
        
        // Si on n'est pas en mode "Aléatoire", on définit tout de suite la position des dames
        if position != .random {
            isWhiteQueenOnTop = (position == .blackOnBottom)
        }
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
        // Récupérer toutes les voix disponibles
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        
        // Filtrer les voix françaises
        let frenchVoices = allVoices.filter { $0.language.starts(with: "fr") }
        
        if useFemaleVoice {
            // Rechercher d'abord les voix féminines par leur gender
            let frenchFemaleVoices = frenchVoices.filter { $0.gender == .female }
            
            if !frenchFemaleVoices.isEmpty {
                // Utiliser la première voix féminine disponible
                utterance.voice = frenchFemaleVoices.first
                print("✅ Voix féminine sélectionnée par gender: \(utterance.voice?.name ?? "inconnue")")
            } else {
                // Si aucune voix avec gender féminin n'est trouvée, essayer par identifiant
                let femaleVoiceIDs = [
                    "com.apple.voice.premium.fr-FR.Amelie",
                    "com.apple.ttsbundle.Amelie-compact",
                    "com.apple.voice.compact.fr-FR.Aurelie",
                    "com.apple.eloquence.fr-FR.Aurelie",
                    "com.apple.eloquence.fr-FR.Sandy"
                ]
                
                var voiceFound = false
                for voiceID in femaleVoiceIDs {
                    if let voice = frenchVoices.first(where: { $0.identifier == voiceID }) {
                        utterance.voice = voice
                        voiceFound = true
                        print("✅ Voix féminine sélectionnée par identifiant: \(voice.name)")
                        break
                    }
                }
                
                // Si toujours pas de voix, utiliser la première voix française disponible
                if !voiceFound {
                    utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
                    print("⚠️ Fallback sur la voix française par défaut")
                }
            }
        } else {
            // Rechercher d'abord les voix masculines par leur gender
            let frenchMaleVoices = frenchVoices.filter { $0.gender == .male }
            
            if !frenchMaleVoices.isEmpty {
                // Utiliser la première voix masculine disponible
                utterance.voice = frenchMaleVoices.first
                print("✅ Voix masculine sélectionnée par gender: \(utterance.voice?.name ?? "inconnue")")
            } else {
                // Si aucune voix avec gender masculin n'est trouvée, essayer par identifiant
                let maleVoiceIDs = [
                    "com.apple.voice.premium.fr-FR.Thomas",
                    "com.apple.ttsbundle.Thomas-compact",
                    "com.apple.eloquence.fr-FR.Bruno",
                    "com.apple.eloquence.fr-FR.Yannick"
                ]
                
                var voiceFound = false
                for voiceID in maleVoiceIDs {
                    if let voice = frenchVoices.first(where: { $0.identifier == voiceID }) {
                        utterance.voice = voice
                        voiceFound = true
                        print("✅ Voix masculine sélectionnée par identifiant: \(voice.name)")
                        break
                    }
                }
                
                // Si toujours pas de voix, utiliser la première voix française disponible
                if !voiceFound {
                    utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
                    print("⚠️ Fallback sur la voix française par défaut")
                }
            }
        }
        
        // Ajuster les paramètres de la voix en fonction du contexte
        if isGameplay {
            // Paramètres pour le jeu - plus naturel et moins robotique
            utterance.rate = 0.50       // Vitesse adaptée pour le gameplay
            utterance.pitchMultiplier = useFemaleVoice ? 1.2 : 0.95 // Ajuster le pitch selon le genre
            utterance.postUtteranceDelay = 0.05 // Courte pause après l'énonciation
        } else {
            // Paramètres pour le compte à rebours - plus lent et clair
            utterance.rate = 0.45       // Vitesse plus lente pour le compte à rebours
            utterance.pitchMultiplier = useFemaleVoice ? 1.25 : 0.95  // Pitch adapté au genre
        }
        
        utterance.volume = 1.0     // Volume maximum dans tous les cas
    }
    
    private func actuallyStartGame() {
        isGameActive = true
        targetPosition = ChessGame.generateRandomPosition()
        
        // Positionner les dames selon l'option choisie
        switch selectedQueenPosition {
        case .whiteOnBottom:
            isWhiteQueenOnTop = false // Dame blanche en bas
        case .blackOnBottom:
            isWhiteQueenOnTop = true // Dame blanche en haut (donc noire en bas)
        case .random:
            isWhiteQueenOnTop = Bool.random() // Position aléatoire
        }
        
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
    
    // Fonction pour vocaliser la position cible
    private func speakTargetPosition() {
        guard isSpeechEnabled else { return }
        
        // Ne pas prononcer les coordonnées en mode saisie
        if selectedGameMode == .coordinates {
            return
        }
        
        // Utiliser la notation d'origine (sans transformation) pour la synthèse vocale
        let utterance = AVSpeechUtterance(string: targetPosition.notation)
        
        // Configurer la voix avec les paramètres appropriés
        configureVoice(utterance, isGameplay: true)
        
        // Double vérification: s'assurer explicitement que la voix est bien définie selon le genre
        if useFemaleVoice && (utterance.voice == nil || utterance.voice?.gender != .female) {
            // Si aucune voix féminine n'a été définie par configureVoice, forcer une voix française féminine
            let frenchVoices = AVSpeechSynthesisVoice.speechVoices().filter { 
                $0.language.starts(with: "fr") && $0.gender == .female 
            }
            
            if let firstFrenchFemaleVoice = frenchVoices.first {
                print("⚠️ Forçage d'une voix féminine: \(firstFrenchFemaleVoice.name)")
                utterance.voice = firstFrenchFemaleVoice
            } else {
                // Si vraiment aucune voix féminine n'est disponible, utiliser la voix par défaut
                print("⚠️ Aucune voix féminine française trouvée, utilisation de la voix par défaut")
                utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
            }
        }
        
        // Logs pour déboguer
        print("🔊 Lecture position: \(targetPosition.notation) avec voix: \(utterance.voice?.name ?? "inconnue") (féminine: \(useFemaleVoice))")
        
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
        
        // Afficher le formulaire de saisie du nom si le score est positif
        if score > 0 {
            // Pré-remplir le nom avec le dernier joueur
            playerName = getLastPlayerName()
            showNameInput = true
        }
        
        // Ne pas réinitialiser le score pour permettre l'affichage du Game Over
        // Le score sera réinitialisé lors du prochain démarrage de jeu
    }
    
    func checkAnswer(_ position: ChessPosition) {
        guard isGameActive else { return }
        
        // Si la dame noire est en bas (plateau inversé), nous devons adapter la position cible
        let adjustedTargetPosition: ChessPosition
        if isWhiteQueenOnTop {
            // Quand la dame blanche est en haut (dame noire en bas), les coordonnées sont inversées
            // A1 devient H8, B2 devient G7, etc.
            adjustedTargetPosition = ChessPosition(
                file: 7 - targetPosition.file, 
                rank: 7 - targetPosition.rank
            )
        } else {
            // Configuration normale, pas d'ajustement nécessaire
            adjustedTargetPosition = targetPosition
        }
        
        if selectedGameMode == .visual {
            let correctPosition = isWhiteQueenOnTop ? adjustedTargetPosition : targetPosition
            
            if position == correctPosition {
                score += 1
                timeRemaining += 1 // Ajouter une seconde
                message = "Correct!"
                isCorrect = true
                playSuccessSound()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.message = ""
                    
                    // Générer une nouvelle position cible
                    self.targetPosition = ChessGame.generateRandomPosition()
                    
                    // En mode "Aléatoire", changer la position des dames à chaque nouvelle cible
                    if self.selectedQueenPosition == .random {
                        self.isWhiteQueenOnTop = Bool.random()
                    }
                    
                    self.speakTargetPosition()
                }
            } else {
                score -= 1
                message = "Try again!"
                isCorrect = false
                playFailureSound()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.message = ""
                }
            }
        } else {
            // Mode coordonnées
            if let inputPosition = ChessPosition.from(notation: userInput.uppercased()) {
                // Ajuster la position saisie si le plateau est inversé
                let adjustedInputPosition = isWhiteQueenOnTop ? 
                    ChessPosition(file: 7 - inputPosition.file, rank: 7 - inputPosition.rank) : 
                    inputPosition
                
                if adjustedInputPosition == targetPosition {
                    score += 1
                    timeRemaining += 1 // Ajouter une seconde
                    message = "Correct!"
                    isCorrect = true
                    playSuccessSound()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.message = ""
                        
                        // Générer une nouvelle position cible
                        self.targetPosition = ChessGame.generateRandomPosition()
                        
                        // En mode "Aléatoire", changer la position des dames à chaque nouvelle cible
                        if self.selectedQueenPosition == .random {
                            self.isWhiteQueenOnTop = Bool.random()
                        }
                        
                        self.speakTargetPosition()
                        self.userInput = "" // Réinitialiser le champ de saisie
                    }
                } else {
                    score -= 1
                    message = "Try again!"
                    isCorrect = false
                    playFailureSound()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.message = ""
                    }
                }
            }
        }
    }
    
    // Fonction pour lister et logger toutes les voix disponibles
    private func logAvailableVoices() {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        print("------- VOIX DISPONIBLES -------")
        
        // Voix françaises
        let frenchVoices = voices.filter { $0.language.starts(with: "fr") }
        print("VOIX FRANÇAISES (\(frenchVoices.count)):")
        for voice in frenchVoices {
            print("- \(voice.name) [\(voice.identifier)], Genre: \(voice.gender == .female ? "Féminin" : (voice.gender == .male ? "Masculin" : "Non spécifié"))")
        }
        
        // Autres voix
        print("\nAUTRES VOIX (\(voices.count - frenchVoices.count)):")
        for voice in voices where !voice.language.starts(with: "fr") {
            if voice.language.starts(with: "en") {
                print("- \(voice.name) [\(voice.identifier)], Langue: \(voice.language)")
            }
        }
        
        print("-------------------------------")
    }
    
    // Fonction pour sauvegarder un score
    func saveScore() {
        guard !playerName.isEmpty else { return }
        
        let newScore = SavedScore(
            playerName: playerName,
            score: score,
            date: Date(),
            duration: currentDuration,
            gameMode: selectedGameMode.rawValue
        )
        
        highScores.append(newScore)
        
        // Trier les scores par ordre décroissant
        highScores.sort { $0.score > $1.score }
        
        // Limiter à 10 meilleurs scores par mode de jeu
        let visualScores = highScores.filter { $0.gameMode == GameMode.visual.rawValue }
        let coordinatesScores = highScores.filter { $0.gameMode == GameMode.coordinates.rawValue }
        
        if visualScores.count > 10 || coordinatesScores.count > 10 {
            let keptVisualScores = visualScores.count > 10 ? Array(visualScores.prefix(10)) : visualScores
            let keptCoordinatesScores = coordinatesScores.count > 10 ? Array(coordinatesScores.prefix(10)) : coordinatesScores
            
            highScores = keptVisualScores + keptCoordinatesScores
        }
        
        // Sauvegarder les scores
        saveHighScores()
        
        // Sauvegarder le nom du dernier joueur
        UserDefaults.standard.set(playerName, forKey: "lastPlayerName")
        
        // Réinitialiser le nom du joueur et masquer l'input
        playerName = ""
        showNameInput = false
    }
    
    // Charger les meilleurs scores depuis UserDefaults
    private func loadHighScores() {
        if let data = UserDefaults.standard.data(forKey: "highScores") {
            do {
                highScores = try JSONDecoder().decode([SavedScore].self, from: data)
            } catch {
                print("Erreur lors du chargement des scores: \(error)")
            }
        }
    }
    
    // Sauvegarder les meilleurs scores dans UserDefaults
    private func saveHighScores() {
        do {
            let data = try JSONEncoder().encode(highScores)
            UserDefaults.standard.set(data, forKey: "highScores")
        } catch {
            print("Erreur lors de la sauvegarde des scores: \(error)")
        }
    }
    
    // Obtenir le nom du dernier joueur ayant enregistré un score
    private func getLastPlayerName() -> String {
        // Vérifier si nous avons des scores enregistrés
        if let lastScore = UserDefaults.standard.string(forKey: "lastPlayerName") {
            return lastScore
        }
        return ""
    }
} 