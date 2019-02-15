//
//  ___FILENAME___
//  ___PROJECTNAME___
//
//  Created on ___DATE___.
//  ___COPYRIGHT___
//

struct ___FILEBASENAMEASIDENTIFIER___: APIEndpoint {
    typealias ResponseType = <#ResponseType#>
    
    var parameters: JSONObject? {
        return <#request parameters#>
    }
    
    var headers: HTTPHeaders {
        return <#request headers#>
    }
    
    var path: String {
        return "<#request path#>"
    }
    
    var method: HTTPMethod {
        return .<#request method#>
    }
    
    var encoding: ParameterEncoding {
        return <#parameter encoding#>
    }
}
