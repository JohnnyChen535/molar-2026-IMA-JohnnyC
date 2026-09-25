import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            WindowView()
                .tabItem {
                    Label("Window", systemImage: "window.vertical.closed")
                }

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .tint(Color(red: 0.88, green: 0.73, blue: 0.46))
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
