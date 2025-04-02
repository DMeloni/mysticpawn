import SwiftUI

struct ContentView: View {
    @StateObject private var game = ChessGame()
    @State private var animationAmount: CGFloat = 0
    @State private var showMenu: Bool = false
    @State private var showTimerSelection: Bool = false
    @State private var currentView: AppView = .game
    
    enum AppView {
        case game
        case timerSelection
    }
    
    var body: some View {
        ZStack {
            // Arrière-plan texturé
            Color(hex: "DCD0C0") // Couleur beige clair pour le fond
                .overlay(
                    WoodGrainOverlay()
                        .opacity(0.1)
                )
                .ignoresSafeArea()
            
            // Contenu principal selon la vue active
            if currentView == .game {
                gameView
            } else if currentView == .timerSelection {
                timerSelectionView
            }
            
            // Menu latéral
            if showMenu {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showMenu.toggle()
                        }
                    }
                
                HStack {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Menu")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "5D4037"))
                            .padding(.top, 50)
                            .padding(.bottom, 20)
                        
                        MenuItemView(iconName: "house.fill", title: "Accueil") {
                            withAnimation {
                                showMenu.toggle()
                                currentView = .timerSelection
                            }
                        }
                        
                        MenuItemView(iconName: "gear", title: "Paramètres") {
                            withAnimation {
                                showMenu.toggle()
                            }
                        }
                        
                        MenuItemView(iconName: "trophy.fill", title: "Classement") {
                            withAnimation {
                                showMenu.toggle()
                            }
                        }
                        
                        MenuItemView(iconName: "info.circle.fill", title: "À propos") {
                            withAnimation {
                                showMenu.toggle()
                            }
                        }
                        
                        Spacer()
                    }
                    .frame(width: 250)
                    .padding(.horizontal, 20)
                    .background(
                        Color(hex: "DCD0C0")
                            .overlay(
                                WoodGrainOverlay()
                                    .opacity(0.2)
                            )
                    )
                    .ignoresSafeArea(edges: .vertical)
                    
                    Spacer()
                }
                .transition(.move(edge: .leading))
            }
            
            // Effet visuel de brillance en cas de succès/échec
            if !game.message.isEmpty && currentView == .game {
                Color(game.isCorrect ? .green : .red)
                    .opacity(0.2 + (animationAmount * 0.4))
                    .ignoresSafeArea()
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.1)) {
                            animationAmount = 1
                        }
                        
                        // Réinitialiser l'animation pour la prochaine fois
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeIn(duration: 0.1)) {
                                animationAmount = 0
                            }
                        }
                    }
            }
            
            // Overlay pour fin de partie
            if !game.isGameActive && game.timeRemaining == 0 && currentView == .game {
                VStack {
                    Text("Game Over!")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    Text("Final Score: \(game.score)")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    Button(action: {
                        currentView = .timerSelection
                    }) {
                        Text("Play Again")
                            .font(.headline)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(Color(hex: "A0522D"))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .shadow(radius: 2)
                    }
                    .padding(.top, 30)
                }
                .padding(40)
                .background(Color.black.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    // Vue du jeu principal
    var gameView: some View {
        VStack(spacing: 0) {
            // Barre de navigation - positionnée tout en haut
            ZStack {
                Color(hex: "CD853F").opacity(0.7)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                
                HStack {
                    Button(action: {
                        withAnimation {
                            showMenu.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(Color(hex: "5D4037"))
                            .padding(.leading, 16)
                    }
                    
                    Spacer()
                    
                    Text("MysticPawn")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "5D4037"))
                    
                    Spacer()
                    
                    Button(action: {
                        // Action pour le bouton d'aide
                    }) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(Color(hex: "5D4037"))
                            .padding(.trailing, 16)
                    }
                }
            }
            .frame(height: 50)
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
            .background(Color(hex: "CD853F").opacity(0.7))
            .ignoresSafeArea(edges: .top)
            
            // Contenu de l'application
            ZStack {
                // Arrière-plan texturé spécifique au contenu
                Color(hex: "DCD0C0") // Couleur beige clair pour le fond
                    .overlay(
                        WoodGrainOverlay()
                            .opacity(0.1)
                    )
                
                VStack(spacing: 10) {
                    HStack {
                        // Position cible sans le "Target:"
                        Text(game.targetPosition.notation)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Color(hex: "373737"))
                            .opacity(game.isGameActive && !game.isCountingDown ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5), value: game.isCountingDown)
                            .scaleEffect(game.isGameActive && !game.isCountingDown ? 1 : 0.5)
                        
                        Spacer()
                        
                        // Timer - visible uniquement quand le jeu est actif (pas pendant le compte à rebours)
                        HStack(spacing: 5) {
                            Image(systemName: "clock")
                                .font(.system(size: 22))
                            Text("\(game.timeRemaining)")
                                .font(.system(size: 26, weight: .bold))
                        }
                        .foregroundColor(game.timeRemaining > 5 ? Color(hex: "373737") : .red)
                        .opacity(game.isGameActive && !game.isCountingDown ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5), value: game.isCountingDown)
                        .scaleEffect(game.isGameActive && !game.isCountingDown ? 1 : 0.5)
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    
                    // Échiquier agrandi
                    GeometryReader { geometry in
                        ZStack {
                            ChessboardView(game: game)
                                .frame(width: geometry.size.width, height: geometry.size.width)
                                .opacity(game.isGameActive || game.isCountingDown ? 1 : 0.7)
                            
                            // Affichage du compte à rebours
                            if game.isCountingDown {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.7))
                                        .frame(width: 120, height: 120)
                                    
                                    Circle()
                                        .stroke(Color(hex: "A0522D"), lineWidth: 6)
                                        .frame(width: 120, height: 120)
                                    
                                    Text("\(game.countdownValue)")
                                        .font(.system(size: 80, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    .frame(height: UIScreen.main.bounds.width) // Définir une hauteur fixe
                    .padding(.horizontal, 0)
                    
                    // Barre de score et bouton
                    HStack {
                        // Score
                        Text("Score: \(game.score)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "373737"))
                        
                        Spacer()
                        
                        // Bouton Start/Restart
                        Button(action: {
                            if game.isGameActive || game.isCountingDown {
                                game.restartGame()
                            } else {
                                currentView = .timerSelection
                            }
                        }) {
                            Text((game.isGameActive || game.isCountingDown) ? "Restart" : "Start")
                                .font(.headline)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(hex: "A0522D"))
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(radius: 2)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
                .padding(0)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    // Vue de sélection du temps
    var timerSelectionView: some View {
        VStack(spacing: 0) {
            // Barre de navigation - positionnée tout en haut
            ZStack {
                Color(hex: "CD853F").opacity(0.7)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                
                HStack {
                    Button(action: {
                        withAnimation {
                            showMenu.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(Color(hex: "5D4037"))
                            .padding(.leading, 16)
                    }
                    
                    Spacer()
                    
                    Text("Sélection du temps")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "5D4037"))
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            currentView = .game
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(Color(hex: "5D4037"))
                            .padding(.trailing, 16)
                    }
                }
            }
            .frame(height: 50)
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
            .background(Color(hex: "CD853F").opacity(0.7))
            .ignoresSafeArea(edges: .top)
            
            // Contenu de la sélection du temps
            VStack(spacing: 30) {
                // Titre
                Text("Choisissez la durée de la partie")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "5D4037"))
                    .padding(.top, 50)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Options de temps
                VStack(spacing: 25) {
                    TimerOptionButton(duration: 20) {
                        startGameWithDuration(20)
                    }
                    
                    TimerOptionButton(duration: 40) {
                        startGameWithDuration(40)
                    }
                    
                    TimerOptionButton(duration: 60) {
                        startGameWithDuration(60)
                    }
                }
                .padding(.top, 30)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(
                Color(hex: "DCD0C0")
                    .overlay(
                        WoodGrainOverlay()
                            .opacity(0.1)
                    )
            )
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    // Fonction pour démarrer le jeu avec la durée sélectionnée
    func startGameWithDuration(_ duration: Int) {
        game.startGame(duration: duration)
        withAnimation {
            currentView = .game
        }
    }
}

struct TimerOptionButton: View {
    let duration: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 24))
                    
                    Text("\(duration) secondes")
                        .font(.system(size: 24, weight: .semibold))
                }
                
                if duration == 20 {
                    Text("(Rapide)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "5D4037").opacity(0.7))
                } else if duration == 40 {
                    Text("(Normal)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "5D4037").opacity(0.7))
                } else {
                    Text("(Détendu)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "5D4037").opacity(0.7))
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 30)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "A0522D").opacity(0.9),
                        Color(hex: "8B4513").opacity(0.9)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
        }
    }
}

struct MenuItemView: View {
    let iconName: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.system(size: 22))
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                
                Spacer()
            }
            .foregroundColor(Color(hex: "5D4037"))
            .padding(.vertical, 12)
        }
    }
}

