// HTTPRouter.swift
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

struct HTTPRouter : Respondable {

    struct HTTPRoute {

        let path: String
        let methods: Set<HTTPMethod>
        let respond: HTTPRequest throws -> HTTPResponse

    }

    private var routes: [String: HTTPMethodRouter] = [:]
    private var fallback: (path: String) -> HTTPRequest throws -> HTTPResponse

    var paths: [String] {

        return Array(routes.keys)

    }

    var respond: HTTPRequest throws -> HTTPResponse {

        var pathRouter = HTTPPathRouter(fallback: fallback)

        // WARNING: Because of the nature of dictionaries (unordered), if a path matches more than one route. The route that is chosen is undefined. It could be any of them.
        for (path, methodRouter) in routes {

            pathRouter.route(path, respond: methodRouter.respond)

        }

        return pathRouter.respond

    }

    init(basePath: String = "", _ build: (router: HTTPRouterBuilder) -> Void) {

        let routerBuilder = HTTPRouterBuilder(basePath: basePath)
        build(router: routerBuilder)

        fallback = routerBuilder.fallback

        for route in routerBuilder.routes {

            addRoute(route.methods, path: route.path, respond: route.respond)

        }

    }

    final class HTTPRouterBuilder {

        private let basePath: String
        private var routes: [HTTPRoute] = []
        
        init(basePath: String) {
            
            self.basePath = basePath
            
        }
        
        var fallback: (path: String) -> HTTPRequest throws -> HTTPResponse = { path in

            return { request in

                HTTPResponse(status: .NotFound)

            }

        }
        
        func group(basePath: String, _ build: (group: HTTPRouterBuilder) -> Void) {
            
            let groupBuilder = HTTPRouterBuilder(basePath: basePath)
            build(group: groupBuilder)
            
            for route in groupBuilder.routes {
                
                routes.append(HTTPRoute(path: self.basePath + route.path, methods: route.methods, respond: route.respond))
                
            }
            
        }

        func fallback(f: (path: String) -> HTTPRequest throws -> HTTPResponse) {

            self.fallback = f

        }

        func any(path: String, _ respond: HTTPRequest throws -> HTTPResponse) {

            let route = HTTPRoute(
                path: basePath + path,
                methods: [.GET, .POST, .PUT, .PATCH, .DELETE],
                respond: respond
            )

            routes.append(route)

        }

        func any(path: String, respond: Void -> HTTPRequest throws -> HTTPResponse) {

            any(path, respond())
            
        }

        func get(path: String, _ respond: HTTPRequest throws -> HTTPResponse) {

            let route = HTTPRoute(
                path: basePath + path,
                methods: [.GET],
                respond: respond
            )

            routes.append(route)

        }

        func get(path: String, respond: Void -> HTTPRequest throws -> HTTPResponse) {

            get(path, respond())
            
        }

        func post(path: String, _ respond: HTTPRequest throws -> HTTPResponse) {

            let route = HTTPRoute(
                path: basePath + path,
                methods: [.POST],
                respond: respond
            )

            routes.append(route)

        }

        func post(path: String, respond: Void -> HTTPRequest throws -> HTTPResponse) {

            post(path, respond())
            
        }

        func put(path: String, _ respond: HTTPRequest throws -> HTTPResponse) {

            let route = HTTPRoute(
                path: basePath + path,
                methods: [.PUT],
                respond: respond
            )

            routes.append(route)

        }

        func put(path: String, respond: Void -> HTTPRequest throws -> HTTPResponse) {

            put(path, respond())
            
        }

        func patch(path: String, _ respond: HTTPRequest throws -> HTTPResponse) {

            let route = HTTPRoute(
                path: basePath + path,
                methods: [.PATCH],
                respond: respond
            )

            routes.append(route)

        }

        func patch(path: String, respond: Void -> HTTPRequest throws -> HTTPResponse) {

            patch(path, respond())
            
        }

        func delete(path: String, _ respond: HTTPRequest throws -> HTTPResponse) {

            let route = HTTPRoute(
                path: basePath + path,
                methods: [.DELETE],
                respond: respond
            )

            routes.append(route)

        }

        func delete(path: String, respond: Void -> HTTPRequest throws -> HTTPResponse) {

            delete(path, respond())
            
        }

        // TODO: Use regex to validate the path string.
        func resources<T: ResourcefulResponder>(path: String, _ responder: T) {

            let indexRoute = HTTPRoute(
                path: basePath + path,
                methods: [.GET],
                respond: responder.index
            )

            let createRoute = HTTPRoute(
                path: basePath + path,
                methods: [.POST],
                respond: responder.create
            )

            let showRoute = HTTPRoute(
                path: basePath + path + "/:id",
                methods: [.GET],
                respond: responder.show
            )

            let updateRoute = HTTPRoute(
                path: basePath + path + "/:id",
                methods: [.PUT, .PATCH],
                respond: responder.update
            )

            let destroyRoute = HTTPRoute(
                path: basePath + path + "/:id",
                methods: [.DELETE],
                respond: responder.destroy
            )

            routes += [indexRoute, createRoute, showRoute, updateRoute, destroyRoute]

        }

        // TODO: Use regex to validate the path string.
        func resources<T: ResourcefulResponder>(path: String, responder: Void -> T) {

            resources(path, responder())
            
        }

        // TODO: Use regex to validate the path string.
        func resource<T: ResourcefulResponder>(path: String, _ responder: T) {

            let showRoute = HTTPRoute(
                path: basePath + path,
                methods: [.GET],
                respond: responder.show
            )
            
            let createRoute = HTTPRoute(
                path: basePath + path,
                methods: [.POST],
                respond: responder.create
            )
            
            let updateRoute = HTTPRoute(
                path: basePath + path,
                methods: [.PUT, .PATCH],
                respond: responder.update
            )
            
            let destroyRoute = HTTPRoute(
                path: basePath + path,
                methods: [.DELETE],
                respond: responder.destroy
            )
            
            routes += [createRoute, showRoute, updateRoute, destroyRoute]
            
        }

        // TODO: Use regex to validate the path string.
        func resource<T: ResourcefulResponder>(path: String, responder: Void -> T) {

            resource(path, responder())

        }

    }

    private mutating func addRoute(methods: Set<HTTPMethod>, path: String, respond: HTTPRequest throws -> HTTPResponse) {

        func methodNotAllowed(method: HTTPMethod)(request: HTTPRequest) throws -> HTTPResponse {

            return HTTPResponse(status: .MethodNotAllowed)
            
        }

        if routes[path] == nil {

            routes[path] = HTTPMethodRouter(fallback: methodNotAllowed)

        }

        for method in methods {

            routes[path]?.route(method, respond: respond)

        }

    }

}