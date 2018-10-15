# Swidux

Swift unidirectional data flow inspired by redux.

## Stability

This library should be considered alpha, and not stable. Breaking changes will happen often.

## Usage

Define your application state,

```swift
struct AppState {
    var count = 0
}
```

the list of actions that could be done,

```swift
enum CounterAction: Action {
    case increment
    case decrement
}
```

and how they impact the application state.

```swift
let counterReducer = Reducer<Int> { state, action in
    switch action {
    case CounterAction.increment: state += 1
    case CounterAction.decrement: state -= 1
    default: break
    }
}
```

Then initialize the application store,

```swift
let store = Store<AppState>(
    initialState: AppState(),
    reducer: counterReducer.lift(\.count)
)
```

subscribe any application state key path to be notified of state changes (make sure to keep reference to the token because its deallocation stop subscription).

```swift
let token = store.subscribe(\.count) { print($0) }
```

Now `dispatch` actions to mutate application state and use your subscription to state changes to update your UI, ...

```swift
store.dispatch(CounterAction.increment)
store.dispatch(CounterAction.decrement)
```

## Installation

```swift
import PackageDescription

let package = Package(
    dependencies: [
        .package(url: "https://github.com/clmntcrl/swidux.git", .branch("master")),
    ]
)
```

## License

Swidux is released under the MIT license. See [LICENSE](LICENSE) for details.
