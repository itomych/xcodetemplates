// ___FILEHEADER___

import Foundation

extension ProcessInfo {
    private struct Constants {
        static let showNetworkLogs = "SHOW_NETWORK_LOGS"
    }
    
    #if DEBUG
        var showNetworkLogs: Bool {
            arguments.contains(Constants.showNetworkLogs)
        }
    #endif
}
