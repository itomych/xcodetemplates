// ___FILEHEADER___

import Foundation

public enum APIError: Error {
    case emptyResponseData
    case localizedError(code: Int, userInfo: [String: Any] = [:])
}

extension APIError: CustomNSError {
    public static var errorDomain: String { "com.itomych.api.error" }
    
    public var errorCode: Int {
        if case .localizedError(let code, _) = self {
            return code
        }
        return 0
    }
    
    public var errorUserInfo: [String: Any] {
        if case .localizedError(_, let userInfo) = self {
            return userInfo
        }
        return [:]
    }
}

public extension NSError {
    var isNetworkConnectionFailed: Bool {
        return domain == NSURLErrorDomain && code == NSURLErrorNotConnectedToInternet
    }
    
    var isRequestCancelled: Bool {
        return domain == NSURLErrorDomain && code == NSURLErrorCancelled
    }
}
