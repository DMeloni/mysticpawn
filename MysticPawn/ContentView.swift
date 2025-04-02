import SwiftUI

struct ContentView: View {
    @StateObject private var game = ChessGame()
    
    var body: some View {
        VStack(spacing: 30) {
            // Target position
            Text("Target: \(game.targetPosition.notation)")
                .font(.system(size: 40, weight: .bold))
            
            // Échiquier
            ChessboardView(game: game)
                .aspectRatio(1, contentMode: .fit)
                .padding(.horizontal, 20)
            
            // Message de feedback
            if !game.message.isEmpty {
                FeedbackView(isCorrect: game.isCorrect)
            }
            
            // Score
            Text("Score: \(game.score)")
                .font(.system(size: 40, weight: .bold))
        }
        .padding()
    }
}

struct ChessboardView: View {
    @ObservedObject var game: ChessGame
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 8)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            ForEach((0...7).reversed(), id: \.self) { rank in
                ForEach(0...7, id: \.self) { file in
                    let position = ChessPosition(file: file, rank: rank)
                    SquareView(position: position, game: game)
                }
            }
        }
        .background(Color(white: 0.95))
        .clipShape(Rectangle())
        .overlay(
            Rectangle()
                .stroke(Color(white: 0.8), lineWidth: 1)
        )
    }
}

struct SquareView: View {
    let position: ChessPosition
    @ObservedObject var game: ChessGame
    
    var body: some View {
        Button(action: {
            game.checkAnswer(position)
        }) {
            Rectangle()
                .fill((position.file + position.rank) % 2 == 0 ? Color(hex: "F4D03F") : Color(hex: "B7950B"))
                .aspectRatio(1, contentMode: .fill)
        }
    }
}

struct FeedbackView: View {
    let isCorrect: Bool
    
    var body: some View {
        HStack {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
            Text(isCorrect ? "Correct!" : "Try again!")
                .font(.title2)
        }
        .foregroundColor(isCorrect ? .green : .red)
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
        )
        .padding(.horizontal)
    }
}

// Extension pour supporter les couleurs hexadécimales
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Preview pour iOS 16
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
