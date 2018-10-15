import Foundation
import Swidux

struct AppState {
    var count = 0
}

enum CounterAction: Action {
    case increment
    case decrement
}

let counterReducer = Reducer<Int> { state, action in
    switch action {
    case CounterAction.increment: state += 1
    case CounterAction.decrement: state -= 1
    default: break
    }
}

let store = Store<AppState>(
    initialState: AppState(),
    reducer: counterReducer.lift(\.count)
)

let token = store.subscribe(\.count) { print($0) }

store.dispatch(CounterAction.increment)
store.dispatch(CounterAction.increment)
store.dispatch(CounterAction.decrement)
