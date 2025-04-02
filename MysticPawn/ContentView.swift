import SwiftUI

struct ContentView: View {
    @StateObject private var game = ChessGame()
    @State private var animationAmount: CGFloat = 0
    @State private var showMenu: Bool = false
    @State private var currentView: AppView = .timerSelection
    
    var body: some View {
        ZStack {
            // Arrière-plan texturé
            AppColors.background
                .overlay(
                    WoodGrainOverlay()
                        .opacity(0.1)
                )
                .ignoresSafeArea()
            
            // Contenu principal selon la vue active
            if currentView == .game {
                GameView(game: game, currentView: $currentView, showMenu: $showMenu)
            } else if currentView == .timerSelection {
                TimerSelectionView(game: game, currentView: $currentView, showMenu: $showMenu)
            } else if currentView == .settings {
                SettingsView(game: game, currentView: $currentView, showMenu: $showMenu)
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
                            .foregroundColor(AppColors.accent)
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
                                currentView = .settings
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
                        AppColors.background
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
                GameOverView(game: game, currentView: $currentView)
            }
        }
    }
}

// Preview pour iOS 16
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
