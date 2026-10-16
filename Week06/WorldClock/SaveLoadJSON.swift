import Foundation

// Based on the Week06 ImageEditDemoJSON example.
// https://github.com/molab-itp/06-ImageEditDemoJSON

func documentPath(fileName: String) throws -> URL {
    let directory = try FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    )
    return directory.appendingPathComponent(fileName)
}

func saveJSON<T: Encodable>(_ value: T, fileName: String) throws {
    let path = try documentPath(fileName: fileName)
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try encoder.encode(value)
    let text = String(data: data, encoding: .utf8)!
    try text.write(to: path, atomically: true, encoding: .utf8)
}

func loadJSON<T: Decodable>(_ type: T.Type, fileName: String) throws -> T {
    let path = try documentPath(fileName: fileName)
    let text = try String(contentsOfFile: path.path, encoding: .utf8)
    let data = text.data(using: .utf8)!
    let decoder = JSONDecoder()
    return try decoder.decode(type, from: data)
}
