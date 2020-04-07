// ___FILEHEADER___

import Alamofire

public struct MediaParameters {
    let fileURL: URL
    let parameterName: String
    let fileName: String
    let mimeType: String
    
    public init(fileURL: URL,
                parameterName: String,
                fileName: String,
                mimeType: String) {
        self.fileURL = fileURL
        self.parameterName = parameterName
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

public protocol RequestDescriptor {
    associatedtype ResponseType
    
    var path: String { get }
    var method: HTTPMethod { get }
    var encoding: ParameterEncoding { get }
    var params: Parameters? { get }
    var headers: HTTPHeaders? { get }
    var mediaParameters: MediaParameters? { get }
}

extension RequestDescriptor {
    public var params: Parameters? { nil }
    public var headers: HTTPHeaders? { nil }
    public var mediaParameters: MediaParameters? { nil }
}
