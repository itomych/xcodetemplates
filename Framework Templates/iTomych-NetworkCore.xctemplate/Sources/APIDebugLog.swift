// ___FILEHEADER___

import Alamofire

extension Request {
    public func debugLog() {
        #if DEBUG
            guard ProcessInfo.processInfo.showNetworkLogs else { return }
            print("""
            ==============================================
            \(self.debugDescription)
            ==============================================
            """)
        #endif
    }
}

extension HTTPURLResponse {
    public func debugLog(with data: Data?) {
        #if DEBUG
            guard ProcessInfo.processInfo.showNetworkLogs else { return }
            print("\n==============================================")
            print("url = \(url?.absoluteString ?? "no url")")
            print("statusCode = \(statusCode)")
            if let data = data, let bodyString = String(data: data, encoding: .utf8) {
                print("body = \(bodyString)")
            }
            print("headers = \(allHeaderFields)")
            print("==============================================\n")
        #endif
    }
}
