//  Created by Cyril Clément
//  Copyright © 2018 clmntcrl. All rights reserved.

import Foundation

// Middlewares allow to extend swidux architecture. They they are able to act before and after reducers and could be used to
// handle a wide variety of problems like logging, handling asynchronous actions, ...
//
//                           +-----------------+
//        +------------------|  UI Components  |<-------------------+
//        |                  +-----------------+                    |
//        |                                                         |
//     +---------------------------------------------------------------+
//     |                         Middlewares                           |
//     +---------------------------------------------------------------+
//        |                                                         |
//        |    +-----------+    +------------+       +---------+    |
//        +--->|  Actions  |--->|  Reducers  |------>|  Store  |----+
//             +-----------+    +------------+       +---------+
//
// Each middle get a dispatch function as parameter (plus the store to be able to get state) and return a wrapped one which will
// be used by the next middleware and finally by the swidux store.
// Because of this you should take care of the order of the middlewares, indeed one can have consequence for the others. A
// middleware could, for example, decide to don't propagate certain actions to the dispacth function (perhaps because these
// actions are only useful for its operation). If your middlewares contain a logger, these actions will be logged or not
// according to the order of the middlewares.

public struct Middleware<AppState> {

    public let run: (Store<AppState>)
        -> (@escaping (Action) -> Void)
        -> (Action) -> Void

    public init(
        run: @escaping (Store<AppState>)
            -> (@escaping (Action) -> Void)
            -> (Action) -> Void
    ) {

        self.run = run
    }
}
