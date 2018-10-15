//  Created by Cyril Clément
//  Copyright © 2018 clmntcrl. All rights reserved.

import Foundation

public final class StoreSubscriptionToken {

    private let token: NSObjectProtocol
    private let center: NotificationCenter

    var onDeinit: () -> Void = {}

    init(token: NSObjectProtocol, center: NotificationCenter = .default) {
        self.token = token
        self.center = center
    }

    deinit {
        onDeinit()
        center.removeObserver(token)
    }
}
