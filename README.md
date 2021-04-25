# Compose

Compose is an opinionated architecture framework intended to create applications for iOS and macOS. Compose is built on top of Combine and SwiftUI.

- 🌴 Component tree
- 🚦 Event-driven communication between components
- 🚏 Easy to use routing
- 🧨 Reactive store
- 🏛 Predicable file structure
- 👨🏽‍💻 UI elements to implement navigation from scratch

_Compose is still a work in progress. The framework is still alpha—feature set may change, variable and method names may change too._

##  1. <a name='TableofContents'></a>Table of Contents

<!-- vscode-markdown-toc -->
* 1. [Table of Contents](#TableofContents)
* 2. [Supported Platforms](#SupportedPlatforms)
* 3. [Installation](#Installation)
* 4. [Getting Started](#GettingStarted)
* 5. [Emitters](#Emitters)
	* 5.1. [Emitters Operators](#EmittersOperators)
	* 5.2. [Emitters Chaining](#EmittersChaining)
		* 5.2.1. [Debounce](#Debounce)
		* 5.2.2. [Filter, Only, Not](#FilterOnlyNot)
		* 5.2.3. [Map](#Map)
		* 5.2.4. [Merge](#Merge)
		* 5.2.5. [Tap](#Tap)
		* 5.2.6. [Undup](#Undup)
* 6. [Components](#Components)
	* 6.1. [`Component`](#Component)
		* 6.1.1. [Preinstalled Lifecycle Emitters](#PreinstalledLifecycleEmitters)
	* 6.2. [Attaching Emitters With `@EmitterObject`](#AttachingEmittersWithEmitterObject)
	* 6.3. [`RouterComponent`](#RouterComponent)
		* 6.3.1. [`Router`](#Router)
		* 6.3.2. [`RouterView`](#RouterView)
		* 6.3.3. [`RoutableView`](#RoutableView)
	* 6.4. [`StartupComponent`](#StartupComponent)
	* 6.5. [`LazyComponent`](#LazyComponent)
		* 6.5.1. [Lifecycle Emitters](#LifecycleEmitters)
	* 6.6. [`DynamicComponent`](#DynamicComponent)
		* 6.6.1. [Lifecycle Emitters](#LifecycleEmitters-1)
* 7. [Services](#Services)
* 8. [Stores](#Stores)
	* 8.1. [State via  `AnyState`](#StateviaAnyState)
	* 8.2. [Validations via  `AnyValidation`](#ValidationsviaAnyValidation)
		* 8.2.1. [`Validator`](#Validator)
		* 8.2.2. [`ValidatorField`](#ValidatorField)
		* 8.2.3. [`ValidatorRule`](#ValidatorRule)
	* 8.3. [Statuses via  `AnyStatus`](#StatusesviaAnyStatus)
		* 8.3.1. [`AnyStatus` operators](#AnyStatusoperators)
	* 8.4. [Persistence via  `AnyPersistentStorage`](#PersistenceviaAnyPersistentStorage)
		* 8.4.1. [Choosing Persisted Values](#ChoosingPersistedValues)
	* 8.5. [Identified References via  `@Ref` and `@RefCollection`](#IdentifiedReferencesviaRefandRefCollection)
	* 8.6. [Data Management](#DataManagement)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  2. <a name='SupportedPlatforms'></a>Supported Platforms

- iOS 13+
- macOS 10.15+

##  3. <a name='Installation'></a>Installation

Xcode 11+ with Swift 5.3 is required to use Compose. 

To install Compose using Swift Package Manager, open the following menu item in Xcode:

**File > Swift Packages > Add Package Dependency**

In the Choose Package Repository prompt add url:

```
https://github.com/din/compose
```

Include the library as a dependency for your target then import it when you need it:

```swift
import Compose
```

##  4. <a name='GettingStarted'></a>Getting Started

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

##  5. <a name='Emitters'></a>Emitters 

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

###  5.1. <a name='EmittersOperators'></a>Emitters Operators

There are several operators defined to add subscribers to any emitters (chained or vanilla).

- `+=` is used when the subscription closure must be executed any time an emitter emits a value or a signal.
- `!+=` is used when the subscription closure must be executed **only once** and then never executed again.
- `++=` is used when the subscription closure must be executed any time an emitter emits a value or a signal and immediately with the last emitted value, if presented.

`ValueEmitter` defines one additional operator: 
- `~+=` when the subscription closure must be executed with the new value and the previous emitted value, which allows computing diffing between two emitted values. 

###  5.2. <a name='EmittersChaining'></a>Emitters Chaining

It's possible to produce a chain of emitters to alter the outcome of a previous emitter in such a way. Chaining of emitters is similar to chaining multiple `Publisher` together in Combine. There are several predefined emitters which are scoped under the `Emitters` structure.

####  5.2.1. <a name='Debounce'></a>Debounce

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

####  5.2.2. <a name='FilterOnlyNot'></a>Filter, Only, Not

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
emitter.only(.two) += { value in
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

####  5.2.3. <a name='Map'></a>Map

Transform emitted value using a closure:

```swift
// Define an emitter.
let emitter = ValueEmitter<Int>()

// Filter value using some closure.
emitter.map({ $0 + 10 }) += { value in
    print("Received some value plus '10'.")
}

// Send different values.
emitter.send(5)
emitter.send(10)
emitter.send(35)
```

####  5.2.4. <a name='Merge'></a>Merge

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

> ❗️ You can only merge `ValueEmitters` if they emit the same value type.

####  5.2.5. <a name='Tap'></a>Tap

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

####  5.2.6. <a name='Undup'></a>Undup

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

##  6. <a name='Components'></a>Components

Compose is built with components tree and event-driven communication between them. Compose heavily utilises structures, keypaths, SwiftUI, and Combine to achieve the desired result and abstract complex logic from the user. 

###  6.1. <a name='Component'></a>`Component`

A basic building block for presenting content. A component is usually a single screen of content.  Components define their presentation using SwiftUI `View`. 

`Component` is a protocol which doesn't conform to any other protocol. 

Each component must be a `struct` and must conform to the `Component` protocol. Usually component body contains emitters, stores, and subcomponents.

```swift
// Auth.swift

struct AuthComponent : Component {

    let logIn = SignalEmitter()

}
```

> ❗️ Compose permits subscriptions to emitters only within a component: a component can subscribe to emitters defined by the component itself, or by any child component. It is not possible to subscribe to events in parent components!

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

> ❗️ You should never read `observers` property manually anywhere in your code: Compose automatically sets this up for you.

This component can now be presented in the tree of components using `Router` or via direct presentation within a view.

####  6.1.1. <a name='PreinstalledLifecycleEmitters'></a>Preinstalled Lifecycle Emitters

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

###  6.2. <a name='AttachingEmittersWithEmitterObject'></a>Attaching Emitters With `@EmitterObject`

Sometimes it's necessary to pass the emitter down to a particular `View` instance from within different parents. The best way to achieve that, is to use the `@EmitterObject` property wrapper in conjunction with the `attach(emitter:at:)` instance method available for every `View`.

Consider having a view which wants to open a certain link when a button is clicked:

```swift
struct ChildView : View {

    @EmitterObject var openLink : SignalEmitter

    var body : some View {
        VStack {
            Button(emitter: openLink) {
                Text("Open link")
            }
        }
    }

}
```

> ❗️ It's highly discouraged to subscribe to emitters provided via `EmitterObject` property wrappers inside views—the `observers` computed property on a `Component` instance should be used instead.

Now, if we put it inside a component, we can attach an emitter to be passed down to the view. The emitter is attached to the *projected value* of the `@EmitterObject` property wrapper. It is then can be used to emit events like an ordinary emitter:

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

###  6.3. <a name='RouterComponent'></a>`RouterComponent`

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

> ❗️ `RouterComponent provides default implementation for SwiftUI view, so you don't have to provide your own body, if you have some simple cases.

Now, pushing any button in the appropriate component triggers the signal emitter, which, in turn, is observed by the `AuthComponent` and the currently presented component is replaced.

There could be an occasion where routing is placed outside of the routing view. For example, tab bar controllers would have navigation links defined outside of the routed component itself. For this case, you can override default view of the router component. Let's rewrite our previous example by factoring emitters out of the children components:

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
            RouterView()
            
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

> ❗️ You must add `RouterView()` somewhere into the body of your `AuthComponent` in order for your children content to show up properly.

####  6.3.1. <a name='Router'></a>`Router`

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
- `router.push(_ keyPath : KeyPath<Component, Component>)` pushes new view into the routing stack.
- `router.pop()`  removes the last keypath from the routing stack.
- `router.popToRoot()` removes all the keypaths from the routing stack and returns to the root one (which is specified when you create a `Router` instance).

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

It's also quite easy to perform the transition when animating to or from a particular view:

```swift
// Auth+Observers.swift 

extension AuthComponent {

    var observers : Void {
        openLogIn += {
            withAnimation {
                router.replace(\Self.logIn)
            }
        }
    }

}
```

> ❗️ The default transition on SwiftUI views is usually defined as a fade in/fade out animation. You can specify your own transitions for routing animations using the `.transition(_:)` method on the top view of your component.

It is also possible to observe `router.path` property to access the currently navigated keypath. This can be used to alter the presentation of your view:

```swift
// Auth+View.swift

extension AuthComponent : View {

    var body : some View {
        VStack {
            RouterView()

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

####  6.3.2. <a name='RouterView'></a>`RouterView`

`RouterView` doesn't expose any configuration because its purpose is to present the children content. 

####  6.3.3. <a name='RoutableView'></a>`RoutableView`

Sometimes it is handy to be able to add a default view on the router component itself. In order to do that, it's possible to use `RoutableView` instead of `View` to be able to route to the current component via the `\Self.self` keypath:

```swift
// Onboarding.swift

struct OnboardingComponent : RouterComponent {

    let next = NextComponent()

    @ObservedObject var router = Router(start: \Self.self)

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

extension OnboardingComponent : RoutableView {

    var body : some View {
        RouterView()
    }
    
    var routableBody : some View {
        VStack {
            Button(emitter: openNext) {
                Text("Open Next Page")
            }
        }
    }

}
```

`RoutableView` requires a component to implement the `routableBody` computed property, which is displayed when the component's router is pointing at `\Self.self` keypath. If any other component's keypath is pushed onto the router stack, the other component's view will be displayed instead.

###  6.4. <a name='StartupComponent'></a>`StartupComponent`

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

###  6.5. <a name='LazyComponent'></a>`LazyComponent`

`LazyComponent` is a `struct` that accepts the component you wish to make lazy as a generic parameter.

Components can be quite heavy and might include a lot of nested components under them. Creating all of them as just properties on your view could sometimes lead to some performance overhead. `LazyComponent` can be used in order to avoid creating the whole component tree right away–the component will be created once it is accessed by the view and the component will be destroyed on disappearance automatically.

```swift
// Profile.swift

struct ProfileComponent : RouterComponent {

    let editProfile = LazyComponent(EditProfileComponent())

    @ObservedObject var router = Router(start: \Self.self)

    let openEditProfile = SignalEmitter()
    
}

// Profile+Observes.swift

extension ProfileComponent : View {

    var observers : Void {
        openEditProfile += {
            router.push(\Self.editProfile)
        }
    }

}

// Profile+View.swift

extension ProfileComponent : RoutableView {

    var body : some View {
        RouterView()
    }

    var routableBody : some View {
        VStack {
            Button(emitter: openEditProfile) {
                Text("Show Edit Profile")
            }
        }
        
    }

}
```

`LazyComponent` initialiser accepts an `@autoclosure` statement: supplied constructor will be executed once the component is accessed by the view. 

####  6.5.1. <a name='LifecycleEmitters'></a>Lifecycle Emitters

`LazyComponent` provides two lifecycle emitters:

- `didCreate` is invoked as soon as lazy component's view appears.
- `didDestroy` is invoked as soon as lazy component's view disappears.

These emitters are super useful to observe underlying component's emitters with ease:

```swift
// EditProfile.swift

struct EditProfileComponent : Component {

    let didSave = SignalEmitter()

}

// Profile+Observers.swift

extension ProfileComponent {

    var observers : Void {
        openEditProfile += {
            router.push(\Self.editProfile)
        }
    
        editProfile.didCreate += {
            print("Edit profile created!")
            
            editProfile.didSave += {
                print("Edit profile's didSave received!")
            }
        }
    }

}
```

> ❗️ Keep in mind that all observers of all emitters are destroyed automatically when the component is destroyed. This means that, even though you have subscribed to `editProfile.didSave`, you did that only for the lfietime of the underlying `EditProfileComponent`. When it disappears, all emitters you setup before are also inactivated. When it appears again, new emitters are setup and the cycle continues.

###  6.6. <a name='DynamicComponent'></a>`DynamicComponent`

`DynamicComponent` is a `struct` that accepts the component you wish to make lazy as a generic parameter.

`DynamicComponent` is very similar to `LazyComponent`, except the latter one is created automatically, and the former one must be initialised by the developer. `DynamicComponent` is used when the underlying component requires any data to be passed into the component.

Consider that `EditProfileComponent` from the `LazyComponent` section requires any input data to be present, the input data is usually passed via the initialiser of the component:

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

In this case, initialisation of any  `EditProfileComponent` instace always requires `profile` to be passed in. This is easily achieved with `DynamicComponent`:

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
            editProfile.create {
                EditProfileComponent(profile: profileToEdit)
            }
            
            // Observe emitters of the newly created instance
            editProfile.close += {
                editProfile.destroy()
                router.pop()
            }
  
            // Present the instance using routing
            router.push(\Self.editProfile)
        }
    }

}
```

> ❗️ If you try to navigate to dynamic component before it has been created, you will get an assertion failure and a crash. The component must always be created with `create(_:)` method and destroyed with `destroy()` method on a `DynamicComponent` instance.

####  6.6.1. <a name='LifecycleEmitters-1'></a>Lifecycle Emitters

`DynamicComponent` provides two lifecycle emitters:

- `didCreate` is invoked as soon as dynamic component was created.
- `didDestroy` is invoked as soon as dynamic component was destroyed.

Lifecycle emitters for `DynamicComponent` instances are used much more rarely because the developer usually controls the lifecycle of dynamic components manually. 

##  7. <a name='Services'></a>Services

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

##  8. <a name='Stores'></a>Stores

`Store` is a `class` which is used by components to encapsulate state of a certain data shape. 

Store is defined with three accompanying types that enhance or modify the store behavior:

```swift
let store = Store<State, Validation, Status>()
```

The first type is always required, and others might be omitted by passing `Empty` as an argument:

```swift
let store = Store<State, Empty, Empty>()
```

As an alternative, there are typealiases `PlainStore`, `ValidatedStore`, and `IndicatedStore`  available to create stores with particular features only:

```swift
let plainStore = PlainStore<State>()
let validatedStore = ValidatedStore<State, Validation>()
let indicatedStore = IndicatedStore<State, Status>()
```

###  8.1. <a name='StateviaAnyState'></a>State via  `AnyState` 

The `struct` that holds data of the state is the only required type to initialise a `Store` instance. This `struct` must conform to `AnyState` protocol.  The protocol requires any state to be:

- `Codable` because data might be serialized and deserialized.
- `Equatable` to find out changes and generate state differences.
- Forces state to contain an empty  `init()`, which means that all state properties must have some default value.

> ❗️ Properties of the state must be value types in order for all changes to be propagated correctly. If you put `class` instances into your state and update their properties, the state will not be updated and changes will not propagate to the views that use the state.


```swift
// LogIn.swift

struct LogInComponent : Component {

    @ObservedObject var store = Store<State, Empty, Empty>()

}

// LogIn+State.swift

extension LogInComponent {

    struct State : AnyState {
        var firstName = ""
        var lastName = ""
    }

}
```


> ❗️ Don't forget to mark the `Store` instance as `@ObservedObject` to make sure all store changes update the SwiftUI view of the component.

Now the state is accessible to the SwiftUI view. It's possible to query the state values using the `store.state.firstName` and `store.state.lastName` from within the view to get the values directly. It's also possible to get the state values as `Binding` instances to pass them into some SwiftUI views (e.g. `TextField`).


```swift
// LogIn+View.swift

extension LogInComponent : View {

    var body : some View {
        VStack {
            TextField("First Name", text: store.binding.firstName)
            TextField("Last Name", text: store.binding.lastName)
        }
    }

}
```

Now whenever the value of one of the `TextField` views are changed, the values will be instantly stored in the state under the `firstName` and `lastName` values respectively. 

It's also possible to subscribe to changes to the store via emitters: the `didChange` emitter exposed by any `Store` instance can be observed in a familiar manner:

```swift
// LogIn+Observers.swift

extension LogInComponent {

    var observers : Void {
        store.didChange += { state in
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
        store.didChange.undup().tap(\.firstName) += { firstName in
            print("New firstName is \(firstName)")
        }
    }

}
```

###  8.2. <a name='ValidationsviaAnyValidation'></a>Validations via  `AnyValidation`

To reactively validate any state `struct`, one can define a set of validators in a `struct` which conforms to the `AnyValidation` protocol. 

Consider the state from the previous example and its validation:

```swift
// LogIn+State.swift

extension LogInComponent {

    struct State : AnyState {
        var email : String = ""
        var password : String = ""
    }

    struct Validation : AnyValidation {

        let credentials = Validator {
            ValidatorField(for: \State.email) {
                NonEmptyRule()
                    .errorMessage("Email address must be non-empty")
                EmailRule()
                    .errorMessage("Invalid email address format")
            }
            ValidatorField(for: \State.password) {
                LengthRule(in: 6...1000)
                    .errorMessage("Password must be at least 6 characters long")
            }
        }

    }
    
}
```

`Validation` structure might contain any number of `Validator` instances. We have to modify our original `store` property on the component to have validation as well:

```swift
// LogIn.swift

struct LogInComponent : Component {

    @ObservedObject var store = Store<State, Validation, Empty>()

    let login = SignalEmitter()

}
```

All validators defined in `Validation` structure are accessible under the `store.validation` property of the `Store` instance. To access the `credentials` validator, for example, the `store.validation.credentials` is used. The defined validation can now be used within the view to disable submit button inside our component view:

```swift
// LogIn+View.swift

extension LogInComponent : View {

    var body : some View {
        VStack {
            TextField("First Name", text: store.binding.firstName)
            TextField("Last Name", text: store.binding.lastName)
            Button(emitter: login) {
                Text("Log In")
            }
            .disabled(store.validation.credentials.isValid == false)
            .opacity(store.validation.credentials.isValid == false)
            
            if store.validation.credentials ~= \Store.firstName {
                Text("First name is invalid")
            }
            
            if store.validation.credentials ~= \Store.lastName {
                Text("Last name is invalid")
            }
        }
    }

}
```

####  8.2.1. <a name='Validator'></a>`Validator`

Exposes the following reactive properties:

- `isEnabled` to enable or disable the validator. Disabled validators are not refreshed when validated fields are updated.
- `isValid` to check whether the validator contains any errors, or whether all data is valid.
- `invalidFields` is an array of keypaths that are not valid. 
- `errors` is an array of error messages for invalid keypaths.

All mentioned fields are automatically updated whenever the fields referenced by keypaths are updated.

`Validator` contains any number of `ValidatorField` instances via function builder.

##### `Validator` operators

You can use the following operators with the `Validator` instance:

- `~=` to check if a particular keypath exists in the `invalidFields` array.
- `!~=` to check if a particular field doesn't exist in the `invalidFields` array.

####  8.2.2. <a name='ValidatorField'></a>`ValidatorField`

Points at a particular state value using a keypath:

```swift
ValidatorField(for: \State.email) {
    ...
}
```

`ValidatorField` itself doesn't expose any properties.

`ValidatorField` contains any number of `ValidatorRule` instances via function builder.

####  8.2.3. <a name='ValidatorRule'></a>`ValidatorRule`

Defines a particular rule to be executed on a field when it changes. `ValidatorRule` instances return a simple boolean to indicate whether the field is valid or not.

```swift
ValidatorField(for: \State.email) {
    NonEmptyRule()
    EmailRule()
}
```

There are several predefined validators shipped with Compose:

- `NonEmptyRule()` to ensure that the field is non-empty.
- `EmailRule()` to ensure that the field is an email.
- `LengthRule(in: 10...30)` to ensure the field has a particular length.
- `EqualityRule(with: ~\State.repeatedPassword)` to ensure fields match.
- `ConstantRule(value: false)` to ensure field has the exactly specified value.
- `ArrayRule()` which uses nested rules to ensure that all values in the specified array are valid.

There is also a `TriggerRule(tag: "your-trigger-tag")` which doesn't provide any innate validation, but can be triggered outside in response to various events:

```swift
validators.credentials.activateTrigger(for: ~\Self.password, tag: "your-trigger-tag")
```

Activating a trigger marks the rule as not valid, which in turns makes validator's `isValid` property equal to `false`.

> ❗️ It's also possible to define a new rule by conforming to `ValidatorRule` protocol.

###  8.3. <a name='StatusesviaAnyStatus'></a>Statuses via  `AnyStatus`

There are times where we have to notify user interface about certain loading progresses in the application. Doing network request, processing large amount of data usually result in some sort of loading indicators presented in the user interface.  `Store` contains the `status` property which simplify managing complex statuses of the particular state with enumerations. 

Given the previous example of `LogInComponent`, we can imagine having two long network requests to check our fields on the backend separately. We start with creating a `Status` enumeration which conforms to the `AnyStatus` protocol:

```swift
// LogIn+State.swift

extension LogInComponent {

    enum Status : AnyStatus {
        case checkingFirstName, checkingLastName
    }

}
```

The store definition has to be changed in order to use the new `Status` type:

```swift
// LogIn.swift

struct LogInComponent : Component {

    @ObservedObject var store = Store<State, Validation, Status>()
    
    let login = SignalEmitter()

}
```

Firstly, we can change the store instance status in our `+Observers.swift` file:

```swift
// LogIn+Observers.swift

extension LogInComponent {

    var observers : Void {
        login += {
            store.status += .checkingFirstName
            store.status += .checkingLastName
            
            services.network.checkFirstName(store.state.firstName) { 
                store.status -= .checkingFirstName
            }
            
            services.network.checkLastName(store.state.lastName) { 
                store.status -= .checkingLastName
            }
        }
    }

}
```

Now it's possible to use  `checkingFirstName` and `checkingLastName` statuses to adjust our UI behaviour:

```swift
// LogIn+View.swift

extension LogInComponent : View {

    var body : some View {
        VStack {
            TextField("First Name", text: store.binding.firstName)
            TextField("Last Name", text: store.binding.lastName)
            Button(emitter: login) {
                Text("Log In")
            }
            .disabled(store.validation.credentials.isValid == false || store.status.isEmpty == false)
            .opacity(store.validation.credentials.isValid == false)
        }
        .overlay(
            Text("Loading")
                .opacity(store.status.isEmpty == false ? 1.0 : 0.0)
        )
    }

}
```

> ❗️ The `status` property of `Store` instances is actually defined as `Set<Status>`, where `Status` is the type passed to the `Store` when initialising it. This means it is not possible to set the same status more than one time.

####  8.3.1. <a name='AnyStatusoperators'></a>`AnyStatus` operators

There are several operators defined to operate on `status` property of any `Store` instance easily:

- `+=` to add a new status to the list of statuses.
- `-=` to remove status from the list of statuses.
- `|=` to replace all statuses in the list with the specified status.
- `~=` to check if the list of statuses contains a particular status.
- `!~=` to check if the list of statuses doesn't contain a particular status.

###  8.4. <a name='PersistenceviaAnyPersistentStorage'></a>Persistence via  `AnyPersistentStorage`

It's useful to persist certain stores to some kind of a storage. The persistence can be used to store small chunks of data which can be retrieved any time even between launches of the application. 

Compose comes with two persistent storages that can be used by `Store` instances:

- `EmptyPersistentStorage` is a default persistent storage which does nothing.
- `FilePersistentStorage` is a file-based storage for data. It can be initialised with a tag that will be used as its local filename: `FilePersistentStorage(key: "my-key")`

> ❗️ It's possible to define new persistent storages by conforming to `AnyPersistentStorage` protocol.

The storage is specified when the store is created via the `Store` initialiser:

```swift
// LogIn.swift

struct LogInComponent : Component {

    @ObservedObject var store = Store<State, Validation, Status>(storage: FilePersistentStorage(key: "login-fields"))

    let login = SignalEmitter()

}
```

The `persistence` property of the `Store` instance has several methods to manually do persistence actions:

- `save()` to store the data to the persistent storage.
- `restore()` to load the data from the persistent storage into the state of the store.
- `purge()` to erase all stored data in the specified persistent storage.

These methods are meant to be called manually during the lifecycle of a component or a service:

```swift
// LogIn.swift

struct LogInComponent : Component {

    @ObservedObject var store = Store<State, Validation, Status>(storage: FilePersistentStorage(key: "login-fields"))

    let login = SignalEmitter()

    init() {
        store.persistence.restore()
    }
}

// LogIn+Observers.swift

extension LogInComponent {

    var observers : Void {
        login += {
            store.persistence.save()
        }
    }

}
```

####  8.4.1. <a name='ChoosingPersistedValues'></a>Choosing Persisted Values

The store persistence heavily relies on the fact that `State` of the store always conforms to `AnyState` protocol, which requires `State` to be `Codable`. This allows any storage to immediately serialize data into some intermediate format to be stored in the storage. 

Since `State` conforms to `Codable`, it is also easy to choose which values are going to be stored in the persistence via the `CodingKey` enumeration defined on the state:

```swift
// LogIn+State.swift

extension LogInComponent {

    struct State : AnyState {
        enum PersistenceKeys : CodingKey {
            case email
        }
    
        var email : String = ""
        var password : String = "" 
        var shouldShowWelcomeMessage : Bool = false
    }
    
}
```

`PersistenceKeys` define the shape of persisted data—the `email` property will be persisted, but all other fields will not be persisted.

###  8.5. <a name='IdentifiedReferencesviaRefandRefCollection'></a>Identified References via  `@Ref` and `@RefCollection`

The `@Ref` and `@RefCollection` wrappers are used when declaring properties of the state for a `Store` instance. `@Ref` property wrapper is used for single objects, `@RefCollection` property wrapper is used for collection of objects.  

Sometimes data managed by a component might be mutated by child components.  `@Ref` and `@RefCollection` property wrappers are used to keep interactive chunks of data synced between different components (most importantly, between children components of the same parent component).

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

struct Exhibition : Component {

    let specimenA : SpecimenComponent
    let specimenB : SpecimenComponent

    @ObservedObject var store = PlainStore<State>()

    init() {
        self.specimenA = SpecimenComponent(specimen: store.state.$specimen)
        self.specimenB = SpecimenComponent(specimen: store.state.$specimen)
    }
}

// Exhibition+State.swift

extension Exhibition {

    struct State {
        @Ref var specimen = SpecimenModel(id: "MY-MODEL-ID", "Funny Circle")
    }

}

// Exhibition+View.swift

extension Exhibition : View {

    var body : some View {
        VStack {
            Text("Welcome, we can show a '\(store.state.specimen.name)' today")
            specimenA
            specimenB
        }
    }

}
```

Note how we pass `store.state.$specimen` into the children components instead of the value itself. The `$` notation allows us to obtain the `Referred` instance—a super-lightweight object that can be passed around and assigned to other `Ref` instances via the same `$` notation. 

It's time to define the underlying `SpecimenComponent`:

```swift
// Specimen.swift

struct SpecimenComponent : Component {

    @ObservedObject var store = PlainStore<State>()

    init(specimen : Referred<SpecimenModel>) {
        self.store.state.$specimen = specimen
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
            TextField("Name", text: store.binding.specimen.name)
        }
    }

}
```

When we pass a `$specimen` to the constructor of our children components, we pass the `Referred` instance, which can be assigned to another `@Ref` object via `store.state.$specimen = specimen`. The `Referred` instance only carries the information necessary for the underlying `@Ref` property wrapper to hook up to the value by its identifier. 

Now, when one of the text fields is updated in one of the components, all other values marked by `@Ref` will also be automatically updated, which ensures full synchronisation of the value across different components. 

`@RefComponent` works in a similar manner, but instead holds an array of data that can be also passed around:

```swift
// Exhibition.swift

struct Exhibition : Component {

    let specimenA : SpecimenComponent
    let specimenB : SpecimenComponent

    @ObservedObject var store = PlainStore<State>()

    init() {
        self.specimenA = SpecimenComponent(specimen: store.state.$specimens[0])
        self.specimenB = SpecimenComponent(specimen: store.state.$specimens[1])
    }
}

// Exhibition+State.swift

extension Exhibition {

    struct State {
        @RefCollection var specimens = [
            SpecimenModel(id: "MY-MODEL-ID-FIRST", "Funny Circle"),
            SpecimenModel(id: "MY-MODEL-ID-SECOND", "Heavy Box")
        ]
    }

}

// Exhibition+View.swift

extension Exhibition : RoutableView {

    var body : some View {
        RouterView()
    }

    var routableBody : some View {
        VStack {
            Text("Welcome, we can show '\(store.state.specimens[0].name)' and '\(store.state.specimens[1].name)' today")
            specimenA
            specimenB
        }
    }

}
```

Updating a particular specimen would update only the appropriate chunk text and leave the other one be.

###  8.6. <a name='DataManagement'></a>Data Management

On the one hand, Compose favours decentralised data storage: each component has its own store (one or many), that holds the component's state validates it and performs actions with the services. 

On the other hand, services can also have their own stores, making data available globally to all components. This enables developers to recreate familiar Redux-like storage solutions, where services encapsulate stores and actions on the stores, and views rely on the services' stores to display reactive constantly changing data.

Which way data is stored in a particular application is never specified by Compose itself—the pattern is chosen by the developer.


