//: [Previous](@previous)

import Foundation
import Combine

var cancellables = Set<AnyCancellable>()

// Паблишер, испускающий строки с именами.
let namesPublisher = ["Yaroslav", "Vyacheslav"].publisher

// Структура ответа Genderize.io
// Имя, пол, вероятность, количество записей в БД.
struct GenderizeResponse: Codable {
    let name, gender: String
    let probability: Double
    let count: Int
}

// Структура ответа Nationalize.io
// Имя, массив кодов стран с вероятностью принадлежности носителя этого имени к стране.
struct NationalizeResponse: Codable {
    let name: String
    let country: [Country]?
    
    struct Country: Codable {
        let countryId: String
        let probability: Double
        
        enum CodingKeys: String, CodingKey {
            case countryId = "country_id"
            case probability
        }
    }
}

//1. Написать простейший клиент, который обращается к любому открытому API, используя Combine в запросах. (Минимальное количество методов API: 2).
//2. Реализовать отладку любых двух издателей в коде.
class NameAPI {
    var cancellables = Set<AnyCancellable>()
    
    // Имя, по которому будет возвращаться гражданство и пол человека.
    let name: String
    
    // Базовые URL API.
    private let baseUrlNationalizeApi = "https://api.nationalize.io/?name="
    private let baseUrlGenderizeApi = "https://api.genderize.io/?name="
    
    init(_ name: String) {
        self.name = name
    }
    
    func fetch() {
        let publisher = Publishers.Zip(fetchGender(), fetchNation())
        publisher.sink { value in
            print(value.1.country![0].countryId)
        }
        .store(in: &cancellables)
    }
    
    private func fetchNation() -> AnyPublisher<NationalizeResponse, Never> {
        let url = URL(string: baseUrlNationalizeApi + name)!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: NationalizeResponse.self, decoder: JSONDecoder())
            .replaceError(with: NationalizeResponse(name: "", country: nil))
            .eraseToAnyPublisher()
    }
    
    private func fetchGender() -> AnyPublisher<GenderizeResponse, Never> {
        let url = URL(string: baseUrlGenderizeApi + name)!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: GenderizeResponse.self, decoder: JSONDecoder())
            .replaceError(with: GenderizeResponse(name: "", gender: "", probability: 0, count: 0))
            .eraseToAnyPublisher()
    }
}

let nameAPI = NameAPI("Yaroslav")
nameAPI.fetch()

//nameAPI.fetchGender().sink { value in print(value.gender) }.store(in: &cancellables)

//: [Next](@next)
