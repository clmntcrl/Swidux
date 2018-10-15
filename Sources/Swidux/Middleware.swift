//  Created by Cyril Clément
//  Copyright © 2018 clmntcrl. All rights reserved.

import Foundation

public struct Middleware<AppState> {

    let run: (Store<AppState>, Action) -> Void

    public init(run: @escaping (Store<AppState>, Action) -> Void) {
        self.run = run
    }
}
