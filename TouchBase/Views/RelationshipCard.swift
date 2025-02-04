import SwiftUI

struct RelationshipCard: View {
    let relationship: Relationship
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Text(relationship.name)
                    .font(AppTheme.Typography.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 16) {
                    Label(relationship.group.name, systemImage: "person.2")
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(.secondary)
                    
                    Label(relationship.lastMet.formatted(date: .abbreviated, time: .omitted),
                          systemImage: "calendar")
                        .font(AppTheme.Typography.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(AppTheme.Layout.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassBackground()
        }
        .buttonStyle(CardButtonStyle())
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(AppTheme.Animation.spring, value: configuration.isPressed)
            .shadow(color: .black.opacity(configuration.isPressed ? 0.05 : 0.1),
                   radius: configuration.isPressed ? 4 : 8,
                   x: 0,
                   y: configuration.isPressed ? 2 : 4)
    }
} 