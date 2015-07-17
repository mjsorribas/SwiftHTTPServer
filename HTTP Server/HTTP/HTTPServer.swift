// HTTPServer.swift
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

final class HTTPServer: RoutableServer<HTTPRequestParser, HTTPResponseSerializer> {

    init(requestMiddlewares: HTTPRequestMiddleware? = nil,
        routes: [ServerRoute<HTTPRequest, HTTPResponse>] = [],
        responseMiddlewares: HTTPResponseMiddleware? = nil) {

            let responseMiddlewares = { (request: HTTPRequest) in

                return responseMiddlewares >>>
                       Middleware.keepAlive(request.keepAlive) >>>
                       Middleware.headers(["server": "HTTP Server"])

            }

            super.init(
                requestMiddlewares: requestMiddlewares,
                routes: routes,
                responseMiddlewares: responseMiddlewares,
                defaultResponder: Responder.assetAtPath,
                failureResponder: HTTPServer.failureResponder,
                keepConnectionForRequest: HTTPServer.keepConnectionForRequest
            )

    }

}

// MARK: - Private

extension HTTPServer {

    private static func defaultFailureHandler(error: ErrorType) {

        Log.error("Server error: \(error)")

    }

    private static func failureResponder(error: ErrorType) -> HTTPResponse {

        return HTTPResponse(status: .InternalServerError, body: TextBody(text: "\(error)"))
        
    }

    private static func keepConnectionForRequest(request: HTTPRequest) -> Bool {
        
        return request.keepAlive
        
    }
    
}