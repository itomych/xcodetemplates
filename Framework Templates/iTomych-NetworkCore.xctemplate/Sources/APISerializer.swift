// ___FILEHEADER___

import Alamofire

func APIResponseDecodableSerializer<T: Decodable>() -> DataResponseSerializer<T> {
    return DataResponseSerializer { _, _, data, error in
        if let error = error {
            return .failure(error)
        }
        guard let data = data else {
            return .failure(APIError.emptyResponseData)
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let object = try decoder.decode(T.self, from: data)
            return .success(object)
        } catch {
            return .failure(error)
        }
    }
}

func APIOptionalResponseDecodableSerializer<T: Decodable>() -> DataResponseSerializer<T?> {
    return DataResponseSerializer { _, _, data, error in
        if let error = error {
            return .failure(error)
        }
        guard let data = data else {
            return .failure(APIError.emptyResponseData)
        }
        guard !data.isEmpty else {
            return .success(nil)
        }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let object = try decoder.decode(T.self, from: data)
            return .success(object)
        } catch {
            return .failure(error)
        }
    }
}
