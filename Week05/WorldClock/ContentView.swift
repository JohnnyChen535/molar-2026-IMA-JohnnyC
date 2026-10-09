import SwiftUI

struct ContentView: View {
    // Both pages use the same data.
    @State private var store = ClockStore()
    // Save the city IDs as text, separated by commas.
    @AppStorage("selectedCities") var savedCities = "America/New_York,Europe/London,Asia/Shanghai,Asia/Tokyo"

    var body: some View {
        TabView {
            ClocksView(store: store)
                .tabItem { Label("Clocks", systemImage: "clock") }

            CitiesView(store: store)
                .tabItem { Label("Cities", systemImage: "globe") }
        }
        .onAppear {
            // Read the saved cities when the app opens.
            if savedCities.isEmpty {
                store.selectedIDs = []
            } else {
                store.selectedIDs = savedCities.components(separatedBy: ",")
            }
        }
        .onChange(of: store.selectedIDs) {
            savedCities = store.selectedIDs.joined(separator: ",")
        }
    }
}

struct ClocksView: View {
    @Bindable var store: ClockStore
    // Remember the time format after closing the app.
    @AppStorage("use24Hour") var use24Hour = true

    var body: some View {
        NavigationStack {
            // Update the time every second.
            TimelineView(.periodic(from: .now, by: 1)) { context in
                List {
                    Toggle("24-hour time", isOn: $use24Hour)

                    ForEach(store.selectedCities) { city in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(city.name)
                                Text(city.dateText(at: context.date))
                            }
                            Spacer()
                            Text(city.time(at: context.date, use24Hour: use24Hour))
                                .monospacedDigit()
                        }
                    }

                    if store.selectedCities.isEmpty {
                        Text("Select a city on the Cities page.")
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("World Clock")
        }
    }
}

struct CitiesView: View {
    @Bindable var store: ClockStore

    var body: some View {
        NavigationStack {
            List {
                ForEach(City.all) { city in
                    // Tap a city to add or remove it.
                    Button {
                        store.toggle(city)
                    } label: {
                        HStack {
                            Text(city.name)
                            Spacer()
                            if store.selectedIDs.contains(city.id) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .accessibilityLabel("\(store.selectedIDs.contains(city.id) ? "Remove" : "Add") \(city.name)")
                }
            }
            .listStyle(.plain)
            .navigationTitle("Cities")
        }
    }
}

#Preview{
    ContentView()
}
