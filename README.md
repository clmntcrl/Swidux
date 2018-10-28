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

## Discussion

### Reducers

`Reducers` use `inout state` to improve performances. This has a major drawback, the consistency of the state is no longer guaranteed by the reducer but is the responsibility of the developer. Let's take the following example:

```swift
struct AppState {
    var tasks: [Id<Task>: Task] = [:]
    var todaysTasksIds: [Id<Task>] = []
}

let reducer = Reducer<AppState> { state, action in
    switch action {
    case TaskAction.create(let title):
        let task = Task(title: title)
        state.todaysTasksIds += [task.id] // ← ‼️ Inconsistent state
        state.tasks[task.id] = task
    default: break
    }
}
```

Each mutation of the application state trigger the notification of susbscribers (if the value they have subscribed change). So if someone subscribe to `\.todaysTasksIds` changes to generate a list of a today's task list like bellow:

```swift
let token = store.subscribe(\.todaysTasksIds) { todaysTasksIds in 
    let todaysTasks = todaysTasksIds.map { store.state.tasks[$0] }
    // ...
}
```

The inconsistency of the state _could_ crash the application because `state.tasks` has not yet been updated (this is not certain because subscribers notifications rely on an async dispatch that makes code execution order unpredictable).

In the above example, inverting `state.todaysTasksIds += [task.id]` and `state.tasks[task.id] = task` lines fix state inconsistency. Sometimes it could be harder to keep things consitent if reducing action mutates lot of state properties. For those cases the use of `mutating func` is helpful because `didSet` observer will only be call after the execution this function.

## Installation

### [Carthage](https://github.com/Carthage/Carthage)

Add the following dependency to your Cartfile:

```
github "clmntcrl/swidux" ~> 0.1.0
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
        .package(url: "https://github.com/clmntcrl/swidux.git", from: "0.1.0"),
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
