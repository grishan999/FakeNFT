import Foundation

struct ProfilePutRequest: NetworkRequest {
   var endpoint: URL? {
       URL(string: "8fe8bbb3-b61e-4eff-8973-473d07ceba1c")
   }
   var httpMethod: HttpMethod = .put
   var dto: Dto?
}

struct ProfileDtoObject: Dto {
   let param1: String
   let param2: String
    let param3: String
    let param4: String
    

    enum CodingKeys: String, CodingKey {
        case param1 = "name"
        case param2 = "avatar"
        case param3 = "description"
        case param4 = "website"
    }

    func asDictionary() -> [String : String] {
        [
            CodingKeys.param1.rawValue: param1,
            CodingKeys.param2.rawValue: param2,
            CodingKeys.param3.rawValue: param3,
            CodingKeys.param4.rawValue: param4
        ]
    }
}

struct ProfilePutResponse: Decodable {
    let name: String
    let avatar: String
    let description: String
    let website: String
}


