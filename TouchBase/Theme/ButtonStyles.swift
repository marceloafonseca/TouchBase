import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.headline)
            .foregroundColor(.white)
            .frame(height: AppTheme.Layout.buttonHeight)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: AppTheme.gradientColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(AppTheme.Layout.buttonHeight / 2)
            .shadow(color: AppTheme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(AppTheme.Animation.spring, value: configuration.isPressed)
    }
}

extension View {
    func primaryButton() -> some View {
        self.buttonStyle(PrimaryButtonStyle())
    }
} 