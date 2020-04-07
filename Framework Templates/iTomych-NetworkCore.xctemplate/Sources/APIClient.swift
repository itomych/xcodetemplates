// ___FILEHEADER___

@_exported import Alamofire
import AlamofireSessionRenewer

public protocol API {
    func request<Descriptor: RequestDescriptor>(descriptor: Descriptor) -> DataRequest
}

public protocol Uploader {
    func upload<Descriptor: RequestDescriptor>(descriptor: Descriptor, completion: @escaping (UploadRequest) -> Void, onError: @escaping (Error) -> Void)
}

public protocol Downloader {
    func download<Descriptor: RequestDescriptor>(descriptor: Descriptor, to documentUrl: URL) -> DownloadRequest
}

public protocol Authorizable {
    func authorize(with credential: Credential?)
}

extension API {
    public func request<Descriptor: RequestDescriptor>(descriptor: Descriptor, completion: @escaping (DefaultDataResponse) -> Void) -> DataRequest where Descriptor.ResponseType == Void {
        return request(descriptor: descriptor).response(completionHandler: completion)
    }
    
    public func request<Descriptor: RequestDescriptor>(descriptor: Descriptor,
                                                       completion: @escaping (DataResponse<Descriptor.ResponseType>) -> Void) -> DataRequest where Descriptor.ResponseType: Decodable {
        return request(descriptor: descriptor).response(responseSerializer: APIResponseDecodableSerializer(), completionHandler: completion)
    }
    
    public func requestOptional<Descriptor: RequestDescriptor>(descriptor: Descriptor,
                                                               completion: @escaping (DataResponse<Descriptor.ResponseType?>) -> Void) -> DataRequest where Descriptor.ResponseType: Decodable {
        return request(descriptor: descriptor).response(responseSerializer: APIOptionalResponseDecodableSerializer(), completionHandler: completion)
    }
}

extension Uploader {
    public func startUpload<Descriptor: RequestDescriptor>(_ descriptor: Descriptor,
                                                           completion: @escaping ((DataResponse<Descriptor.ResponseType>) -> Void),
                                                           onError: @escaping (Error) -> Void) where Descriptor.ResponseType: Decodable {
        upload(descriptor: descriptor, completion: { uploadRequest in
            uploadRequest.response(responseSerializer: APIResponseDecodableSerializer(), completionHandler: completion)
        }, onError: onError)
    }
}

extension Downloader {
    public func startDownload<Descriptor: RequestDescriptor>(_ descriptor: Descriptor, fileURL: URL) -> DownloadRequest {
        return download(descriptor: descriptor, to: fileURL)
    }
}

public final class APIClient: API, Uploader, Downloader, Authorizable {
    fileprivate let baseURL: URL
    fileprivate let sessionManager: SessionManager
    fileprivate let requestsHandler = RequestsHandler(maxRetryCount: 1, errorDomain: APIError.errorDomain)
    
    public var renewCredential: ((@escaping SuccessRenewHandler, @escaping FailureRenewHandler) -> Void)? {
        get {
            return requestsHandler.renewCredential
        }
        set {
            requestsHandler.renewCredential = newValue
        }
    }
    
    public init(baseURL: URL,
                sessionConfiguration: URLSessionConfiguration? = nil,
                serverTrustPolicyManager: ServerTrustPolicyManager? = nil) {
        self.baseURL = baseURL
        
        let configuration: URLSessionConfiguration
        
        if let sessionConfiguration = sessionConfiguration {
            configuration = sessionConfiguration
        } else {
            configuration = .default
            configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        }
        
        sessionManager = SessionManager(configuration: configuration,
                                        serverTrustPolicyManager: serverTrustPolicyManager)
        sessionManager.adapter = requestsHandler
        sessionManager.retrier = requestsHandler
    }
}

extension API where Self == APIClient {
    public func request<Descriptor: RequestDescriptor>(descriptor: Descriptor) -> DataRequest {
        let url = URL(string: descriptor.path, relativeTo: self.baseURL)!
        let request = self.sessionManager.request(url,
                                                  method: descriptor.method,
                                                  parameters: descriptor.params,
                                                  encoding: descriptor.encoding,
                                                  headers: descriptor.headers)
            .validate(APIResponseValidator)
        request.debugLog()
        return request
    }
}

extension Uploader where Self == APIClient {
    public func upload<Descriptor: RequestDescriptor>(descriptor: Descriptor, completion: @escaping (UploadRequest) -> Void, onError: @escaping (Error) -> Void) {
        let url = URL(string: descriptor.path, relativeTo: self.baseURL)!
        self.sessionManager.upload(multipartFormData: { [weak self] multipartFormData in
            self?.buildMultipartFormData(multipartFormData, descriptor: descriptor)
        }, to: url, method: descriptor.method, headers: descriptor.headers, encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.validate(APIResponseValidator)
                upload.debugLog()
                completion(upload)
            case .failure(let error):
                onError(error)
            }
        })
    }
}

extension Downloader where Self == APIClient {
    public func download<Descriptor: RequestDescriptor>(descriptor: Descriptor, to documentUrl: URL) -> DownloadRequest {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in (documentUrl, [.removePreviousFile]) }
        let url = URL(string: descriptor.path, relativeTo: self.baseURL)!
        let request = self.sessionManager.download(url,
                                                   method: descriptor.method,
                                                   parameters: descriptor.params,
                                                   encoding: descriptor.encoding,
                                                   headers: descriptor.headers,
                                                   to: destination)
            .validate(APIDownloadResponseValidator)
        return request
    }
}

extension APIClient {
    func buildMultipartFormData<Descriptor: RequestDescriptor>(_ multipartFormData: MultipartFormData, descriptor: Descriptor) {
        if let parameters = descriptor.params {
            for (key, value) in parameters {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
        }
        if let mediaParameters = descriptor.mediaParameters {
            multipartFormData.append(mediaParameters.fileURL, withName: mediaParameters.parameterName, fileName: mediaParameters.fileName, mimeType: mediaParameters.mimeType)
        }
    }
}

extension Authorizable where Self == APIClient {
    public func authorize(with credential: Credential?) {
        self.requestsHandler.credential = credential?.bearerToken
    }
}

extension APIClient {
    public var adapter: RequestAdapter? {
        return sessionManager.adapter
    }
}
