import Foundation

enum NetworkClientError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case parsingError
}

protocol NetworkClient {
    @discardableResult
    func send(request: NetworkRequest,
              completionQueue: DispatchQueue,
              onResponse: @escaping (Result<Data, Error>) -> Void) -> NetworkTask?

    @discardableResult
    func send<T: Decodable>(request: NetworkRequest,
                            type: T.Type,
                            completionQueue: DispatchQueue,
                            onResponse: @escaping (Result<T, Error>) -> Void) -> NetworkTask?
}

extension NetworkClient {

    @discardableResult
    func send(request: NetworkRequest,
              onResponse: @escaping (Result<Data, Error>) -> Void) -> NetworkTask? {
        send(request: request, completionQueue: .main, onResponse: onResponse)
    }

    @discardableResult
    func send<T: Decodable>(request: NetworkRequest,
                            type: T.Type,
                            onResponse: @escaping (Result<T, Error>) -> Void) -> NetworkTask? {
        send(request: request, type: type, completionQueue: .main, onResponse: onResponse)
    }
}

struct DefaultNetworkClient: NetworkClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(session: URLSession = URLSession.shared,
         decoder: JSONDecoder = JSONDecoder(),
         encoder: JSONEncoder = JSONEncoder()) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    @discardableResult
    func send(
        request: NetworkRequest,
        completionQueue: DispatchQueue,
        onResponse: @escaping (Result<Data, Error>) -> Void
    ) -> NetworkTask? {
        let onResponse: (Result<Data, Error>) -> Void = { result in
            completionQueue.async {
                onResponse(result)
            }
        }
        guard let urlRequest = create(request: request) else { return nil }

        let task = session.dataTask(with: urlRequest) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                onResponse(.failure(NetworkClientError.urlSessionError))
                return
            }

            guard 200 ..< 300 ~= response.statusCode else {
                onResponse(.failure(NetworkClientError.httpStatusCode(response.statusCode)))
                return
            }

            if let data = data {
                onResponse(.success(data))
                return
            } else if let error = error {
                onResponse(.failure(NetworkClientError.urlRequestError(error)))
                return
            } else {
                assertionFailure("Unexpected condition!")
                return
            }
        }

        task.resume()

        return DefaultNetworkTask(dataTask: task)
    }

    @discardableResult
    func send<T: Decodable>(
        request: NetworkRequest,
        type: T.Type,
        completionQueue: DispatchQueue,
        onResponse: @escaping (Result<T, Error>) -> Void
    ) -> NetworkTask? {
        return send(request: request, completionQueue: completionQueue) { result in
            switch result {
            case let .success(data):
                self.parse(data: data, type: type, onResponse: onResponse)
            case let .failure(error):
                onResponse(.failure(error))
            }
        }
    }

    // MARK: - Private

    private func create(request: NetworkRequest) -> URLRequest? {
        guard let endpoint = request.endpoint else {
            assertionFailure("Empty endpoint")
            return nil
        }

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = request.httpMethod.rawValue
        urlRequest.addValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")

        // ✅ Логирование основной информации
        print("🌐 === NETWORK REQUEST DEBUG ===")
        print("📍 URL: \(endpoint.absoluteString)")
        print("📋 Method: \(request.httpMethod.rawValue)")
        print("🔑 Token: \(RequestConstants.token)")

        // ✅ Специальная логика для ChangeOrderRequest
        if let changeOrderRequest = request as? ChangeOrPayOrder {
            print("🔄 ChangeOrderRequest detected")
            print("📦 NFT IDs: \(changeOrderRequest.nftIds)")
            
            let bodyString = changeOrderRequest.nftIds
                .map { "nfts=\($0)" }
                .joined(separator: "&")
            
            print("📝 Body string: \(bodyString)")
            
            urlRequest.httpBody = bodyString.data(using: .utf8)
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            // ✅ Логирование заголовков
            print("🏷️ Headers:")
            urlRequest.allHTTPHeaderFields?.forEach { key, value in
                print("   \(key): \(value)")
            }
            
            // ✅ Логирование тела запроса
            if let bodyData = urlRequest.httpBody,
               let bodyString = String(data: bodyData, encoding: .utf8) {
                print("📄 HTTP Body: \(bodyString)")
            }
            
            print("=== END REQUEST DEBUG ===")
            return urlRequest
        }
        
        // Обычная логика для других запросов
        if let dtoDictionary = request.dto?.asDictionary() {
            print("📋 Regular request with DTO")
            print("📦 DTO: \(dtoDictionary)")
            
            var urlComponents = URLComponents()
            let queryItems = dtoDictionary.map { field in
                URLQueryItem(name: field.key, value: field.value)
            }
            urlComponents.queryItems = queryItems
            urlRequest.httpBody = urlComponents.query?.data(using: .utf8)
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            // ✅ Логирование для обычных запросов
            print("🏷️ Headers:")
            urlRequest.allHTTPHeaderFields?.forEach { key, value in
                print("   \(key): \(value)")
            }
            
            if let bodyData = urlRequest.httpBody,
               let bodyString = String(data: bodyData, encoding: .utf8) {
                print("📄 HTTP Body: \(bodyString)")
            }
        }

        print("=== END REQUEST DEBUG ===")
        return urlRequest
    }

    private func parse<T: Decodable>(data: Data, type _: T.Type, onResponse: @escaping (Result<T, Error>) -> Void) {
        do {
            let response = try decoder.decode(T.self, from: data)
            onResponse(.success(response))
        } catch {
            onResponse(.failure(NetworkClientError.parsingError))
        }
    }
}

