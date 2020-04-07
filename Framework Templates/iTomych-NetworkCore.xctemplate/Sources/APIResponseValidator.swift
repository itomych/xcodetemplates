// ___FILEHEADER___

import Alamofire

func APIResponseValidator(request _: URLRequest?, response: HTTPURLResponse, data: Data?) -> Request.ValidationResult {
    response.debugLog(with: data)
    let statusCode = response.statusCode
    switch statusCode {
    case 400 ... Int.max:
        guard let data = data else {
            return .failure(APIError.localizedError(code: statusCode))
        }
        do {
            let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
            let userInfo = [NSLocalizedDescriptionKey: errorResponse.errorMessage]
            return .failure(APIError.localizedError(code: statusCode, userInfo: userInfo))
        } catch {
            return .failure(APIError.localizedError(code: statusCode))
        }
    default:
        return .success
    }
}

func APIDownloadResponseValidator(request: URLRequest?, response: HTTPURLResponse, temporaryURL _: URL?, destinationURL _: URL?) -> DownloadRequest.ValidationResult {
    return APIResponseValidator(request: request, response: response, data: nil)
}

public extension APIError {
    var isClient: Bool { (400 ... 499).contains(errorCode) }
    var isUnauthorized: Bool { errorCode == 401 }
}

public struct APIErrorResponse: Codable {
    let errorMessage: String
    let errorCode: String
}
