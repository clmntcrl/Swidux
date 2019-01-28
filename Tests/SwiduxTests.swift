//  Created by Cyril Clément
//  Copyright © 2019 clmntcrl. All rights reserved.

import XCTest
@testable import Swidux

class SwiduxTests: XCTestCase {

    struct CounterState {
        var count = 0
    }
    enum CounterAction: Action {
        case increment, decrement
    }
    let counterReducer = Reducer<CounterState> { state, action in
        switch action as! CounterAction {
        case .increment: state.count += 1
        case .decrement: state.count -= 1
        }
    }
    var store: Store<CounterState>!

    // MARK: - Set up

    override func setUp() {
        super.setUp()

        store = Store(initialState: CounterState(), reducer: counterReducer)
    }

    // MARK: - Tests

    func testThatSwiduxStoreIsThreadSafe() {
        // Perform both read and write access from different queues
        let increment = XCTestExpectation()
        DispatchQueue.global(qos: .userInitiated).async {
            for _ in 0..<1_000 {
                self.store.dispatch(CounterAction.increment)
            }
            increment.fulfill()
        }
        let decrement = XCTestExpectation()
        DispatchQueue.global(qos: .userInitiated).async {
            for _ in 0..<1_000 {
                self.store.dispatch(CounterAction.decrement)
            }
            decrement.fulfill()
        }
        var subscriptionTokens = [Any]()
        for _ in 0..<500 {
            subscriptionTokens.append(store.subscribe(\.count) { _ in })
        }
        // Wait for increments and decrements completion
        XCTWaiter().wait(for: [ increment, decrement ], timeout: 5)
        // Assert
        XCTAssertEqual(store.getState().count, 0)
    }
}
