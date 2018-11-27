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

## Discussions

### AppState

Application state must be a value type because Swidux store rely on `didSet` observer to notify subscribers of state changes.

### Reducers

Reducers use `(inout State, Action) -> Void` signature (instead of `(State, Action) -> State`) to improve performances and avoid lot of `State` copies.

## Installation

### [Carthage](https://github.com/Carthage/Carthage)

Add the following dependency to your Cartfile:

```
github "clmntcrl/swidux" ~> 0.1.1
```

```
$ carthage update
```


### [SwiftPM](https://github.com/apple/swift-package-manager)

Add package as dependency:

```swift
import PackageDescription

let package = Package(
    name: "AwesomeProjectName",
    dependencies: [
        .package(url: "https://github.com/clmntcrl/swidux.git", from: "0.1.1"),
    ],
    targets: [
        .target(name: "AwesomeProjectName", dependencies: ["Swidux"])
    ]
)
```

```
$ swift build
```


## License

Swidux is released under the MIT license. See [LICENSE](LICENSE) for details.
