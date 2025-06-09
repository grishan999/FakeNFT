import Foundation

typealias ProfileCompletion = (
    Result<ProfileModel,
    Error>
) -> Void
typealias ProfilePutCompletion = (
    Result<ProfilePutResponse,
    Error>
) -> Void

protocol ProfileServiceProtocol {
    func loadProfile(completion: @escaping ProfileCompletion)
    func sendProfilePutRequest(
        param1: String,
        param2: String,
        param3: String,
        param4: String,
        completion: @escaping ProfilePutCompletion
    )
}

final class ProfileService: ProfileServiceProtocol {
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func loadProfile(
        completion: @escaping ProfileCompletion
    ) {
        let request = ProfileRequest()
        networkClient.send(
            request: request,
            type: ProfileModel.self
        ) {
            result in
            switch result {
            case .success(let profile):
                completion(.success(profile))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func sendProfilePutRequest(
        param1: String,
        param2: String,
        param3: String,
        param4: String,
        completion: @escaping ProfilePutCompletion
    ) {
        let dto = ProfileDtoObject(
            param1: param1,
            param2: param2,
            param3: param3,
            param4: param4
        )
        let request = ProfilePutRequest(dto: dto)
        networkClient.send(
            request: request,
            type: ProfilePutResponse.self
        ) {
            result in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}


