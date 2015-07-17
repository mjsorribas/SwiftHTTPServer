// JSONResponder.swift
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

extension Responder {

    static let json = JSONResponder()

}

struct JSONResponder: HTTPMethodResponder {

    func get(request: HTTPRequest) -> HTTPResponse {
        
        let json: JSON = [

            "null": nil,
            "string": "Foo Bar",
            "boolean": true,
            "array": [
                "1",
                2,
                nil,
                true,
                ["1", 2, nil, false],
                ["a": "b"]
            ],
            "object": [
                "a": "1",
                "b": 2,
                "c": nil,
                "d": false,
                "e": ["1", 2, nil, false],
                "f": ["a": "b"]
            ],
            "number": 1969

        ]

        return HTTPResponse(status: .OK, body: JSONBody(json: json))

    }

    func post(request: HTTPRequest) -> HTTPResponse {

        guard var body = request.body as? JSONBody
        else { return HTTPResponse(status: .BadRequest, body: TextBody(text: "Expected JSON body")) }

        body.json["number"] = 321
        body.json["array"][0] = 3
        body.json["array"][2] = 1

        return HTTPResponse(status: .OK, body: body)

    }

}