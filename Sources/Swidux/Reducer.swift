//  Created by Cyril Clément
//  Copyright © 2018 clmntcrl. All rights reserved.

import Foundation

public struct Reducer<State> {

    /// Reduce action for `State`.
    ///
    /// - Important: Because of the use `inout State` the consistency of the state is not guaranteed by the reducer but is the
    /// responsibility of the developer.
    ///
    /// If reducing action mutates lot of `State` properties it could be hard to keep `State` consitent for each mutation. For
    /// those cases the use of `mutating func` is helpful because `didSet` observer will only be call after the execution of this
    /// function.
    ///
    /// - Note: Consistency would be enforced if reduce type was `(State, Action) -> State` but at the cost of `State` copies
    /// that would have impact on performances.
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
