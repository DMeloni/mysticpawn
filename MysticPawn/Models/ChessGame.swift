import Foundation
import Combine

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
    
    private var timer: AnyCancellable?
    private var countdownTimer: AnyCancellable?
    
    init() {
        self.targetPosition = ChessGame.generateRandomPosition()
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
        
        // Démarrer le compte à rebours
        startCountdown()
    }
    
    private func startCountdown() {
        // Réinitialiser le compte à rebours
        countdownValue = 3
        isCountingDown = true
        
        countdownTimer?.cancel()
        countdownTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.countdownValue > 1 {
                    self.countdownValue -= 1
                } else {
                    // Fin du compte à rebours, démarrer le jeu
                    self.isCountingDown = false
                    self.countdownTimer?.cancel()
                    self.actuallyStartGame()
                }
            }
    }
    
    private func actuallyStartGame() {
        isGameActive = true
        targetPosition = ChessGame.generateRandomPosition()
        
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
    
    // Fonction pour redémarrer le jeu avec la durée mémorisée
    func restartGame() {
        startGame(duration: currentDuration)
    }
    
    func endGame() {
        isGameActive = false
        timer?.cancel()
        timer = nil
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