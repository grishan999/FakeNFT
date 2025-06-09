import Foundation

struct ProfileRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "")
    }
    var dto: Dto?
}


