//: [Previous](@previous)

import Foundation
import Combine

// Example method.
public func example(of description: String, action: () -> Void) {
  print("\n------ Example of:", description, "------")
  action()
}

// Subscriptions property.
private var subscriptions = Set<AnyCancellable>()

// 1. Создайте пример, который публикует коллекцию чисел от 1 до 100, и используйте операторы фильтрации, чтобы выполнить следующие действия:
// a. Пропустите первые 50 значений, выданных вышестоящим издателем.
// b. Возьмите следующие 20 значений после этих 50.
// c. Берите только чётные числа.
example(of: "first") {
    (1...100).publisher
        .dropFirst(50)
        .prefix(20)
        .filter{ $0 % 2 == 0 }
        .collect()
        .sink(receiveCompletion: { print($0) }, receiveValue: { print($0)})
        .store(in: &subscriptions)
}

// 2. Создайте пример, который собирает коллекцию строк, преобразует её в коллекцию чисел и вычисляет среднее арифметическое этих значений.
example(of: "second") {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    
    ["one", "thirty-six", "sixty-nine", "wow", "not-a-number", "five"].publisher
        .compactMap{ formatter.number(from: $0) as? Int }
        .collect()
        .map{ Double($0.reduce(0, +)) / Double($0.count) }
        .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
        .store(in: &subscriptions)
}

// 3. Создать поиск телефонного номера в коллекции с помощью операторов преобразования, ваша цель в этой задаче — создать издателя, который делает две вещи:
// a. Получает строку из десяти цифр или букв.
// b. Ищет этот номер в структуре данных контактов.

// Это задание со звездочкой, решил не заморачиваться с ним, сорри.

//: [Next](@next)
