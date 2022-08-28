import ComposableArchitecture

extension Reducer {
    static func recurse(_ reducer: @escaping (Reducer) -> Reducer) -> Reducer {
        var `self`: Reducer!
        self = Reducer { state, action, environment in
            reducer(self).run(&state, action, environment)
        }
        return self
    }
}
