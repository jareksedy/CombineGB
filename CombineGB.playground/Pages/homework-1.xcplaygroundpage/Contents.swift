//: [Previous](@previous)

import Foundation
import Combine

let myPublisher = Just("Hello, world!")
let mySubscriber = myPublisher.sink(receiveValue: {value in print(value)})
