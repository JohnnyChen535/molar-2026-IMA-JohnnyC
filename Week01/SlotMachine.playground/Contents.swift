// Week 01 — Fruit Machine
// A little slot machine that runs in the console.
// AI helped with the starter code.

let symbols = ["CHERRY", "LEMON ", "GRAPE ", "APPLE "]
let rounds = 3
var totalScore = 0

// Pick symbols. Swift's range here includes 0, 1, and 2.
func spin() -> [String] {
    var result: [String] = []
    for _ in 0..<3 {
        let index = Int.random(in: 0..<symbols.count)
        result.append(symbols[index])
    }
    return result
}

// All three match: 10 points. Any pair: 3 points. Otherwise: 0.
func getScore(reels: [String]) -> Int {
    if reels[0] == reels[1] && reels[1] == reels[2] {
        return 10
    } else if reels[0] == reels[1] || reels[0] == reels[2] || reels[1] == reels[2] {
        return 3
    } else {
        return 0
    }
}

// The fruit names are padded to the same width to keep the frame lined up.
func drawMachine(reels: [String]) {
    print("      .--------------------------.")
    print("      |       FRUIT MACHINE      |")
    print("      |--------------------------|   O")
    print("      |  \(reels[0])| \(reels[1])| \(reels[2])  |   |")
    print("      |--------------------------|---+")
    print("      |       [ SPIN AGAIN ]     |")
    print("      '--------------------------'")
}

print("FRUIT MACHINE")
print("Three matching fruits = 10 points. A pair = 3 points.")

for round in 1...rounds {
    print("\nROUND \(round)")
    let reels = spin()
    drawMachine(reels: reels)
    let points = getScore(reels: reels)
    totalScore += points

    if points == 10 {
        print("JACKPOT! +10 points")
    } else if points == 3 {
        print("A pair! +3 points")
    } else {
        print("No match this round.")
    }
    print("Score: \(totalScore)")
}

print("\nFinal score: \(totalScore) / \(rounds * 10)")
print("Run again for another game.")

// Notes for later:
// The SPIN AGAIN label is text art, not a clickable button.
// spin() always returns three items, which getScore and drawMachine expect.
// Keep rounds above zero.
//
