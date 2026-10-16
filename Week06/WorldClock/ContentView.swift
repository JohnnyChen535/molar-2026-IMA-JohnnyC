import SwiftUI
import Combine

struct ContentView: View {
    // All pages use the same data.
    @State private var store = ClockStore()
    @Environment(\.scenePhase) private var scenePhase
    // The class TimerDemo uses this timer to check every second.
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            if store.isRinging {
                Text("Alarm time reached")
                Button("Stop alarm") {
                    store.stopAlarm()
                }
            }
            TabView {
                ClocksView(store: store)
                    .tabItem { Label("Clocks", systemImage: "clock") }

                CitiesView(store: store)
                    .tabItem { Label("Cities", systemImage: "globe") }

                AlarmView(store: store)
                    .tabItem { Label("Alarm", systemImage: "alarm") }
            }
        }
        .onReceive(timer) { now in
            if scenePhase == .active {
                store.checkAlarm(now)
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                store.skipPastAlarm()
            } else {
                store.stopAlarm()
            }
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
