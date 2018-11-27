//  Created by Cyril Clément
//  Copyright © 2018 clmntcrl. All rights reserved.

import Foundation

public struct Reducer<State> {

    let reduce: (inout State, Action) -> Void

    public init(reduce: @escaping (inout State, Action) -> Void) {
        self.reduce = reduce
    }
}

public extension Reducer {

    public static func combine(reducers: [Reducer<State>]) -> Reducer<State> {
        return Reducer { state, action in
            reducers.forEach {
                reducer in reducer.reduce(&state, action)
            }
        }
    }

    public func lift<T>(_ kp: WritableKeyPath<T, State>) -> Reducer<T> {
        return .init { state, action in
            self.reduce(&state[keyPath: kp], action)
        }
    }
}
