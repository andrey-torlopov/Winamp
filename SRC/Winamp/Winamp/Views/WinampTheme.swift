import SwiftUI

enum WinampTheme {
    static let background = Color(red: 0.11, green: 0.11, blue: 0.28)
    static let panel = Color(red: 0.16, green: 0.17, blue: 0.38)
    static let borderLight = Color(red: 0.42, green: 0.44, blue: 0.67)
    static let borderDark = Color(red: 0.05, green: 0.05, blue: 0.16)
    static let neon = Color(red: 0.0, green: 0.95, blue: 0.28)
    static let amber = Color(red: 0.95, green: 0.62, blue: 0.18)
}

struct WinampPanel: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(WinampTheme.panel)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(WinampTheme.borderLight, lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .stroke(WinampTheme.borderDark, lineWidth: 2)
                    .padding(1)
            )
    }
}

extension View {
    func winampPanel() -> some View {
        modifier(WinampPanel())
    }
}
