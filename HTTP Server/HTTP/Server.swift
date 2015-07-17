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

protocol RequestParser {

    typealias Request
    static func receiveRequest(socket socket: Socket) throws -> Request

}

protocol ResponseSerializer {

    typealias Response
    static func sendResponse(socket socket: Socket, response: Response) throws

}

final class Server<Parser: RequestParser, Serializer: ResponseSerializer> {

    typealias Request = Parser.Request
    typealias Response = Serializer.Response
    typealias Responder = (request: Request) -> Response
    typealias ResponderForRequest = (request: Request) -> Responder
    typealias KeepConnectionForRequest = (request: Request) -> Bool

    private let responderForRequest: ResponderForRequest
    private let keepConnectionForRequest: KeepConnectionForRequest?

    private var socket: Socket?

    init(responderForRequest: ResponderForRequest, keepConnectionForRequest: KeepConnectionForRequest? = nil) {

        self.responderForRequest = responderForRequest
        self.keepConnectionForRequest = keepConnectionForRequest
            
    }

}

// MARK: - Start / Stop

extension Server {

    func start(port port: TCPPort = 8080, failureHandler: ErrorType -> Void = Error.defaultFailureHandler)   {

        do {

            socket?.release()
            socket = try Socket(port: port, maxConnections: 1000)
            Dispatch.async { self.waitForClients(failureHandler: failureHandler) }
            Log.info("Server listening at port \(port).")

        } catch {

            failureHandler(error)

        }

    }

    func stop() {

        socket?.release()

    }

}

// MARK: - Private

extension Server {

    private func waitForClients(failureHandler failureHandler: ErrorType -> Void) {

        do {

            while true {

                let clientSocket = try socket!.acceptClient()
                Dispatch.async { self.processClient(clientSocket: clientSocket, failureHandler: failureHandler) }

            }

        } catch {

            socket?.release()
            failureHandler(error)

        }

    }

    private func processClient(clientSocket clientSocket: Socket, failureHandler: ErrorType -> Void) {

        do {

            while true {

                let request = try Parser.receiveRequest(socket: clientSocket)
                let respond = responderForRequest(request: request)
                let response = respond(request: request)
                try Serializer.sendResponse(socket: clientSocket, response: response)

                if keepConnectionForRequest?(request: request) ?? false { break }
                
            }
            
            clientSocket.release()
            
        } catch {
            
            failureHandler(error)
            
        }
        
    }
    
}