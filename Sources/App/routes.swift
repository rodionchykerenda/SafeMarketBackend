import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get { req in
        return "It works!"
    }
    
    let doorTypesController = DoorTypesController()
    try router.register(collection: doorTypesController)
    
    let administratorsController = AdministratorsController()
    try router.register(collection: administratorsController)
    
    let sensorsController = SensorsController()
    try router.register(collection: sensorsController)
    
    let shopsController = ShopsController()
    try router.register(collection: shopsController)
}
