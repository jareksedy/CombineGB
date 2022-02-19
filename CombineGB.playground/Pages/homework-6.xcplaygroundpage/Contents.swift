//: [Previous](@previous)

import Foundation
import Combine

// ---------------------------------------------------------------------------------
//
// ДЗ №6
// 1. Реализовать обработку ошибок внутри созданного на прошлом уроке API клиента.
//
// ---------------------------------------------------------------------------------

var cancellables = Set<AnyCancellable>()

// Енумчик с ошибками
enum MyError: Error {
    case fetchingError, decodingError
}

extension MyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .fetchingError:
            return "Ошибка получения данных с сервера."
        case .decodingError:
            return "Ошибка парсинга полученных данных."
        }
    }
}

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
class NameApi {
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
        
        publisher
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error): print(error.localizedDescription)
                case .finished: break
                }
            },
                  receiveValue: { value in
                let gender = value.0.gender == "male" ? "👨🏻 (мужской)" : "👩🏻 (женский)"
                
                print("Имя: \(self.name)")
                print("Пол: \(gender) с вероятностью \(value.0.probability * 100) % на основании \(value.0.count) записей в БД.")
                
                if let countries = value.1.country {
                    for country in countries {
                        print("\(self.flagEmoji(from: country.countryId)) \(self.countryName(from: country.countryId) ?? "Н/Д") с вероятностью \((country.probability * 100).rounded()) %.")
                    }
                }
                
                print()
                print()
            })
        .store(in: &cancellables)
    }
    
    private func fetchNation() -> AnyPublisher<NationalizeResponse, Error> {
        let url = URL(string: baseUrlNationalizeApi + name)!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { error -> MyError in return MyError.fetchingError }
            .map { $0.data }
            .decode(type: NationalizeResponse.self, decoder: JSONDecoder())
            .mapError { error -> MyError in return MyError.decodingError }
            //.replaceError(with: MyError.fetchingError)
            .eraseToAnyPublisher()
    }
    
    private func fetchGender() -> AnyPublisher<GenderizeResponse, Error> {
        let url = URL(string: baseUrlGenderizeApi + name)!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { error -> MyError in return MyError.fetchingError }
            .map { $0.data }
            .decode(type: GenderizeResponse.self, decoder: JSONDecoder())
            .mapError { error -> MyError in return MyError.decodingError }
            //.replaceError(with: GenderizeResponse(name: "", gender: "", probability: 0, count: 0))
            .eraseToAnyPublisher()
    }
    
    // Преобразует код страны в эмодзи флага этой страны.
    private func flagEmoji(from countryCode: String) -> String {
        let base: UInt32 = 127397
        return countryCode.uppercased().unicodeScalars.map { String(UnicodeScalar(base + $0.value)!) }.joined()
    }
    
    // Преобразует код страны в название этой страны в текущей локали.
    private func countryName(from countryCode: String) -> String? {
        return (Locale.current as NSLocale).displayName(forKey: .countryCode, value: countryCode)
    }
}

// Паблишер, испускающий строки с именами, гражданство и пол которых мы будем предсказывать с помощью открытого API.
let namesPublisher = ["Yaroslav", "Vyacheslav", "Slava", "Meruert", "Fatma", "Anna", "Cthulhu", "Lenin", "Pedro", "Dazdraperma", "Kumar", "Motherfucker", "Jah"].publisher

// Подписываемся и обращаемся к двум различным API для определения пола и гражданства.
namesPublisher
    .sink { value in NameApi(value).fetch() }
    .store(in: &cancellables)

//: [Next](@next)
