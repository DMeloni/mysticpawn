import SwiftUI

// Barre de navigation réutilisable
struct NavigationBar: View {
    let title: String
    let leftAction: () -> Void
    let leftIcon: String
    let rightIcon: String
    let rightAction: () -> Void
    
    var body: some View {
        ZStack {
            // Utiliser une couleur uniforme pour toutes les barres de navigation
            AppColors.woodMedium
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
            
            HStack {
                Button(action: leftAction) {
                    Image(systemName: leftIcon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppColors.textLight)
                        .padding(.leading, 16)
                }
                
                Spacer()
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textLight)
                
                Spacer()
                
                Button(action: rightAction) {
                    Image(systemName: rightIcon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppColors.textLight)
                        .padding(.trailing, 16)
                }
            }
        }
        .frame(height: 50)
        .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
        .background(AppColors.woodMedium) // Même couleur que le ZStack
        .ignoresSafeArea(edges: .top)
    }
}

// Élément de menu réutilisable
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
            .foregroundColor(AppColors.accent)
            .padding(.vertical, 12)
        }
    }
}

// Overlay de grain de bois
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

// Définition des couleurs principales de l'application
struct AppColors {
    static let background = Color(hex: "F5F0E5") // Fond clair
    static let woodDark = Color(hex: "8B4513") // Bois foncé
    static let woodMedium = Color(hex: "A0522D") // Bois moyen
    static let woodLight = Color(hex: "CD853F") // Bois clair
    static let accent = Color(hex: "5D4037") // Accent pour le texte
    static let textDark = Color(hex: "292929") // Texte foncé
    static let textLight = Color(hex: "FFFFFF") // Texte clair
    static let lightSquare = Color(hex: "F5F5F5").opacity(0.95) // Cases blanches
    static let darkSquare = Color(hex: "1B1B1B").opacity(0.9) // Cases noires
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

// Définition des types d'écrans dans l'application
enum AppView {
    case home
    case game
    case timerSelection
    case settings
} 