import Vapor
import Fluent

struct ShopsController: RouteCollection {
    func boot(router: Router) throws {
        let shopsRoutes = router.grouped("api", "shops")
        shopsRoutes.get(use: getAllHandler)
        shopsRoutes.get(Shop.parameter, use: getShopById)
        shopsRoutes.post(use: createHandler)
        shopsRoutes.get(Shop.parameter, "door_type", use: getDoorType)
        shopsRoutes.get("nearest", use: getNearestShop)
        shopsRoutes.delete(Shop.parameter, use: deleteHanlder)
        shopsRoutes.put(Shop.parameter, use: updateHandler)
        shopsRoutes.put(Shop.parameter, "amount_of_customers", use: updateHandler)
    }
    
    func getAllHandler(_ request: Request) throws -> Future<[Shop]> {
        return Shop.query(on: request).all()
    }
    
    func getShopById(_ request: Request) throws -> Future<Shop> {
        return try request.parameters.next(Shop.self)
    }
    
    func getAllSensorsForStationHandler(_ request: Request) throws -> Future<[Sensor]> {
        return try request.parameters.next(Shop.self)
            .flatMap(to: [Sensor].self, { shop in
                return try shop.sensors.query(on: request).all()
            })
    }
    
    func getDoorType(_ request: Request) throws -> Future<DoorType> {
        return try request.parameters.next(Shop.self)
            .flatMap(to: DoorType.self, { shop in
                return shop.type.get(on: request)
            })
    }
    
    func getNearestShop(_ request: Request) throws -> Future<[Shop]> {
        guard
            let currentLat = request.query[Double.self, at: "lat"],
            let currentLong = request.query[Double.self, at: "long"],
            let range = request.query[Int.self, at: "range"]
            else {
                throw Abort(.badRequest)
        }
        return Shop.query(on: request).all().map { shop in
            return shop.filter {
                DistanceCalculator.countDistance(startLat: currentLat,
                                                 startLong: currentLong,
                                                 endLat: $0.latitude,
                                                 endLong: $0.longtitude) <= Double(range)
            }
        }
    }
    
    // MARK: - Create
    func createHandler(_ request: Request) throws -> Future<Shop> {
      return try request
        .content
        .decode(Shop.self)
        .flatMap(to: Shop.self, { shop in
          shop.save(on: request)
        })
    }
    
    // MARK: - Update
    func updateHandler(_ request: Request) throws -> Future<Shop> {
      return try flatMap(
        to: Shop.self,
        request.parameters.next(Shop.self),
        request.content.decode(Shop.self),
        { shop, updatedShop in
          shop.name = updatedShop.name
          shop.address = updatedShop.address
          shop.latitude = updatedShop.latitude
          shop.longtitude = updatedShop.longtitude
          return shop.save(on: request)
      })
    }
    
    func updateAmountOfCustomers(_ request: Request) throws -> Future<Shop> {
      return try flatMap(
        to: Shop.self,
        request.parameters.next(Shop.self),
        request.content.decode(Shop.self),
        { shop, updatedShop in
          shop.currentAmountOfCustomers += 1
          return shop.save(on: request)
      })
    }
    
    // MARK: - Delete
    func deleteHanlder(_ request: Request) throws -> Future<HTTPStatus> {
      return try request
        .parameters
        .next(Shop.self)
        .delete(on: request)
        .transform(to: .noContent)
    }
    
}
