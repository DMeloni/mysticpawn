import Foundation

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
    
    init() {
        self.targetPosition = ChessGame.generateRandomPosition()
    }
    
    static func generateRandomPosition() -> ChessPosition {
        ChessPosition(
            file: Int.random(in: 0...7),
            rank: Int.random(in: 0...7)
        )
    }
    
    func checkAnswer(_ position: ChessPosition) {
        if position == targetPosition {
            score += 1
            message = "Correct!"
            isCorrect = true
            
            // Délai avant de générer une nouvelle position
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.message = ""
                self.targetPosition = ChessGame.generateRandomPosition()
            }
        } else {
            message = "Try again!"
            isCorrect = false
            
            // Effacer le message d'erreur après un délai
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.message = ""
            }
        }
    }
} 