//  Created by Cyril Clément
//  Copyright © 2018 clmntcrl. All rights reserved.

import Foundation

private let actionDispatchQueue = DispatchQueue(label: "io.clmntcrl.store-action-dispatch-queue", qos: .utility)

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
        let subscription = subscriptions[
            keyPath,
            default: .init(keyPath: keyPath) { self.subscriptions.removeValue(forKey: keyPath) }
        ]
        if case .none = subscriptions[keyPath] {
            subscriptions[keyPath] = subscription
        }
        // Subscribe
        return subscription.subscribe { onNext($0 as! Value) }
    }

    public func dispatch(_ action: Action) {
        actionDispatchQueue.async {
            self.reducer.reduce(&self.state, action)
            self.middlewares.forEach { middleware in middleware.run(self, action) }
        }
    }
}