struct WoodGrainOverlay: View {
    var body: some View {
        Canvas { context, size in
            // Dessiner des lignes aléatoires pour simuler le grain du bois
            for _ in 0..<200 {
                let startX = CGFloat.random(in: 0...size.width)
                let startY = CGFloat.random(in: 0...size.height)
                let length = CGFloat.random(in: 5...30)
                let angle = CGFloat.random(in: -10...10)
                
                var path = Path()
                path.move(to: CGPoint(x: startX, y: startY))
                path.addLine(to: CGPoint(
                    x: startX + length * cos(angle * .pi / 180),
                    y: startY + length * sin(angle * .pi / 180)
                ))
                
                context.stroke(
                    path,
                    with: .color(Color(hex: "8B4513").opacity(CGFloat.random(in: 0.03...0.1))),
                    lineWidth: CGFloat.random(in: 0.5...1.5)
                )
            }
        }
    }
}

struct ChessboardView: View {
    @ObservedObject var game: ChessGame
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 8)
    
    var body: some View {
        ZStack {
            // Arrière-plan en bois vieilli
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "8B4513").opacity(0.85),  // Brun Saddle
                    Color(hex: "A0522D").opacity(0.9),   // Brun Sienna
                    Color(hex: "CD853F").opacity(0.85),  // Peru
                    Color(hex: "A0522D").opacity(0.9)    // Brun Sienna
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
                    .stroke(Color(hex: "5D4037"), lineWidth: 3)
            )
            
            // Échiquier avec Grid explicite
            VStack(spacing: 0) {
                ForEach((0...7).reversed(), id: \.self) { rank in
                    HStack(spacing: 0) {
                        ForEach(0...7, id: \.self) { file in
                            let position = ChessPosition(file: file, rank: rank)
                            SquareView(position: position, game: game)
                                .aspectRatio(1, contentMode: .fill)
                        }
                    }
                }
            }
            .padding(2)
        }
        .clipShape(RoundedRectangle(cornerRadius: 2))
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

struct SquareView: View {
    let position: ChessPosition
    @ObservedObject var game: ChessGame
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
                    .fill((position.file + position.rank) % 2 == 0 ? 
                          Color(hex: "F5F5F5").opacity(0.9) : // Blanc légèrement atténué
                          Color(hex: "1B1B1B").opacity(0.85)) // Noir légèrement atténué
                    .aspectRatio(1, contentMode: .fill)
                
                // Bordure intérieure qui s'accentue lors du clic
                Rectangle()
                    .strokeBorder(
                        (position.file + position.rank) % 2 == 0 ? 
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
