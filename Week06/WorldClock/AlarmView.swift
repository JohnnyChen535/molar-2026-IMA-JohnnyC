import SwiftUI

struct AlarmView: View {
    @Bindable var store: ClockStore
    @AppStorage("use24Hour") var use24Hour = true
    @State private var selectedTime = Date()

    var body: some View {
        NavigationStack {
            List {
                Text("Set in your phone's time zone: \(TimeZone.current.identifier)")
                DatePicker("Alarm time", selection: $selectedTime,
                           displayedComponents: [.date, .hourAndMinute])
                Button("Set alarm") {
                    store.setAlarm(selectedTime)
                }
                Text("Keep the app open with sound on. This alarm rings once.")

                if !store.message.isEmpty {
                    Text(store.message)
                }

                if let alarm = store.alarm {
                    Text(alarm.isOn ? "Alarm is on" : "Alarm is off")
                    if alarm.isOn {
                        Button("Turn off alarm") {
                            store.turnOffAlarm()
                        }
                    }

                    // Show the same alarm in every selected city's time zone.
                    ForEach(store.selectedCities) { city in
                        VStack(alignment: .leading) {
                            Text(city.name)
                            Text(city.dateText(at: alarm.date))
                            Text(city.time(at: alarm.date, use24Hour: use24Hour))
                        }
                    }
                    if store.selectedCities.isEmpty {
                        Text("Select cities to see their alarm times.")
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Alarm")
            .onAppear {
                if let alarm = store.alarm {
                    selectedTime = alarm.date
                }
            }
        }
    }
}
