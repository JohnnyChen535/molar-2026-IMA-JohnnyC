import Foundation
import Observation

@Observable
class ClockStore {
    var selectedIDs = ["America/New_York", "Europe/London", "Asia/Shanghai", "Asia/Tokyo"]
    var alarm: Alarm?
    var isRinging = false
    var message = ""
    let sound = AlarmSound()

    init() {
        // Read the file if this app has saved cities before.
        do {
            let path = try documentPath(fileName: "cities.json")
            if FileManager.default.fileExists(atPath: path.path) {
                selectedIDs = try loadJSON([String].self, fileName: "cities.json")
            }
        } catch {
            print("Could not load cities: \(error)")
        }

        do {
            let path = try documentPath(fileName: "alarm.json")
            if FileManager.default.fileExists(atPath: path.path) {
                alarm = try loadJSON(Alarm.self, fileName: "alarm.json")
            }
        } catch {
            message = "Could not read the saved alarm."
        }
        skipPastAlarm()
    }

    func save() {
        do {
            try saveJSON(selectedIDs, fileName: "cities.json")
        } catch {
            print("Could not save cities: \(error)")
        }
    }

    func saveAlarm() {
        if let alarm = alarm {
            do {
                try saveJSON(alarm, fileName: "alarm.json")
            } catch {
                message = "Could not save the alarm."
            }
        }
    }

    func setAlarm(_ date: Date) {
        // DatePicker selects minutes, so remove the seconds.
        if let minute = Calendar.current.dateInterval(of: .minute, for: date) {
            let time = minute.start
            if time <= Date() {
                message = "Choose a future time."
                return
            }
            stopAlarm()
            alarm = Alarm(date: time, isOn: true)
            message = ""
            saveAlarm()
        }
    }

    func turnOffAlarm() {
        stopAlarm()
        alarm?.isOn = false
        saveAlarm()
    }

    func checkAlarm(_ now: Date) {
        if let current = alarm, current.isOn, now >= current.date {
            // Turn it off first so it only rings once.
            alarm?.isOn = false
            saveAlarm()
            isRinging = true
            if !sound.play() {
                message = "Alarm time reached. Sound could not play."
            }
        }
    }

    func stopAlarm() {
        sound.stop()
        isRinging = false
    }

    func skipPastAlarm() {
        if let current = alarm, current.isOn, current.date <= Date() {
            alarm?.isOn = false
            message = "The alarm time passed while the app was closed or inactive."
            saveAlarm()
        }
    }

    // Make a list of the selected cities.
    var selectedCities: [City] {
        var cities: [City] = []
        for city in City.all {
            if selectedIDs.contains(city.id) {
                cities.append(city)
            }
        }
        return cities
    }

    func toggle(_ city: City) {
        for index in 0..<selectedIDs.count {
            if selectedIDs[index] == city.id {
                selectedIDs.remove(at: index)
                save()
                return
            }
        }
        selectedIDs.append(city.id)
        save()
    }
}
