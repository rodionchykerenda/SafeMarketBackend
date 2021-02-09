import Foundation
import Vapor
import FluentPostgreSQL
import Fluent

final class Sensor: Codable {
    var id: UUID?
    var isEntering: Bool
    var isItersected: Bool
    var shopId: Shop.ID
    
    init(isEntering: Bool, isItersected: Bool, shop: Shop.ID) {
        self.isEntering = isEntering
        self.isItersected = isItersected
        self.shopId = shop
    }
}

extension Sensor: Content {}
extension Sensor: PostgreSQLUUIDModel {}
extension Sensor: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.shopId, to: \Shop.id)
        }
    }
}
extension Sensor: Parameter {}

extension Sensor {
    var shop: Parent<Sensor, Shop> {
        return parent(\.shopId)
    }
}
