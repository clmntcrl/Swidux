//  Created by Cyril Clément
//  Copyright © 2018 clmntcrl. All rights reserved.

import Foundation

public final class StoreSubscriptionToken {

    private let token: NSObjectProtocol
    private let center: NotificationCenter

    private let onDeinit: () -> Void

    init(token: NSObjectProtocol, center: NotificationCenter = .default, onDeinit: @escaping () -> Void = {}) {
        self.token = token
        self.center = center
        self.onDeinit = onDeinit
    }

    deinit {
        onDeinit()
        center.removeObserver(token)
    }
}
