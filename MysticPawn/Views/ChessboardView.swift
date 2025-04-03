import SwiftUI

struct ChessboardView: View {
    @ObservedObject var game: ChessGame
    
    var body: some View {
        ZStack {
            // Arrière-plan en bois vieilli
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: game.selectedTheme.borderColor).opacity(0.85),
                    Color(hex: game.selectedTheme.borderColor).opacity(0.9),
                    Color(hex: game.selectedTheme.borderColor).opacity(0.85),
                    Color(hex: game.selectedTheme.borderColor).opacity(0.9)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                VeinedWoodOverlay()
                    .opacity(0.15)
            )
            .overlay(
                // Bordure en bois plus foncée (plus fine)
                RoundedRectangle(cornerRadius: 2)
                    .stroke(Color(hex: game.selectedTheme.borderColor), lineWidth: 3)
            )
            
            // Échiquier avec Grid explicite - on inverse tout quand la reine noire est en bas
            if !game.isWhiteQueenOnTop {
                // Plateau inversé (rotation 180°)
                VStack(spacing: 0) {
                    ForEach(0...7, id: \.self) { rank in
                        HStack(spacing: 0) {
                            ForEach((0...7).reversed(), id: \.self) { file in
                                // Les positions restent les mêmes, c'est l'affichage qui est inversé
                                let position = ChessPosition(file: file, rank: rank)
                                SquareView(position: position, game: game, isInverted: true)
                                    .aspectRatio(1, contentMode: .fill)
                            }
                        }
                    }
                }
                .padding(2)
                .rotationEffect(.degrees(180)) // Rotation pour inverser complètement le plateau
            } else {
                // Plateau normal
                VStack(spacing: 0) {
                    ForEach((0...7).reversed(), id: \.self) { rank in
                        HStack(spacing: 0) {
                            ForEach(0...7, id: \.self) { file in
                                let position = ChessPosition(file: file, rank: rank)
                                SquareView(position: position, game: game, isInverted: false)
                                    .aspectRatio(1, contentMode: .fill)
                            }
                        }
                    }
                }
                .padding(2)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 2))
    }
}

struct SquareView: View {
    let position: ChessPosition
    @ObservedObject var game: ChessGame
    let isInverted: Bool // Indique si le plateau est inversé
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Effet d'impact tactile
            #if os(iOS)
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
            #endif
            
            // Effet poussoir amélioré
            withAnimation(.spring(response: 0.1, dampingFraction: 0.35, blendDuration: 0.1)) {
                isPressed = true
            }
            
            // Réinitialiser l'animation après un court délai
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.45)) {
                    isPressed = false
                }
            }
            
            game.checkAnswer(position)
        }) {
            ZStack {
                // Case principale
                Rectangle()
                    .fill((position.file + position.rank) % 2 == 1 ? 
                          Color(hex: game.selectedTheme.lightSquareColor).opacity(0.95) : // Case blanche
                          Color(hex: game.selectedTheme.darkSquareColor).opacity(0.9)) // Case noire
                    .aspectRatio(1, contentMode: .fill)
                
                // Surbrillance lors de la sélection
                if isPressed {
                    Rectangle()
                        .fill(Color(hex: game.selectedTheme.highlightColor).opacity(0.5))
                        .scaleEffect(0.92)
                        .animation(.easeInOut(duration: 0.2), value: isPressed)
                }
                
                // Bordure intérieure qui s'accentue lors du clic
                Rectangle()
                    .strokeBorder(
                        (position.file + position.rank) % 2 == 1 ? 
                            Color.black.opacity(isPressed ? 0.25 : 0.1) : 
                            Color.white.opacity(isPressed ? 0.25 : 0.1),
                        lineWidth: isPressed ? 2 : 1
                    )
                
                // Reflet lumineux qui change lors du clic
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(isPressed ? 0.1 : 0.2),
                                Color.white.opacity(0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(isPressed ? 0.5 : 1.0)
                
                // Dame blanche en D1 ou en E8
                if ((position.file == 3 && position.rank == 0 && !game.isWhiteQueenOnTop) || 
                   (position.file == 4 && position.rank == 7 && game.isWhiteQueenOnTop)) && 
                   !game.isCountingDown {
                    Image("white_queen")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .zIndex(10)
                        .rotationEffect(isInverted ? .degrees(180) : .degrees(0))
                }
                
                // Dame noire en D8 ou en E1
                if ((position.file == 3 && position.rank == 7 && !game.isWhiteQueenOnTop) || 
                   (position.file == 4 && position.rank == 0 && game.isWhiteQueenOnTop)) && 
                   !game.isCountingDown {
                    Image("black_queen")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .zIndex(10)
                        .rotationEffect(isInverted ? .degrees(180) : .degrees(0))
                }
            }
            .shadow(color: Color.black.opacity(isPressed ? 0.1 : 0.2), 
                    radius: isPressed ? 1 : 3, 
                    x: 0, 
                    y: isPressed ? 1 : 2)
            // Effet de zoom et d'enfoncement
            .scaleEffect(isPressed ? 0.92 : 1)
            .offset(y: isPressed ? 2 : 0)
            // Perspective 3D avec meilleur axe
            .rotation3DEffect(
                .degrees(isPressed ? 5 : 0),
                axis: (x: 1, y: 1, z: 0),
                anchor: .center,
                anchorZ: 0,
                perspective: 0.3
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!game.isGameActive || game.isCountingDown) // Désactiver pendant le compte à rebours
        .compositingGroup() // Groupe pour empêcher la modification d'opacité sur les enfants
    }
}

struct VeinedWoodOverlay: View {
    let numberOfLines = 40
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<numberOfLines, id: \.self) { index in
                let yPosition = CGFloat(index) * (geometry.size.height / CGFloat(numberOfLines))
                let width = CGFloat.random(in: 0.3...2.5)
                let opacity = Double.random(in: 0.1...0.5)
                
                Path { path in
                    path.move(to: CGPoint(x: 0, y: yPosition))
                    path.addQuadCurve(
                        to: CGPoint(x: geometry.size.width, y: yPosition + CGFloat.random(in: -10...10)),
                        control: CGPoint(x: geometry.size.width / 2, y: yPosition + CGFloat.random(in: -15...15))
                    )
                }
                .stroke(Color.black, lineWidth: width)
                .opacity(opacity)
            }
        }
    }
} 