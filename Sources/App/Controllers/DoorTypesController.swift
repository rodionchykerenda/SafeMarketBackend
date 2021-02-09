import Vapor
import Fluent

struct DoorTypesController: RouteCollection {
    func boot(router: Router) throws {
        let doorTypesRoutes = router.grouped("api", "door_types")
        doorTypesRoutes.get(use: getAllHandler)
        doorTypesRoutes.get(DoorType.parameter, use: getDoorTypeById)
        doorTypesRoutes.post(use: createHandler)
        doorTypesRoutes.put(DoorType.parameter, use: updateHandler)
        doorTypesRoutes.delete(use: deleteHanlder)
    }
    
    // MARK: - Create
    func createHandler(_ request: Request) throws -> Future<DoorType> {
      return try request
        .content
        .decode(DoorType.self)
        .flatMap(to: DoorType.self, { doorType in
          doorType.save(on: request)
        })
    }
    
    // MARK: - Read
    func getAllHandler(_ request: Request) throws -> Future<[DoorType]> {
      return DoorType.query(on: request).all()
    }
    
    func getDoorTypeById(_ request: Request) throws -> Future<DoorType> {
      return try request.parameters.next(DoorType.self)
    }
    
    // MARK: - Update
    func updateHandler(_ request: Request) throws -> Future<DoorType> {
      return try flatMap(
        to: DoorType.self,
        request.parameters.next(DoorType.self),
        request.content.decode(DoorType.self),
        { type, updatedType in
          type.name = updatedType.name
          return type.save(on: request)
      })
    }
    
    // MARK: - Delete
    func deleteHanlder(_ request: Request) throws -> Future<HTTPStatus> {
      return try request
        .parameters
        .next(DoorType.self)
        .delete(on: request)
        .transform(to: .noContent)
    }
}
