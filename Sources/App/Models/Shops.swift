import Foundation
import Vapor
import FluentPostgreSQL
import Fluent

final class Shop: Codable {
    var id: UUID?
    var name: String
    var address: String
    var latitude: Double
    var longtitude: Double
    var currentAmountOfCustomers: Int
    var doorType: DoorType.ID
    
    init(name: String, cur: Int, address: String, latitude: Double, longtitude: Double, doorType: DoorType.ID) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longtitude = longtitude
        self.doorType = doorType
        self.currentAmountOfCustomers = cur
    }
    
}

extension Shop: Content {}
extension Shop: PostgreSQLUUIDModel {}
extension Shop: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.doorType, to: \DoorType.id)
        }
    }
}
extension Shop: Parameter {}

extension Shop {
    var type: Parent<Shop, DoorType> {
        return parent(\.doorType)
    }
    
    var sensors: Children<Shop, Sensor> {
        return children(\.shopId)
    }
}
