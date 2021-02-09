import Vapor
import Fluent
import Crypto

struct AdministratorsController: RouteCollection {
    func boot(router: Router) throws {
        let administratorsRoutes = router.grouped("api", "administrators")
        administratorsRoutes.post(Administrator.self, at: "register", use: registerAdministratorHandler)
        administratorsRoutes.post(Administrator.self, at: "login", use: login)
        administratorsRoutes.get("logout", use: logout)
        administratorsRoutes.get("emails", use: getAllAdministratorsEmails)
        administratorsRoutes.delete(Administrator.parameter, use: deleteHandler)
    }
    
    // MARK: - Register
    func registerAdministratorHandler(_ request: Request, newAdministrator: Administrator) throws -> Future<HTTPResponseStatus> {
        return Administrator.query(on: request).filter(\.email == newAdministrator.email).first().flatMap { existingAdministrator in
            guard existingAdministrator == nil else {
                throw Abort(.badRequest, reason: "A Administrator with this email already exists" , identifier: nil)
            }
            guard newAdministrator.email.count > 0 && newAdministrator.password.count > 0 else {
                throw Abort(.badRequest, reason: "Empty Administrator data" , identifier: nil)
            }
            let digest = try request.make(BCryptDigest.self)
            let hashedPassword = try digest.hash(newAdministrator.password)
            let persistedAdministrator = Administrator(email: newAdministrator.email, password: hashedPassword)
            return persistedAdministrator.save(on: request).transform(to: .created)
        }
    }
    
    // MARK: - Login
    func login(_ request: Request, administrator: Administrator) throws -> Future<HTTPResponseStatus> {
        return Administrator.query(on: request).filter(\.email == administrator.email).first().flatMap { currentAdministrator in
            guard administrator.email.count > 0 && administrator.password.count > 0 else {
                throw Abort(.badRequest, reason: "Empty administrator data" , identifier: nil)
            }
            guard currentAdministrator != nil else {
                throw Abort(.badRequest, reason: "An administrator with this email doesn't exists" , identifier: nil)
            }
            let digest = try request.make(BCryptDigest.self)
            let isRightPassword = try digest.verify(administrator.password, created: currentAdministrator!.password)
            if !isRightPassword {
                throw Abort(.badRequest, reason: "Wrong password" , identifier: nil)
            }
            return request.future(HTTPResponseStatus(statusCode: 200, reasonPhrase: "Authorization suceeded"))
        }
    }
    
    // MARK: - Logout
    func logout(_ request: Request) throws -> Future<HTTPResponseStatus> {
        return request.future(HTTPResponseStatus(statusCode: 200))
    }
    
    // MARK: - Read
    func getAllAdministratorsEmails(_ request: Request) throws -> Future<[String]> {
        return Administrator.query(on: request).all().flatMap { administrators in
            return request.future(administrators.compactMap({ "\($0.email) - \(String(describing: $0.id))" }))
        }
    }
    
    // MARK: - Delete
    func deleteHandler(_ request: Request) throws -> Future<HTTPStatus> {
        return try request
            .parameters
            .next(Administrator.self)
            .delete(on: request)
            .transform(to: .noContent)
    }
}
