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

### Middleware

Middlewares allow to extend swidux architecture. They they are able to act before and after reducers and could be used to handle a wide variety of problems like logging, handling asynchronous actions, ...

Internaly, each middle get a dispatch function as parameter (plus the store to be able to get state) and return a wrapped one which will be used by the next middleware and finally by the swidux store.
<br />Because of this you should take care of the order of the middlewares. A middleware could, for example, decide to don't propagate certain actions to the dispacth function (perhaps because these actions are only useful for its operation). If your middlewares contain a logger, these actions will be logged or not according to the order of the middlewares.


## License

Swidux is released under the MIT license. See [LICENSE](LICENSE) for details.
