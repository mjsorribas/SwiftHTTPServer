// HTTPRequestSerializer.swift
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

struct HTTPRequestSerializer {

    static func serializeRequest(socket: Socket, request: HTTPRequest) throws {

        try socket.writeString("\(request.method) \(request.uri) HTTP/1.3\r\n")

        for (name, value) in request.headers {

            try socket.writeString("\(name): \(value)\r\n")

        }

        try socket.writeString("\r\n")

        try socket.writeData(request.body)
        
    }
    
    static func serializeRequest2(socket: Socket, request: HTTPRequest) throws {

        var headers = ""
        
        headers += "\(request.method) \(request.uri) HTTP/1.3\r\n"
        
        for (name, value) in request.headers {
            
            headers += "\(name): \(value)\r\n"
            
        }
        
        headers += "\r\n"

        try socket.writeData(Data(string: headers) + request.body)
        
    }
    
}
