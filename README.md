# Compose 

[![Maintainability](https://api.codeclimate.com/v1/badges/dde2d99fb7fd3b902659/maintainability)](https://codeclimate.com/github/din/compose/maintainability)

Compose is an opinionated architecture framework intended to create applications for iOS and macOS. Compose is built on top of Combine and SwiftUI.

- 🌴 Component tree
- 🚦 Event-driven communication between components
- 🚏 Flexible routing
- 🧨 Reactive store
- 🏛 Predicable file structure
- 👨🏽‍💻 UI elements to implement navigation from scratch

_Compose is still a work in progress. The framework is still alpha—feature set may change, variable and method names may change too._

## <a name='TableofContents'></a>Table of Contents

<!-- vscode-markdown-toc -->
* [Table of Contents](#TableofContents)
* [Supported Platforms](#SupportedPlatforms)
* [Installation](#Installation)
* [Getting Started](#GettingStarted)
* [Emitters](#Emitters)
	* [Emitters Operators](#EmittersOperators)
	* [Emitters Chaining](#EmittersChaining)
		* [Debounce](#Debounce)
		* [DropFirst](#DropFirst)
		* [DropUntil](#DropUntil)
		* [Filter, Only, Not](#FilterOnlyNot)
		* [FlatMap](#FlatMap)
		* [IgnoreOutput](#IgnoreOutput)
		* [Map](#Map)
		* [MapErrorToNil](#MapErrorToNil)
		* [Merge](#Merge)
		* [NonNull](#NonNull)
		* [Once](#Once)
		* [Publisher](#Publisher)
		* [Tap](#Tap)
		* [Undup](#Undup)
		* [WithCurrent](#WithCurrent)
* [Components](#Components)
	* [`Component`](#Component)
		* [Preinstalled Lifecycle Emitters](#PreinstalledLifecycleEmitters)
		* [Attaching Emitters With `@AttachedEmitter`](#AttachingEmittersWithAttachedEmitter)
	* [`RouterComponent`](#RouterComponent)
		* [`Router`](#Router)
		* [`@EnclosingRouter`](#EnclosingRouter)
		* [`RouterView`](#RouterView)
	* [`StartupComponent`](#StartupComponent)
	* [`DynamicComponent`](#DynamicComponent)
		* [Lifecycle Emitters](#LifecycleEmitters)
	* [`InstanceComponent`](#InstanceComponent)
		* [Lifecycle Emitters](#LifecycleEmitters-1)
		* [Supplementary methods](#Supplementarymethods)
* [Services](#Services)
* [`@Store` And State Management](#StoreAndStateManagement)
	* [Validating State](#ValidatingState)
		* [`Validation`](#Validation)
		* [`Field`](#Field)
		* [`ArrayField`](#ArrayField)
		* [`Rule`](#Rule)
	* [Tracking State Statuses](#TrackingStateStatuses)
		* [`StatusSet` Operators](#StatusSetOperators)
	* [Persisting State](#PersistingState)
		* [Choosing Persisted Values](#ChoosingPersistedValues)
	* [Identified References via  `@Ref` and `@RefCollection`](#IdentifiedReferencesviaRefandRefCollection)
	* [Centralised Versus Decentralised State Management](#CentralisedVersusDecentralisedStateManagement)

<!-- vscode-markdown-toc-config
	numbering=false
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

## <a name='SupportedPlatforms'></a>Supported Platforms

- iOS 13+
- macOS 10.15+

## <a name='Installation'></a>Installation

Xcode 11+ with Swift 5.3 is required to use Compose. 

To install Compose using Swift Package Manager, open the following menu item in Xcode:

**File > Swift Packages > Add Package Dependency**

In the Choose Package Repository prompt, add the URL:

```
https://github.com/din/compose
```

Include the library as a dependency for your target, then import it when you need it:

```swift
import Compose
```

## <a name='GettingStarted'></a>Getting Started

The following _opinionated_ project structure is the most optimal to use Compose:

```
+ Resources/ <-- Project-wide resources
    - Assets.xcassets
    - Info.plist
    - ...
+ Shared/
    + Styles/ <-- shared application styles
    + Views/ <-- shared views
        - ...
    + Extensions/ <-- various useful extensions
        - ...
+ Services/
    + User/
        - UserService.swift
    + Data/
        - DataService.swift
    + ...
+ Components/
    + App/
        - App.swift <-- entry application point
        - App+View.swift
    + Auth/
        - Auth.swift <-- contains the component definition
        - Auth+Observers.swift <-- contains observers as computed properties
        - Auth+State.swift <-- contains State and Validation definitions 
        - Auth+View.swift <-- contains SwiftUI view
    + Home/
        + Posts/
            - Post.swift
            - Post+State.swift
            - Post+Observers.swift
            - Post+View.swift
        - Home.swift
        - Home+View.swift
    + ...
```

## <a name='Emitters'></a>Emitters 

Emitters emit values which can be observed by subscribed closures. Emitter is a basic building block of Compose which enables building event-driven communication within the component or between different components.

There are two semantic types of emitters: signal emitters and value emitters.

Signal emitters carry only the fact of being called and their value is `Void`:

```swift
// Define an emitter that doesn't carry any value.
let printHello = SignalEmitter()

// Subscribe to an emitter.
printHello += {
    print("Hello, world!")
}

// Later on, emit an event like this:
printHello.send()
```

Value emitters, as the name implies, carry some value with them:

```swift
// Define an emitter that carries a certain value.
let printMessage = ValueEmitter<String>()

// Subscribe to an emitter.
printMessage += { message in
    print(message)
}

// You can subscribe to an emitter many times in different places.
printMessage += { message in 
    print("Another subscriber says:", message)
}

// Later on, emit an event with a value like this:
printMessage.send("A simple message.")
```

Emitters are usually defined in the body of a component, but they also can be defined outside of components. _Emitters cannot be defined as computed properties._

### <a name='EmittersOperators'></a>Emitters Operators

There are several operators defined to add subscribers to any emitters (chained or vanilla).

Any emitter has the following operator defined:
- `+=` is used when the subscription closure must be executed any time an emitter emits a value or a signal.

`ValueEmitter` defines an additional operator: 
- `~+=` when the subscription closure must be executed with the new value and the previous emitted value, which allows computing diffing between two emitted values. 

`OnceEmitter` defines an additional operator:
- `!+=` is used when the subscription closure must be executed **only once** and then never executed again. 

### <a name='EmittersChaining'></a>Emitters Chaining

It's possible to produce a chain of emitters to alter the outcome of a previous emitter in such a way. Chaining emitters is similar to chaining multiple `Publisher` together in Combine. There are several predefined emitters which are scoped under the `Emitters` structure.

#### <a name='Debounce'></a>Debounce

Debounce received value via a signal or a value emitter:

```swift
// Define an emitter.
let emitter = SignalEmitter()

emitter.debounce(interval: .seconds(1)) += {
    // This is executed only once.
    print("Debounced signal received!")
}

// Send signal 100 times.
for i in 0..<100 {
    emitter.send()
}
```

#### <a name='DropFirst'></a>DropFirst

Drop first value or a signal received from an emitter:

```swift
// Define an emitter.
let emitter = SignalEmitter()

emitter.dropFirst() += {
    // This is executed only once.
    print("Second signal received!")
}

// Send signal 2 times.
emitter.send()
emitter.send()
```

#### <a name='DropUntil'></a>DropUntil

Drop values or signals from emitter until another emitter sends any value:

```swift
// Define an emitter.
let emitter = ValueEmitter<Int>()

// Define another emitter
let controlEmitter = SignalEmitter()

emitter.dropUntil(emitter: controlEmitter) += { value in
    // This is executed only with value '300'.
    print("Received value:", value)
}

// Send signal 2 times.
emitter.send(100)
emitter.send(200)

controlEmitter.send()

emitter.send(300)

```

#### <a name='FilterOnlyNot'></a>Filter, Only, Not

Filter an emitted value and only fire the event when the filtered value is sent:

```swift
// Define some value.
enum MyValue : Equatable {
    case one, two, three
}

// Define an emitter.
let emitter = ValueEmitter<MyValue>()

// Filter value using some closure.
emitter.filter({ $0 == .one }) += { value in
    print("One received.")
}

// Only listen to a particular value.
emitter.only(.two) += {
    print("Two received.")
}

// Listen to values except a particular one.
emitter.not(.three) += { value in
    print("Not 'three' received.")
}

// Send different values.
emitter.send(.one)
emitter.send(.two)
emitter.send(.three)
```

#### <a name='FlatMap'></a>FlatMap

Transform an emitter into a new emitter:

```swift

// Define emitters.
let firstEmitter = SignalEmitter()
let secondEmitter = ValueEmitter()

firstEmitter.flatMap {
    secondEmitter
} += {
    // This is executed only when second emitter is fired after the first emitter.
    print("Second emitter fired after the first emitter!")
}

// Send signal 2 times
firstEmitter.send()
secondEmitter.send()
```

It is useful to subscribe to nested emitters which are created dynamically:

```swift

struct OuterValue {

    struct InnerValue {

        let sendData = ValueEmitter<String>()
    
    }

    let didCreate = SignalEmitter()

    var innerValue : InnerValue? = nil

    func create() {
        innerValue = InnerValue()
        didCreate.send()
    }
}

let value = OuterValue()

value.didCreate.flatMap {
    value.innerValue?.sendData ?? ValueEmitter<String>()
} += { value in 
    // Will be executed whenever InnerValue's emitter is invoked.
    print("Received:", value)
}

value.create()
value.innerValue?.send("super-data-payload")

```

#### <a name='IgnoreOutput'></a>IgnoreOutput

Ignore all output from an emitter treating it like a signal emitter:

```swift
// Define an emitter.
let emitter = ValueEmitter<Int>()

emitter.ignoreOutput() += {
    // No values received by this block.
    print("Some values were sent!")
}

// Send some values.
emitter.send(100)
emitter.send(200)
```

#### <a name='Map'></a>Map

Transform emitted value using a closure:

```swift
// Define an emitter.
let emitter = ValueEmitter<Int>()

// Map value using a closure.
emitter.map({ $0 + 10 }) += { value in
    print("Received some value plus '10'.")
}

// Send different values.
emitter.send(5)
emitter.send(10)
emitter.send(35)
```

#### <a name='MapErrorToNil'></a>MapErrorToNil

Transform the `Result<Value, Error>` payload to the `Value?` form. 

> ❗️ You can chain this emitter if the underlying emitter value is `Result<Value, Error>`.

```swift
// Define error type
enum ValueError : Error {
    case customError
}

// Define an emitter with a result type.
let emitter = ValueEmitter<Result<Int, ValueError>>()

// Map value using a closure.
emitter.mapErrorToNil += { value in
    guard let value = value else {
        return
    }

    // '100' and '200' received by this block.
    print("Received:", value)
}

// Send different values.
emitter.send(.success(100))
emitter.send(.failure(.customError))
emitter.send(.success(200))
```

#### <a name='Merge'></a>Merge

Merge emitters together using the `+` operator:

```swift
// Define first emitter.
let first = SignalEmitter()

// Define second emitter.
let second = SignalEmitter()

// Make subscription to each of them and execute the closure when any of them is emitted:
(first + second) += {
    print("First or second emitter event received.")
}
```

> ❗️ You can merge only `ValueEmitters` if they emit the same value type.

#### <a name='NonNull'></a>NonNull

Only get non-null values from the emitter:

```swift
// Define an emitter with some optional value.
let emitter = ValueEmitter<Int?>()

// Filter value using some closure.
// This closure will receive only '5' and '100'.
emitter.nonNull() += { value in
    print("Received value:", value)
}

// Send different values.
emitter.send(5)
emitter.send(nil)
emitter.send(nil)
emitter.send(100)
```

#### <a name='Once'></a>Once

Only execute emitter observer closure once:

```swift
// Define an emitter with some optional value.
let emitter = ValueEmitter<Int>()

// Observe the emitter only once.
// This will only print '5' and stop observing the emitter.
emitter.once() += { value in
    print("Received value 1st way:", value)
}

// There is a handy operator defined to do this more often.
// This will only print '5' and stop observing the emitter.
emitter !+= { value in
    print("Received value 2nd way:", value)
}

// Send different values.
emitter.send(5)
emitter.send(100)
emitter.send(30)
emitter.send(40)
```

#### <a name='Publisher'></a>Publisher

Transform Combine's `AnyPublisher<Value, Error>` publisher into the `Result<Value, Error>` emitter:

```swift
// Define a publisher
let fetchData = Future { fulfill in

    // Fetch data using network
    do {
        let data = try fetchNetworkDataAsynchronously()
        fulfill(.success(data))
    }
    catch let error {
        fulfill(.failure(error))
    }

}.eraseToAnyPublisher()

// Make emitter from the publisher and subscribe to it immediately.
fetchData.emitter() += { result in
    guard let data = try? result.get() else {
        print("Error when fetching data!")
        return
    }

    print("Fetched data: ", data)
}

```

#### <a name='Tap'></a>Tap

Get nested value using its keypath:

```swift
// Define a complex value.
struct Profile {
    let firstName : String
    let lastName : String
}

// Define an emitter.
let emitter = Emitter<Profile>()

// Get only the first name.
emitter.tap(\.firstName) += { firstName in
    print("First name: \(firstName)")
}

// Get only the last name.
emitter.tap(\.lastName) += { lastName in
    print("Last name: \(lastName)")
}

// Send complex value.
emitter.send(.init(firstName: "Jill", lastName: "Valentine"))
```

#### <a name='Undup'></a>Undup

Remove duplicates from emitted values and only receive unique ones.

```swift
// Define an emitter.
let emitter = ValueEmitter<Int>()

// Receive values without duplicates.
emitter.undup() += { value in
    print("Received: \(value)")
}

// Send different values.
emitter.send(5)
emitter.send(5)
emitter.send(5)
emitter.send(10)
```

#### <a name='WithCurrent'></a>WithCurrent

Include last value of the `ValueEmitter<T>` emitter as part of emitted values. If the `ValueEmitter<T>` instance had any values before subscribing to it, using `.withCurrent` on the emitter will send the most recent values right away.

```swift
// Define a value emitter.
let emitter = ValueEmitter<Int>()

// Send value before subscribing to an emitter.
emitter.send(100)

// Subscribe to an emitter to get last sent value immediately.
// This closure will receive '100' and '5'.
emitter.withCurrent() += { value in
    print("Received value with a current one:", value)
}

// Subscribe to an emitter and get only values sent afterwards.
// This closure will receive '5' only.
emitter += { value in
    print("Received value:", value)
}

// Send different values.
emitter.send(5)
```

## <a name='Components'></a>Components

Compose is built with components tree and event-driven communication between them. Compose heavily utilises structures, keypaths, SwiftUI, and Combine to achieve the desired result and abstract complex logic from the user. 

### <a name='Component'></a>`Component`

A basic building block for presenting content. A component is usually a single screen of content.  Components define their presentation using SwiftUI `View`. 

`Component` is a protocol which doesn't conform to any other protocol. 

Each component must be a `struct` and must conform to the `Component` protocol. Usually component body contains emitters, stores, and subcomponents.

```swift
// Auth.swift

struct AuthComponent : Component {

    let logIn = SignalEmitter()

}
```

> ❗️ Compose permits subscriptions to emitters only within a component scope: a component can subscribe to emitters defined by the component itself, or by any child component. It is not possible to subscribe to events in parent components!

`Component` requires us to have a presentation layer. It is usually defined in the appropriate `+View.swift` file:

```swift
// Auth+View.swift

extension AuthComponent : View {

    var body : some View {
        VStack {
            Text("Welcome")
            
            Button(emitter: logIn) {
                Text("Log in")
            }
        }
    }

}
```

`Component` also requires us to define the list of observers or `None` if it doesn't have any. You can add as many observers as you want inside the `observers` computed property:

```swift
// Auth+Observers.swift

extension AuthComponent {

    var observers : Void {
        logIn += {
            print("Log In tapped.")
        }
    }

}
```

You can also split it into several computed properties, possibly defined in separate files, if your `+Observers.swift` file grows big.

```swift
// Auth+Observers.swift

extension AuthComponent {

    var observers : Void {
        loginObserver
        actionObserver
    }
    
    private var logInObserver : Void {
        logIn += {
            print("Log In tapped.")
        }
    }
    
    private var actionObserver : Void {
        doAction += {
            print("Action occured.")
        }
    }

}
```

> ❗️ You should never read or refer to `observers` property manually anywhere in your code: Compose automatically sets this up for you during the app lifecycle.

This component can now be presented in the tree of components using `Router` or via direct presentation within a view.

#### <a name='PreinstalledLifecycleEmitters'></a>Preinstalled Lifecycle Emitters

Each component instance comes with two lifecycle emitters: 

- `didAppear` is invoked as soon as component's view appears.
- `didDisappear` is invoked as soon as component's view disappears.

These emitters can be observed in the `+Observers.swift` file:

```swift
// Auth+Observers.swift

extension AuthComponent {

    var observers : Void {
        didAppear += {
            print("Component appeared.")
        }
        
        didDisappear += {
            print("Component disappeared.")
        }
    
        logIn += {
            print("Log In tapped.")
        }
    }

}
```

#### <a name='AttachingEmittersWithAttachedEmitter'></a>Attaching Emitters With `@AttachedEmitter`

Sometimes it's necessary to pass the emitter down to a particular `View` instance from within different parents. The best way to achieve that, is to use the `@AttachedEmitter` property wrapper in conjunction with the `attach(emitter:at:)` instance method available for every `View`.

Consider having a view which wants to open a certain link when a button is clicked:

```swift
struct ChildView : View {

    @AttachedEmitter var openLink : SignalEmitter

    var body : some View {
        VStack {
            Button(emitter: openLink) {
                Text("Open link")
            }
        }
    }

}
```

> ❗️ It's highly discouraged to subscribe to emitters provided via `@AttachedEmitter` property wrappers inside views—the `observers` computed property on a `Component` instance should be used instead.

Now, if we put it inside a component, we can attach an emitter to be passed down to the view. The emitter is attached to the *projected value* of the `@AttachedEmitter` property wrapper. It is then can be used to emit events like an ordinary emitter:

```swift
// SomeComponent.swift

struct SomeComponent : Component {
    
    let openLink = SignalEmitter()

}

// SomeComponent+Observers.swift

extension SomeComponent {

    var observers : Void {
        openLink += {
            print("Link will be opened from here.")
        }
    }

}

// SomeComponent+View.swift

extension SomeComponent : View {

    var body : some View {
        VStack {
            ChildView()
                .attach(openLink, at: \.$openLink)
        }
    }

}
```

### <a name='RouterComponent'></a>`RouterComponent`

`RouterComponent` is a protocol which is based on a basic `Component` protocol, but also requires the conforming `struct` to have a `Router`  instance defined.

`RouterComponent` presents a `RouterView`, which displays the currently specified `Router`'s keypath. Any router component can present any number of children views, which are defined as properties on the router component itself. 

Consider having the following components defined:

```swift
// LogIn.swift

struct LogInComponent : Component {

    let openSignUp = SignalEmitter()

}

// LogIn+Observers.swift

extension LogInComponent {

    var observers : Void {
        None
    }

}
```

```swift
// SignUp.swift

struct SignUpComponent : Component {

    let openLogin = SignalEmitter()

}

// SignUp+Observers.swift

extension SignUpComponent {

    var observers : Void {
        None
    }

}
```

Then, we need to have a router component that would switch between our two components when a particular signal is received:

```swift
// Auth.swift

struct AuthComponent : RouterComponent {

    let logIn = LogInComponent()
    let signUp = SignUpComponent()
    
    @ObservedObject var router = Router(start: \Self.logIn)

}

// Auth+Observers.swift 

extension AuthComponent {

    var observers : Void {
        logIn.openSignUp {
            router.replace(\Self.signUp)
        }
        
        signUp.openLogIn {
            router.replace(\Self.logIn)
        }
    }

}
```

> ❗️ `RouterComponent provides default implementation for its SwiftUI view, so you don't have to provide your own body, if you have some simple cases.

Now, pushing any button in the appropriate component triggers the signal emitter, which, in turn, is observed by the `AuthComponent` and the currently presented component is replaced.

There could be an occasion where routing is placed outside of the routing view. For example, tab bar controllers would have navigation links defined outside of the routed component itself. For this case, you can override the default view of the router component. Let's rewrite our previous example by factoring emitters out of the children components:

```swift
// LogIn.swift

struct LogInComponent : Component {

}

// LogIn+Observers.swift

extension LogInComponent {

    var observers : Void {
        None
    }

}

// LogIn+View.swift

extension LogInComponent {

    var body : some View {
        Text("Welcome To Log In")
    }

}
```

```swift
// SignUp.swift

struct SignUpComponent : Component {

}

// SignUp+Observers.swift

extension SignUpComponent {

    var observers : Void {
        None
    }

}

// SignUp+View.swift

extension SignUpComponent {

    var body : some View {
        Text("Welcome To Sign Up")
    }

}
```

We should put the emitters onto the parent component instead:

```swift
// Auth.swift

struct AuthComponent : RouterComponent {

    let logIn = LogInComponent()
    let signUp = SignUpComponent()
    
    let openSignUp = SignalEmitter()
    let openLogIn = SignalEmitter()
    
    @ObservedObject var router = Router(start: \Self.logIn)

}

// Auth+Observers.swift

extension AuthComponent {

    var observers : Void {
        openSignUp {
            router.replace(\Self.signUp)
        }

        openLogIn {
            router.replace(\Self.logIn)
        }
    }

}

// Auth+View.swift

extension AuthComponent : View {
    
    var body : some View {
        VStack {
            RouterView(router)
            
            HStack {
                Button(emitter: openLogIn) {
                    Text("Log In")
                }
                
                Button(emitter: openSignUp) {
                    Text("Sign Up")
                }
            }
        }
    }
    
}
```

This case of centralised navigation ensures that `RouterView` is accompanied by other views that actually define navigation actions that users can perform.

> ❗️ You must add `RouterView(router)` somewhere into the body of your `AuthComponent` in order for your children content to show up properly.

#### <a name='Router'></a>`Router`

Your `struct` conforming to `RouterComponent` must always define exactly one `Router` object that manages the routing. All routes are specified as keypaths to the components in the very same routing component:

```swift
// Auth.swift

struct AuthComponent : RouterComponent {

    let logIn = LogInComponent()
    let signUp = SignUpComponent()

    @ObservedObject var router = Router(start: \Self.logIn)

}

// Auth+Observers.swift 

extension AuthComponent {

    var observers : Void {
        // ...
    }

}
```

The starting route must always be specified as a keypath to the component which will be presented at first. A `Router` instance has the following methods to perform navigation:

- `router.replace(_ keyPath : KeyPath<Component, Component>)` replaces the whole routing stack with the specified keypath.
- `router.push(_ keyPath : KeyPath<Component, Component>, animated : Bool = true)` pushes a new view into the routing stack.
- `router.pop(animated : Bool = true)`  removes the last keypath from the routing stack.
- `router.popToRoot(animated : Bool = false)` removes all the keypaths from the routing stack and returns to the root one (which is specified when you create a `Router` instance).

Whenever any of the aforementioned routing methods are executed, the router componet's view is immediately updated with the contents of the component under the routed keypath.

```swift
// Auth+Observers.swift 

extension AuthComponent {

    var observers : Void {
        openLogIn += {
            router.replace(\Self.logIn)
        }
    }

}
```

> ❗️ Pushing and popping operations are animated by the `Router` instance. If you wish to prevent router from animating, you could always pass the `animated: false` property when you do a push or a pop operation. The replace operation is not animated by the router.

It is also possible to observe `router.path` and `router.paths` properties to access the currently navigated keypath. This can be used to alter the presentation of your view:

```swift
// Auth+View.swift

extension AuthComponent : View {

    var body : some View {
        VStack {
            RouterView(router)

            HStack {
                Button(emitter: openLogIn) {
                    Text("Log In")
                }
                .foregroundColor(router.path == \Self.logIn ? Color.blue : Color.gray)

                Button(emitter: openSignUp) {
                    Text("Sign Up")
                }
                .foregroundColor(router.path == \Self.signUp ? Color.blue : Color.gray)
            }
        }
    }

}
```

> ❗️ Don't forget to mark your `router` as `@ObservedObject` if you're going to observe its `path` or any other properties directly inside the SwiftUI View of the component.

#### <a name='EnclosingRouter'></a>`@EnclosingRouter` 

It is useful, especially with push & pop style navigation, to access the current router without having to define one. For example, any nested component might need to be able to present some other component. It doesn't have to define the router for itself if it is well known that this particular component will always have some enclosing router around it.

Consider having the following component for resetting password:

```swift
// ResetPassword.swift

struct ResetPasswordComponent : Component {

}

// ResetPassword+Observers.swift

extension ResetPasswordComponent {

    var observers : Void {
        None
    }

}

// ResetPassword+View.swift

extension ResetPasswordComponent {

    var body : some View {
        Text("Welcome To Reset Password")
    }

}
```

This component is defined inside `LogInComponent` and presented via the push & pop style navigation. `LogInComponent` is always presented by the `AuthComponent` which already defines a router. This means `LogInComponent` itself doesn't need to have a router, and instead can rely on an enclosing router for its push & pop style navigation:

```swift
// LogIn.swift

struct LogInComponent : Component {

    let resetPassword = ResetPasswordComponent()

    @EnclosingRouter var router

    let openResetPassword = SignalEmitter()

}

// LogIn+Observers.swift

extension LogInComponent {

    var observers : Void {
        openResetPassword += {
            router.push(\Self.resetPassword)
        }

        resetPassword.goBack += {
            router.pop()
        }
    }

}

// LogIn+View.swift

extension LogInComponent {

    var body : some View {
        VStack {
            Text("Welcome To Log In")
           
            Button(emitter: openResetPassword) {
                Text("Reset Password")
            }}
        }
    }

}
```

Routers referenced by the `@EnclosingRouter` property wrapper have access to `push` and `pop` methods only, and cannot do `replace` operations because it doesn't make sense for nested routing with push & pop navigation style.

#### <a name='RouterView'></a>`RouterView`

Sometimes it is handy to be able to add a default view on the router component itself. In order to do that, it's possible pass the default view using `@ViewBuilder` when creating a `RouterView` instance:

```swift
// Onboarding.swift

struct OnboardingComponent : RouterComponent {

    let next = NextComponent()

    @ObservedObject var router = Router()

    let openNext = SignalEmitter()

}

// Onboarding+Observers.swift

extension OnboardingComponent {

    var observers : Void {
        openNext += {
            router.push(\Self.next)
        }
    }

}

// Onboarding+View.swift

extension OnboardingComponent : View {

    var body : some View {
        RouterView(router) {
            VStack {
                Button(emitter: openNext) {
                    Text("Open Next Page")
                }
            }
        }
    }
    
}
```

A `RouterView` instance must be created by passing in the `Router` instance which will use the speciffied view to present its content.

When default router view is specified, the `Router` instance must be created without any starting keypath.

> ❗️ It is highly discouraged to put dynamic and instance components as default views for routers—their memory won't be properly managed that way. Please only have static components or simple views as default router views.

### <a name='StartupComponent'></a>`StartupComponent`

`StartupComponent` is a protocol which is conformed by a component you define as your root application component.

Compose provides `StartupComponent` as a standard way of bootstrapping the whole application without the necessity to deal with application delegates, scenes, and iOS 13 versus iOS 14 differences.  

The application must contain a root component, which is usually also a router component. Regularly such a root component is called `AppComponent`:

```swift 
// App.swift

@main
struct AppComponent : RouterComponent {

    let auth = AuthComponent()
    let home = HomeComponent()
    
    @ObservedObject var router = Router(start: \Self.auth)

}

// App+Startup.swift

extension AppComponent : StartupComponent {

    func willBindRootComponent() {
        // Setup your application in a familiar manner (e.g. add Firebase, Google Analytics, any other integrations)
    }
    
    func didBindRootComponent() {
        // Root component is now bound, you may access all the underlying children components, emitters, and other properties.
    }

}
```
> ❗️ Don't forget to add the `@main` attribute to your root component so Swift can figure the entry point for you!

If you conform your root component to `StartupComponent`, you don't need to add any other source files in your project to make your application work. Compose takes care of the setup for you.

### <a name='DynamicComponent'></a>`DynamicComponent`

`DynamicComponent` is a `struct` that accepts the component you wish to make dynamic as a generic parameter.

`DynamicComponent`'s underlying component must be initialised by the developer. `DynamicComponent` is used when the component has to be initialised lazily.

The input data is usually passed via the initialiser of the component:

```swift
// ProfileObject.swift

struct ProfileObject {
    let fullName : String
}

// Profile.swift

struct EditProfileComponent : Component {

    let profile : ProfileObject
    
    let close = SignalEmitter()

}
```

Initialisation of any  `EditProfileComponent` instace always requires `profile` to be passed in. This is easily achieved with `DynamicComponent`:

```swift
// Profile.swift

struct ProfileComponent : RouterComponent {

    let editProfile = DynamicComponent<EditProfileComponent>()

    @ObservedObject var router = Router(start: \Self.self)

    let openEditProfile = Emitter<ProfileObject>()

}

// Profile+Observers.swift

extension ProfileComponent {

    var observers : Void {
        openEditProfile += { profileToEdit in 
            // Create an instance of an underlying component
            editProfile.create(EditProfileComponent(profile: profileToEdit))
  
            // Present the instance using routing
            router.push(\Self.editProfile)
        }
    }

}
```

All instances of `DynamicComponent` manage their memory automatically. That means, when you present it via the router, or inside a sheet, the underlying component will be deallocated as soon as it goes out of scope. For example, for sheet presentation, it will be deallocated as soon as sheet is dismissed. For router push/pop navigation, the component will be deallocated as soon as the component is popped from the router.

> ❗️ If you try to navigate to dynamic component before it has been created, you will get an assertion failure and a crash. The component must always be created with `create(_:)` method on a `DynamicComponent` instance.

> ❗️ Keep in mind that all observers of all emitters are destroyed automatically when the component goes out of scope. When it disappears, all observers you setup in the `observers` computed property are cancelled.

#### <a name='LifecycleEmitters'></a>Lifecycle Emitters

`DynamicComponent` provides two lifecycle emitters:

- `didCreate` is invoked as soon as dynamic component was created.
- `didDestroy` is invoked as soon as dynamic component was destroyed.

### <a name='InstanceComponent'></a>`InstanceComponent`

While `DynamicComponent` allows only one *instance* of a component to be created, there are cases where it might be necessary to create any number of dynamic components. This might be useful, for example, to display infinite number of nested components of the same type (for example, opening a video player component from another video player component which was presented by another video player component). 

`InstanceComponent` works similarly to `DynamicComponent`, but allows having infinite number of components created instead. The `InstanceComponent` instance manages memory of all underlying components—all underlying components are automatically destroyed when they go out of scope.

#### <a name='LifecycleEmitters-1'></a>Lifecycle Emitters

`InstanceComponent` provides two lifecycle emitters:

- `didCreate` is invoked as soon as one of instances was created. The UUID of created component is supplied via the emitter.
- `didDestroy` is invoked as soon as one of instances was destroyed. The UUID of destroyed component is supplied via the emitter.

#### <a name='Supplementarymethods'></a>Supplementary methods

Sometimes it is necessary to access the particular instance of an instance component to subscribe to its parts. The `InstanceComponent` has a `instance(for id: UUID)` instance method which helps retrieving a particular instance of an underlying component managed by the `InstanceComponent` component.

## <a name='Services'></a>Services

`Service` is a `protocol` which is adopted by `struct` entities to create services.

Services are globally available shared pieces of application structure. Services are useful when there is some piece of data and some methods that operate on the data that need to be shared with the rest of components and available everywhere. 

Services are available under `services` property for all instances of all components.

Service defintion is split into two parts:

- Create a `struct` with the service which conforms to `Service` protocol.
- Extend `Services` with the computed property that returns the value via the type of the service as a key.

```swift
// UserService.swift

extension Services {

    var user : UserService {
        get {
            self[UserService.self]
        }
        set {
            self[UserService.self] = newValue
        }
    }

}

struct UserService : Service {

    static var Name = "storyline.user"
    
}

// UserService+Account.swift

extension UserService {

    func login() {
        // Log in action is performed here
    }

}
```

> ❗️ The services are always initialized lazily. This means they're only created when they're accessed for the first time. 

The `UserService` instace will be available to all components inside the computed properties, for example:

```swift
// Auth+Observers.swift

extension AuthComponent {
    
    var observers : Void {
        login += {
            services.user.login()
        }
    }
    
}
```

As you can see, the `UserService` is available as `services.user` in the `AuthComponent` (and in all other components too).

## <a name='StoreAndStateManagement'></a>`@Store` And State Management

`@Store` is a property wrapper which is used inside components to manage state of a certain data shape represented by a structure conforming to `AnyState`. 

Store is defined with a property wrapper:

```swift
@Store var state : State
```

`@Store` property wrapper can only be applied to value types that conform to `AnyState`. 

The `struct` that holds data of the state is the only required type to initialise a `Store` instance. This `struct` must conform to `AnyState` protocol.  The protocol requires any state to be:

- `Equatable` to find out changes and generate state differences.
- Forces state to contain an empty  `init()`, which means that all state properties must have some default value.

> ❗️ Properties of the state must be value types in order for all changes to be propagated correctly. If you put `class` instances into your state and update their properties, the state will not be updated and changes will not propagate to the views that use the state.


```swift
// LogIn.swift

struct LogInComponent : Component {

    @Store var state : State

}

// LogIn+State.swift

extension LogInComponent {

    struct State : AnyState {
        var firstName = ""
        var lastName = ""
    }

}
```

Now the state is accessible to the SwiftUI view. It's possible to query the state values using the `state.firstName` and `state.lastName` from within the view to get the values and update the view whenever the values change:

```swift
// LogIn+View.swift

extension LogInComponent : View {

    var body : some View {
        VStack {
            Text("Hello, \(state.firstName)")
        }
    }

}
```

To access various properties of the `@Store` property wrapper, use `$`-notation to get access to projected value of a property wrapper. For example, if you defined your state as `@Store var state : State`, you can access meta properties via the `$state` expression. THe following properties are exposed via projected value of a `@Store` property wrapper:

- `$state.binding` to get a `Binding` instance from the state.
- `$state.persistence` to get access to persistence capabilities.
- `$state.willChange` to subscribe to state changes in `+Observers.swift` files.

It's possible to pass `State` values into some SwiftUI views (e.g. `TextField`) as `Binding` instances:

```swift
// LogIn+View.swift

extension LogInComponent : View {

    var body : some View {
        VStack {
            Text("Hello, \(state.firstName)")

            TextField("First Name", text: $state.binding.firstName)
            TextField("Last Name", text: $state.binding.lastName)
        }
    }

}
```

Now whenever the value of one of the `TextField` views is changed, the values will be instantly stored in the state under the `firstName` and `lastName` values respectively. 

It's also possible to subscribe to changes to the store via emitters. The `willChange` emitter exposed by any `@Store` property wrapper projected value can be observed in a familiar manner:

```swift
// LogIn+Observers.swift

extension LogInComponent {

    var observers : Void {
        $state.willChange += { state in
            print("New full name is \(state.firstName) \(state.lastName).")
        }
    }

}
```

Using emitter chaining, it's possible to get updates of a certain value in the state instead of the whole state:

```swift
// LogIn+Observers.swift

extension LogInComponent {

    var observers : Void {
        $state.willChange.undup().tap(\.firstName) += { firstName in
            print("New firstName is \(firstName)")
        }
    }

}
```

### <a name='ValidatingState'></a>Validating State

To reactively validate any state `struct`, one can define a validation as a computed property inside the state. For simple cases, validation can be expressed with Swift methods without any higher-level abstractions. For example, it's easy to check whether the state values are valid:

```swift
 struct State : AnyState {
    var email : String = ""
    var password : String = ""

    var isValid : Bool {
        // Very simple validation example
        email.isEmpty == false && password.isEmpty == false && password.count > 10
    }
}
```

Compose also provides advanced validation techniques with error reporting via `@ValidationBuilder` and `Validation` helpers. Consider the state from the previous example and its validation:

```swift
// LogIn+State.swift

extension LogInComponent {

    struct State : AnyState {
        var email : String = ""
        var password : String = ""

        @ValidationBuilder
        var credentials : Validation {
            Field(email, rules: .nonEmpty, .email)
            Field(password, rules: .length(6...1000))
        }
    }
    
}
```

> ❗️ `Validation` must always be a computed property on your state. Do not forget to add `@ValidationBuilder` to the computed property to define `Validation` easier with a property builder.

The defined validation can now be used within the view to disable submit button inside our component view:

```swift
// LogIn+View.swift

extension LogInComponent : View {

    var body : some View {
        VStack {
            TextField("Email", text: $state.binding.email)
            SecureField("Password", text: $state.binding.password)
            Button(emitter: login) {
                Text("Log In")
            }
            .disabled(state.credentials.isValid == false)
            .opacity(state.credentials.isValid == false ? 0.5 : 1.0)
        }
    }

}
```

Notice that the validation above exposes `state.credentials.isValid` to check whether all fields are valid. If necessary, it's also possible to provide error messages for validations:

```swift
// LogIn+State.swift

extension LogInComponent {

    struct State : AnyState {
        var email : String = ""
        var password : String = ""

        @ValidationBuilder
        var credentials : Validation {
            Field(email, rules: [
                .nonEmpty : "Email address must be non-empty",
                .email : "Invalid email address format"
            ])
            Field(password, rules: [
                .length(6...1000) : "Password must be at least 6 characters long"
            ])
        }
    }
    
}
```

The error messages will be accessible under `state.credentials.errors` as an array of error strings for all invalid fields.

#### <a name='Validation'></a>`Validation`

Exposes the following properties:

- `isValid` to check whether the validator contains any errors, or whether all data is valid.
- `errors` is an array of error messages for invalid keypaths.

All mentioned fields are automatically updated because `Validation` is always defined as a computed property.

`Validation` contains any number of `Field` instances via property builder.

#### <a name='Field'></a>`Field`

Points at a particular state value to be validated:

```swift
Field(firstName, rules: .nonEmpty)
```

`Field` itself doesn't expose any properties.

`Field` is created with specific set of `Rule` instances applied to the value to validate it.

#### <a name='ArrayField'></a>`ArrayField`

Points at a particular array state value to be validated:

```swift
ArrayField(arrayToValidate,
           validIfEmpty: true,
           path: \ArrayElementType.title,
           rules: .nonEmpty, .length(0...90))
```

`ArrayField` ensures all fields in array are valid with predefined constraints. The initialiser of `ArrayField` accepts the following arguments:

- `validIfEmpty` is a boolean value which indicates whether an empty array should produce valid result or not.
- `path` is a keypath that points to a property on an element of an array to apply validation rules to.

#### <a name='Rule'></a>`Rule`

Defines a particular rule to be executed on a field.

There are several predefined validators shipped with Compose:

- `.nonEmpty` to ensure that the field is non-empty.
- `.email` to ensure that the field is an email.
- `.length(10...30)` to ensure the field has a particular length.
- `.equal(to: repeatedPassword)` to ensure fields match.

> ❗️ It's also possible to define a new rule by extending the `Rule` structure.

### <a name='TrackingStateStatuses'></a>Tracking State Statuses

There are times where we have to notify user interface about certain progresses in the application. Doing network request, processing large amount of data usually result in some sort of loading indicators presented in the user interface. 

Given the previous example of `LogInComponent`, we can imagine having two long network requests to check our fields on the backend separately. We start with creating a `Status` enumeration which conforms to the `AnyStatus` and `Codable` protocols. Then we add a property of type `StatusSet<Status>` to our state: 

```swift
// LogIn+State.swift

extension LogInComponent {

    enum Status : String, AnyStatus {
        case loading, loadingProfile
    }

    struct State : AnyState {
        var status = StatusSet<Status>()

        var email : String = ""
        var password : String = ""

        @ValidationBuilder
        var credentials : Validation {
            Field(email, rules: [
                .nonEmpty : "Email address must be non-empty",
                .email : "Invalid email address format"
            ])
            Field(password, rules: [
                .length(6...1000) : "Password must be at least 6 characters long"
            ])
        }
    }

}
```

Now we can use the status in our `+Observers.swift` file:

```swift
// LogIn+Observers.swift

extension LogInComponent {

    var observers : Void {
        login += {
            state.status += .loading
            state.status += .loadingProfile
            
            services.network.login(email: state.email, password: state.password) { 
                state.status -= .loading
            }
            
            services.network.loadProfile(email: state.email) { 
                state.status -= .loadingProfile
            }
        }
    }

}
```

Now it's possible to use the status to adjust our UI behaviour:

```swift
// LogIn+View.swift

extension LogInComponent : View {

    var body : some View {
        VStack {
            TextField("Email", text: $state.binding.email)
            SecureField("Password", text: $state.binding.password)
            Button(emitter: login) {
                Text("Log In")
            }
            .disabled(state.credentials.isValid == false)
            .opacity(state.credentials.isValid == false ? 0.5 : 1.0)
        }
        .overlay(
            Text("Loading")
                .opacity(state.status.isEmpty == false ? 1.0 : 0.0)
        )
    }

}
```

> ❗️ The `StatusSet<Status>` is a typealias to `Set<AnyStatus>`. This means it is not possible to set the same status more than one time.

#### <a name='StatusSetOperators'></a>`StatusSet` Operators

There are several operators defined to operate on any `StatusSet` instance:

- `+=` to add a new status to the list of statuses.
- `-=` to remove status from the list of statuses.
- `|=` to replace all statuses in the list with the specified status.
- `~=` to check if the list of statuses contains a particular status.
- `!~=` to check if the list of statuses doesn't contain a particular status.

### <a name='PersistingState'></a>Persisting State

It's useful to persist certain state to some kind of storage. The persistence can be used to store small chunks of data which can be retrieved at any time, even between launches of the application. 

Compose comes with two persistent storages that can be used by `Store` instances:

- `EmptyPersistentStorage` is a default persistent storage which does nothing.
- `FilePersistentStorage` is a file-based storage for data. It can be initialised with a tag that will be used as its local filename: `FilePersistentStorage(key: "my-key")`

> ❗️ It's possible to define new persistent storages by conforming to `AnyPersistentStorage` protocol.

The storage is specified when the store is created via the `@Store` property wrapper initialiser:

```swift
// LogIn.swift

struct LogInComponent : Component {

    @Store(storage: FilePersistentStorage(key: "login-fields")) var state : State

    let login = SignalEmitter()

}
```

The `persistence` property of the `@Store` projected value has several methods to manually do persistence actions:

- `save()` to store the data to the persistent storage.
- `restore()` to load the data from the persistent storage into the state.
- `purge()` to erase all stored data in the specified persistent storage.

These methods are meant to be called manually during the lifecycle of a component or a service:

```swift
// LogIn.swift

struct LogInComponent : Component {

    @Store(storage: FilePersistentStorage(key: "login-fields")) var state : State

    let login = SignalEmitter()

    init() {
        $state.persistence.restore()
    }
}

// LogIn+Observers.swift

extension LogInComponent {

    var observers : Void {
        login += {
            state.persistence.save()
        }
    }

}
```

> ❗️ The `persistence` property of `@Store` projected value requires state to conform to `Codable` protocol.

#### <a name='ChoosingPersistedValues'></a>Choosing Persisted Values

The store persistence requires that `State` conforms to `Codable` protocol. This allows any storage to immediately serialize data into some intermediate format to be stored in the storage. 

It is easy to choose which values are going to be stored in the persistence via the `CodingKey` enumeration defined on the state:

```swift
// LogIn+State.swift

extension LogInComponent {

    struct State : Codable, AnyState {

        enum CodingKeys : CodingKey {
            case email
        }
    
        var email : String = ""
        var password : String = "" 
        var shouldShowWelcomeMessage : Bool = false
    }
    
}
```

`CodingKeys` defines the shape of persisted data—the `email` property will be persisted, but all other fields will not be persisted.

### <a name='IdentifiedReferencesviaRefandRefCollection'></a>Identified References via  `@Ref` and `@RefCollection`

The `@Ref` and `@RefCollection` wrappers are used when declaring properties of the state for a `Store` instance. `@Ref` property wrapper is used for single objects, `@RefCollection` property wrapper is used for collection of objects.

Sometimes data managed by a component might be mutated by child components. `@Ref` and `@RefCollection` property wrappers are used to keep interactive chunks of data synced between different components (most importantly, between children components of the same parent component).

In order to use the aforementioned property wrappers, the underlying object must conform to the following protocols:

- `Codable` for serialization and storage purposes.
- `Equatable` for equality checks.
- `Identifiable` to make sure all objects are unique within a specific type.

> ❗️ Identifiers for your objects must be unique. If your objects have collisions between their identifiers, the behavior of `@Ref` and `@RefCollection` is **undefined**.

Firstly, a model must be defined that is going to be passed between components:

```swift
// SpecimenModel.swift

struct SpecimenModel : Codable, Equatable, Identifiable {
    var id : String
    var name : String
}
```

Consider having a component which displays two underlying components:

```swift
// Exhibition.swift

struct ExhibitionComponent : Component {

    let specimenA : SpecimenComponent
    let specimenB : SpecimenComponent

    @Store var state : State

    init() {
        self.specimenA = SpecimenComponent(specimen: state.$specimen)
        self.specimenB = SpecimenComponent(specimen: state.$specimen)
    }
}

// Exhibition+State.swift

extension ExhibitionComponent {

    struct State {
        @Ref var specimen = SpecimenModel(id: "MY-MODEL-ID", "Funny Circle")
    }

}

// Exhibition+View.swift

extension ExhibitionComponent : View {

    var body : some View {
        VStack {
            Text("Welcome, we can show a '\(state.specimen.name)' today")
            specimenA
            specimenB
        }
    }

}
```

Note how we pass `state.$specimen` into the children components instead of the value itself. The `$` notation allows us to obtain the `Referred` instance—a super-lightweight object that can be passed around and assigned to other `Ref` instances via the same `$` notation. 

It's time to define the underlying `SpecimenComponent`:

```swift
// Specimen.swift

struct SpecimenComponent : Component {

    @Store var state : State

    init(specimen : Referred<SpecimenModel>) {
        state.$specimen = specimen
    }

}

// Specimen+State.swift
extension SpecimenComponent {

    struct State {
        @Ref var specimen : SpecimenModel
    }

}

// Specimen+View.swift 
extension SpecimenComponent : View {

    var body : some View {
        VStack {
            TextField("Name", text: $state.binding.specimen.name)
        }
    }

}
```

When we pass a `$specimen` to the constructor of our children components, we pass the `Referred` instance, which can be assigned to another `@Ref` object via `state.$specimen = specimen`. The `Referred` instance only carries the information necessary for the underlying `@Ref` property wrapper to hook up to the value by its identifier. 

Now, when one of the text fields is updated in one of the components, all other values marked by `@Ref` will also be automatically updated, which ensures full synchronisation of the value across different components. 

`@RefComponent` works in a similar manner, but instead holds an array of data that can be also passed around:

```swift
// Exhibition.swift

struct ExhibitionComponent : Component {

    let specimenA : SpecimenComponent
    let specimenB : SpecimenComponent

    @Store var state : State

    init() {
        self.specimenA = SpecimenComponent(specimen: state.$specimens[0])
        self.specimenB = SpecimenComponent(specimen: state.$specimens[1])
    }
}

// Exhibition+State.swift

extension ExhibitionComponent {

    struct State {
        @RefCollection var specimens = [
            SpecimenModel(id: "MY-MODEL-ID-FIRST", "Funny Circle"),
            SpecimenModel(id: "MY-MODEL-ID-SECOND", "Heavy Box")
        ]
    }

}

// Exhibition+View.swift

extension ExhibitionComponent : RoutableView {

    var body : some View {
        RouterView(router)
    }

    var routableBody : some View {
        VStack {
            Text("Welcome, we can show '\(state.specimens[0].name)' and '\(state.specimens[1].name)' today")
            specimenA
            specimenB
        }
    }

}
```

Updating a particular specimen would update only the appropriate chunk text and leave the other one be.

### <a name='CentralisedVersusDecentralisedStateManagement'></a>Centralised Versus Decentralised State Management

On the one hand, Compose favours decentralised data storage: each component has its own store (one or many) that holds the component's state, validates it, and performs actions with the services.

On the other hand, services can also have their own stores, making data available globally to all components. This enables developers to recreate familiar Redux-like storage solutions, where services encapsulate stores and actions on the stores, and views rely on the services' stores to display reactive, constantly changing data.

Which way data is stored in a particular application is never specified by Compose itself—the pattern is chosen by the developer.
