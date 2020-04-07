// ___FILEHEADER___

public struct Credential: Codable {
    public let accessToken: String
    public let refreshToken: String
    
    public var bearerToken: String { "Bearer \(accessToken)" }
    
    public init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
