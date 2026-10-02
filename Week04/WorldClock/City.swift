import Foundation

struct City: Identifiable {
    let name: String
    let country: String
    let id: String

    var timeZone: TimeZone { TimeZone(identifier: id) ?? .gmt }

    // Show the time in this city.
    func time(at date: Date, use24Hour: Bool) -> String {
        date.formatted(Date.FormatStyle(
            date: .omitted,
            time: .standard,
            locale: Locale(identifier: use24Hour ? "en_GB" : "en_US"),
            timeZone: timeZone
        ))
    }

    func dateText(at date: Date) -> String {
        date.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted,
                                       locale: Locale(identifier: "en_US"), timeZone: timeZone))
    }

    static let all: [City] = [
        City(name: "New York", country: "United States", id: "America/New_York"),
        City(name: "London", country: "United Kingdom", id: "Europe/London"),
        City(name: "Shanghai", country: "China", id: "Asia/Shanghai"),
        City(name: "Tokyo", country: "Japan", id: "Asia/Tokyo"),
        City(name: "Los Angeles", country: "United States", id: "America/Los_Angeles"),
        City(name: "Chicago", country: "United States", id: "America/Chicago"),
        City(name: "Paris", country: "France", id: "Europe/Paris"),
        City(name: "Cairo", country: "Egypt", id: "Africa/Cairo"),
        City(name: "Dubai", country: "United Arab Emirates", id: "Asia/Dubai"),
        City(name: "Delhi", country: "India", id: "Asia/Kolkata"),
        City(name: "Kathmandu", country: "Nepal", id: "Asia/Kathmandu"),
        City(name: "Bangkok", country: "Thailand", id: "Asia/Bangkok"),
        City(name: "Singapore", country: "Singapore", id: "Asia/Singapore"),
        City(name: "Seoul", country: "South Korea", id: "Asia/Seoul"),
        City(name: "Sydney", country: "Australia", id: "Australia/Sydney"),
        City(name: "Adelaide", country: "Australia", id: "Australia/Adelaide"),
        City(name: "Auckland", country: "New Zealand", id: "Pacific/Auckland"),
        City(name: "São Paulo", country: "Brazil", id: "America/Sao_Paulo")
    ]
}
