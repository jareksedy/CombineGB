//: [Previous](@previous)

import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

// 1. Создайте первый издатель, производный от Subject, который испускает строки.
// 2. Используйте .collect() со стратегией .byTime для группировки данных через каждые 0.5 секунд.
// 3. Преобразуйте каждое значение в Unicode.Scalar, затем в Character, а затем превратите весь массив в строку с помощью .map().
let stringSubject = PassthroughSubject<String, Never>()
let publisher1 = stringSubject
    .map{ string in return string.map{$0}}
    .map{ String($0) }

//4. Создайте второй издатель, производный от Subject, который измеряет интервалы между каждым символом. Если интервал превышает 0,9 секунды, сопоставьте это значение с эмодзи. В противном случае сопоставьте его с пустой строкой.
let publisher2 = stringSubject
    .measureInterval(using: DispatchQueue.main)
    .map {return $0 < 0.9 ? "🤪" : ""}
    .merge(with: publisher1)
    .sink{ value in print(value) }
    .store(in: &subscriptions)

//5. Окончательный издатель — это слияние двух предыдущих издателей строк и эмодзи. Отфильтруйте пустые строки для лучшего отображения.
//6. Результат выведите в консоль.

stringSubject.send("Fuck this shitty homework!")

//: [Next](@next)
