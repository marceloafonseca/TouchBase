import SwiftUI

enum AppTheme {
    static let primaryColor = Color("AccentBlue")
    static let secondaryColor = Color("VibrantPurple")
    static let backgroundColor = Color("BackgroundColor")
    static let cardBackground = Color("CardBackground")
    
    static let gradientColors = [
        Color("GradientStart"),
        Color("GradientEnd")
    ]
    
    enum Typography {
        static let title = Font.system(size: 34, weight: .bold)
        static let headline = Font.system(.title2, design: .rounded, weight: .bold)
        static let subheadline = Font.system(.subheadline, design: .rounded, weight: .semibold)
        static let body = Font.system(.body, design: .rounded)
        static let caption = Font.system(.caption, design: .rounded)
    }
    
    struct Animation {
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let easeOut = SwiftUI.Animation.easeOut(duration: 0.2)
    }
    
    struct Layout {
        static let cornerRadius: CGFloat = 16
        static let buttonHeight: CGFloat = 56
        static let cardPadding: CGFloat = 16
    }
}

struct GlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(AppTheme.cardBackground.opacity(0.5))
            .cornerRadius(AppTheme.Layout.cornerRadius)
    }
}

extension View {
    func glassBackground() -> some View {
        modifier(GlassBackground())
    }
} 