import Foundation

func load(_ file: String) -> String {
    let path = Bundle.main.path(forResource: file, ofType: nil)
    let str = try? String(contentsOfFile: path!, encoding: .utf8)
    return str ?? ""
}

let apple = load("apple.txt").split(separator: "\n")
let banana = load("banana.txt").split(separator: "\n")
let cherries = load("cherries.txt").split(separator: "\n")
let fruits = [apple, banana, cherries]

let columnWidth = 26
var height = 0

for fruit in fruits {
    if fruit.count > height {
        height = fruit.count
    }
}

print("FRUIT TABLE")
print()

for row in 0..<height {
    var line = "    "

    for fruit in fruits {
        let index = row - (height - fruit.count)
        var part = ""

        if index >= 0 {
            part = String(fruit[index])
        }

        line += part + String(repeating: " ", count: columnWidth - part.count)
    }

    print(line)
}

let tableWidth = columnWidth * fruits.count
print("  +" + String(repeating: "-", count: tableWidth) + "+")
print("  |" + String(repeating: "=", count: tableWidth) + "|")

for _ in 1...4 {
    print("    ||" + String(repeating: " ", count: tableWidth - 6) + "||")
}
