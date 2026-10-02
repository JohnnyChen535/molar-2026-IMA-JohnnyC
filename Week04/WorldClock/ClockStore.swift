import Observation

@Observable
class ClockStore {
    var selectedIDs = ["America/New_York", "Europe/London", "Asia/Shanghai", "Asia/Tokyo"]
    var use24Hour = true

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
                return
            }
        }
        selectedIDs.append(city.id)
    }
}
