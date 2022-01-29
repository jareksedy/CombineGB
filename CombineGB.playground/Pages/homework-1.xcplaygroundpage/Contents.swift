//: [Previous](@previous)

import Foundation
import Combine

// 1. Реализовать пользовательский Publisher, который осуществляет рассылку значений примитивных типов
let namesPublisher = ["John", "Paul", "Ringo", "George"].publisher

// 2. Реализовать пользовательский Subscriber, который подписывается на Publisher из первого пункта задания и выполняет какие-либо действия над полученными значениями, после чего выводит результат в консоль.
final class GreetingSubscriber: Subscriber {
    typealias Input = String
    typealias Failure = Never
    
    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }
    
    func receive(_ input: String) -> Subscribers.Demand {
        let greetingOutput = "Hello, \(input)!"
        print(greetingOutput)
        return .none
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("Completion received: \(completion).")
    }
}

let greetingSubscriber = GreetingSubscriber()
namesPublisher.subscribe(greetingSubscriber)

// 3. Реализовать кастомный Subject, который хранит в себе текущее значение, используя тип CurrentValueSubject.
struct MySwitch {
    enum State { case on, off }
    let subject = CurrentValueSubject<State, Never>(.off)
    
    func toggle() {
        subject.send(subject.value == .on ? .off : .on)
    }
}

let mySwitch = MySwitch()

mySwitch.subject.sink { switchState in
    print("Switch is now \(switchState).")
}

mySwitch.toggle()
mySwitch.toggle()
mySwitch.toggle()
mySwitch.toggle()
mySwitch.toggle()
mySwitch.subject.send(.off)
