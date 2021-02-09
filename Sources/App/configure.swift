import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // Register middleware
    var middlewares = MiddlewareConfig()
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    middlewares.use(corsMiddleware)
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)
    
    // Configure a database
    var databases = DatabasesConfig()
    let databaseName: String
    let databasePort: Int
    if env == .testing {
      databaseName = "vapor-test"
      databasePort = 5433
    } else {
      databaseName = "vapor"
      databasePort = 5432
    }
    let databaseConfig = PostgreSQLDatabaseConfig(
      hostname: "localhost",
      port: databasePort,
      username: "vapor",
      database: databaseName,
      password: "password")
    let database = PostgreSQLDatabase(config: databaseConfig)
    databases.add(database: database, as: .psql)
    services.register(databases)
    
    var migrations = MigrationConfig()
    migrations.add(model: Administrator.self, database: DatabaseIdentifier<Administrator.Database>.psql)
    migrations.add(model: DoorType.self, database: DatabaseIdentifier<DoorType.Database>.psql)
    migrations.add(model: Sensor.self, database: DatabaseIdentifier<Sensor.Database>.psql)
    migrations.add(model: Shop.self, database: DatabaseIdentifier<Shop.Database>.psql)
    services.register(migrations)
}
