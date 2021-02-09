import Foundation
import Vapor
import FluentPostgreSQL
import Fluent

final class Administrator: Codable {
  var id: UUID?
  private(set) var email: String
  private(set) var password: String
  
  init(email: String, password: String) {
    self.email = email
    self.password = password
  }
}

// MARK: - Fluent Protocols
extension Administrator: Content {}
extension Administrator: PostgreSQLUUIDModel {}
extension Administrator: Migration {}
extension Administrator: Parameter {}
