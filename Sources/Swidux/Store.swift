//  Created by Cyril Clément
//  Copyright © 2018 clmntcrl. All rights reserved.

import Foundation

private let swiduxQueue = DispatchQueue(
    label: "io.clmntcrl.swidux",
    qos: .utility,
    attributes: .concurrent
)

public final class Store<AppState> {

    private var subscriptions = [PartialKeyPath<AppState>: StoreSubscription]()

    private var state: AppState {
        didSet {
            subscriptions.forEach { kp, subscription in
                DispatchQueue.main.async {
                    subscription.next(.init(
                        prevState: oldValue[keyPath: kp],
                        nexState: self.getState()[keyPath: kp]
                    ))
                }
            }
        }
    }
    private let reducer: Reducer<AppState>
    private let middlewares: [Middleware<AppState>]

    // MARK: -

    public private(set) lazy var dispatch: (Action) -> Void = { action in
        swiduxQueue.sync(flags: .barrier) { self.reducer.reduce(&self.state, action) }
    }

    public init(
        initialState: AppState,
        reducer: Reducer<AppState> = .init { _,_  in },
        middlewares: [Middleware<AppState>] = []
    ) {

        self.state = initialState
        self.reducer = reducer
        self.middlewares = middlewares

        // Wrap default dispatch implementation with middlewares
        self.dispatch = middlewares.reduce(self.dispatch) { dispatch, middleware in
            middleware.run(self)(dispatch)
        }
    }

    public func getState() -> AppState {
        return swiduxQueue.sync { self.state }
    }

    public func subscribe<Value: Equatable>(
        _ keyPath: KeyPath<AppState, Value>,
        onNext: @escaping (Value) -> Void
    ) -> StoreSubscriptionToken {

        // Provide current value to the subscriber for the given KeyPath
        onNext(getState()[keyPath: keyPath])
        // Reuse subscription if exists
        let subscription = subscriptions[
            keyPath,
            default: .init(
                keyPath: keyPath,
                onSubscriberCounterDropsToZero: { self.subscriptions.removeValue(forKey: keyPath) }
            )
        ]
        if case .none = subscriptions[keyPath] {
            subscriptions[keyPath] = subscription
        }
        // Subscribe
        return subscription.subscribe { onNext($0 as! Value) }
    }
}
