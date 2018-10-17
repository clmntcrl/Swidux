//  Created by Cyril Clément
//  Copyright © 2018 clmntcrl. All rights reserved.

import Foundation

private final class SubscriberCounter {

    var value = 0 {
        didSet {
            if value <= 0 {
                onCounterDropsToZero()
            }
        }
    }
    private var onCounterDropsToZero: () -> Void

    init(onCounterDropsToZero: @escaping () -> Void) {
        self.onCounterDropsToZero = onCounterDropsToZero
    }
}

struct StoreSubscription {

    private let center: NotificationCenter
    private let name: Notification.Name

    private let subscriberCount: SubscriberCounter

    let subscribe: (@escaping (Any) -> Void) -> StoreSubscriptionToken
    let next: (StateUpdate<Any>) -> Void
}

extension StoreSubscription {

    init<Root, Value: Equatable>(
        keyPath: KeyPath<Root, Value>,
        center: NotificationCenter = .default,
        onSubscriberCounterDropsToZero: @escaping () -> Void = {}
    ) {
        let name = Notification.Name("StoreSubscription_\(keyPath.hashValue)")
        self.name = name
        self.center = center

        let subscribersCount = SubscriberCounter(onCounterDropsToZero: onSubscriberCounterDropsToZero)
        self.subscriberCount = subscribersCount

        self.subscribe = { onNext in
            subscribersCount.value += 1
            let token = center.addObserver(forName: name, object: .none, queue: .none) {
                onNext($0.userInfo!["payload"]!)
            }
            return StoreSubscriptionToken(token: token, center: .default, onDeinit: { subscribersCount.value -= 1 })
        }

        self.next = {
            let update = $0.map { $0 as! Value }
            guard update.state != update.oldState else { return }
            center.post(Notification(name: name, object: nil, userInfo: [ "payload": $0.state ]))
        }
    }
}
