// ___FILEHEADER___

import Alamofire
import AlamofireSessionRenewer

final class RequestsHandler: AlamofireSessionRenewer, RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard let cred = credential else { return urlRequest }
        var updatedRequest = urlRequest
        updatedRequest.setValue(cred, forHTTPHeaderField: credentialHeaderField)
        return updatedRequest
    }
}
