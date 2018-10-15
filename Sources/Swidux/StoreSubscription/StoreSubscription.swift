//  Created by Cyril Clément
//  Copyright © 2018 clmntcrl. All rights reserved.

import Foundation

struct StoreSubscription {

    private let center: NotificationCenter
    private let name: Notification.Name

    private var lastValue: Any?

    let subscribe: (@escaping (Any) -> Void) -> StoreSubscriptionToken
    let next: (StateUpdate<Any>) -> Void
}

extension StoreSubscription {

    init<Root, Value: Equatable>(keyPath: KeyPath<Root, Value>, center: NotificationCenter = .default) {
        let name = Notification.Name("StoreSubscription_\(keyPath.hashValue)")
        self.name = name
        self.center = center

        self.subscribe = { onNext in
            let token = center.addObserver(forName: name, object: .none, queue: .none) {
                onNext($0.userInfo!["payload"]!)
            }
            return StoreSubscriptionToken(token: token, center: .default)
        }

        self.next = {
            let update = $0.map { $0 as! Value }
            guard update.state != update.oldState else { return }
            center.post(Notification(name: name, object: nil, userInfo: [ "payload": $0.state ]))
        }
    }
}
