// HTTPResponse.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

struct HTTPResponse {

    let status: HTTPStatus
    let version: HTTPVersion
    let headers: [String: String]
    let body: HTTPBody

    init(status: HTTPStatus, version: HTTPVersion = .HTTP_1_1, headers: [String: String] = [:], body: HTTPBody = EmptyBody()) {

        self.status = status
        self.version = version
        self.headers = HTTPResponse.headersByAddingContentInfoFromBody(body, headers: headers)
        self.body = body

    }

    static func headersByAddingContentInfoFromBody(body: HTTPBody, var headers: [String: String]) -> [String: String] {

        if let contentType = body.contentType {
        
            headers["content-type"] = "\(contentType)"
        
        }

        if let data = body.data {

            headers["content-length"] = "\(data.length)"

        } else {

            headers["content-length"] = "0"

        }

        return headers

    }

}

extension HTTPResponse: KeepConnectionResponse {

    func copyKeepingConnection(keepConnection: Bool) -> HTTPResponse {

        if keepConnection {

            return HTTPResponse(
                status: status,
                headers: headers + ["connection": "keep-alive"],
                body: body
            )

        }

        return self

    }

}

extension HTTPResponse: CustomStringConvertible {

    var description: String {

        var string = "\(status.statusCode) \(status.reasonPhrase) \(version)\n"

        for (index, (header, value)) in headers.enumerate() {

            string += "  \(header): \(value)"

            if index != headers.count - 1 {

                string += "\n"
                
            }
            
        }

        if let body = body.data {

            string += "\n\(body)"
            
        }
        
        return string
        
    }
    
}

extension HTTPResponse: CustomColorLogStringConvertible {

    var logDescription: String {

        var string = Log.lightPurple
        
        string += "\(status.statusCode) \(status.reasonPhrase) \(version)\n"

        string += Log.darkPurple

        for (index, (header, value)) in headers.enumerate() {

            string += "  \(header): \(value)"

            if index != headers.count - 1 {

                string += "\n"

            }

        }

        string += Log.purple

        if let body = body.data {

            string += "\n\(body)"
            
        }

        string += Log.reset
        
        return string
        
    }
    
}
