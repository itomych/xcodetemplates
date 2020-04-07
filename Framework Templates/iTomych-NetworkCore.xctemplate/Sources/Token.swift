// ___FILEHEADER___

import Foundation

public struct Token {
    let rawValue: String
    
    public let expirationDate: Date?
    
    public init?(rawValue token: String) {
        rawValue = token
        
        let components = token.components(separatedBy: ".")
        
        // In general case JWT token contains 3 part: header, payload and signature. It's base64 encoded strings separated by a point.
        // All data that we need is situated in payload
        guard components.count >= 2 else { return nil }
        var component = components[1]
        
        // Base 64 encoded string contains blocks of characters. Each block should contains 4 characters. If last block will contain
        // less character - Data.init(base64Encoded) returns nil. So we need to add padding by ourselfs.
        (0 ..< component.count % 4).forEach { _ in component.append("=") }
        guard let data = Data(base64Encoded: component) else { return nil }
        
        let payload = try? JSONDecoder().decode(JWTTokenPayload.self, from: data)
        
        if let expiration = payload?.exp {
            expirationDate = Date(timeIntervalSince1970: TimeInterval(expiration))
        } else {
            expirationDate = nil
        }
    }
}

private struct JWTTokenPayload: Decodable {
    let exp: Int
}
