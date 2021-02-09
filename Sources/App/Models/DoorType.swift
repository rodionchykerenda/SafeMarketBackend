import Foundation
import Vapor
import FluentPostgreSQL
import Fluent

final class DoorType: Codable {
    var id: UUID?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension DoorType: Content {}
extension DoorType: PostgreSQLUUIDModel {}
extension DoorType: Migration {}
extension DoorType: Parameter {}

