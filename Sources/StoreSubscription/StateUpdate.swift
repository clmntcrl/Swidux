//  Created by Cyril Clément
//  Copyright © 2018 clmntcrl. All rights reserved.

import Foundation

struct StateUpdate<A> {

    let oldState: A
    let state: A
}

extension StateUpdate {

    func map<B>(_ transform: (A) -> B) -> StateUpdate<B> {
        return StateUpdate<B>(
            oldState: transform(oldState),
            state: transform(state)
        )
    }
}
