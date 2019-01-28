//  Created by Cyril Clément
//  Copyright © 2018 clmntcrl. All rights reserved.

import Foundation

struct StateUpdate<A> {

    let prevState: A
    let nexState: A
}

extension StateUpdate {

    func map<B>(_ transform: (A) -> B) -> StateUpdate<B> {
        return StateUpdate<B>(
            prevState: transform(prevState),
            nexState: transform(nexState)
        )
    }
}
