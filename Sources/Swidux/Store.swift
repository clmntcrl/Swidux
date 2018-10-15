//  Created by Cyril Clément
//  Copyright © 2018 clmntcrl. All rights reserved.

import Foundation

private let actionDispatchQueue = DispatchQueue(label: "io.clmntcrl.store-action-dispatch-queue", qos: .utility)
private let middlewareDispatchQueue = DispatchQueue(
    label: "io.clmntcrl.store-middleware-dispatch-queue",
    qos: .utility,
    attributes: .concurrent
)

public final class Store<AppState> {

    private var subscriptions = [PartialKeyPath<AppState>: StoreSubscription]()

    public var state: AppState {
        didSet {
            subscriptions.forEach { kp, subscription in
                let update = StateUpdate(oldState: oldValue[keyPath: kp], state: self.state[keyPath: kp])
                DispatchQueue.main.async { subscription.next(update) }
            }
        }
    }
    public let reducer: Reducer<AppState>
    public let middlewares: [Middleware<AppState>]

    public init(
        initialState: AppState,
        reducer: Reducer<AppState> = .init { _,_  in },
        middlewares: [Middleware<AppState>] = []
    ) {
        self.state = initialState
        self.reducer = reducer
        self.middlewares = middlewares
    }

    public func subscribe<Value: Equatable>(
        _ keyPath: KeyPath<AppState, Value>,
        onNext: @escaping (Value) -> Void
    ) -> StoreSubscriptionToken {
        // Provide current value to the subscriber for the given KeyPath
        onNext(state[keyPath: keyPath])
        // Reuse subscription if exists
        let descriptor = subscriptions[keyPath, default: .init(keyPath: keyPath)]
        if case .none = subscriptions[keyPath] {
            subscriptions[keyPath] = descriptor
        }
        // Subscribe
        let token = descriptor.subscribe { onNext($0 as! Value) }
        token.onDeinit = { self.subscriptions.removeValue(forKey: keyPath) }
        return token
    }

    public func dispatch(_ action: Action) {
        // Mutate state using reducer
        actionDispatchQueue.async { self.reducer.reduce(&self.state, action) }
        // Dispatch action to middlewares
        middlewares.forEach { middleware in
            middlewareDispatchQueue.async { middleware.run(self)(action) }
        }
    }
}
