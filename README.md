# Compose

Compose is an opinionated architecture framework intended to build applications for iOS and macOS. Compose is built on top of Combine and SwiftUI.

- 🌴 Component tree
- 🚦 Event-driven communication between components
- 🚏 Easy to use routing
- 🧨 Reactive store
- 🏛 Predicable file structure
- 👨🏽‍💻 UI elements to implement navigation from scratch

_Compose is still a work in progress. The framework is still alpha—feature set may change, variable and method names may change too._

## Supported Platforms

- iOS 13+
- macOS 10.15+

## Installation

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

## Getting Started

The following project structure is the most optimal to use Compose:

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
        - Auth+State.swift <-- contains supplementary structures, State and Validations definitions 
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

## Emitters 

Emitters emit values which can be observed by subscribing to an emitter when they emit a value. Emitter is a basic building block of Compose which enables building event-driven communication within the component or between different components with a particular subtree.

> ❗️ Compose permits subscriptions to emitters within a component only: a component can subscribe to emitters defined by the component itself, or by any child component included into the component. It is not possible to subscribe to events in parent components!

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

Value emitters, as the name implies, carry value with them:

```swift
// Define an emitter that carries a certain value.
let printMessage = Emitter<String>()

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

### Emitters Operators

There are several operators defined to add subscribers to any emitters.

- `+=` is used when the subscription closure must be executed any time an emitter emits a value or a signal.
- `!+=` is used when the subscription closure must be executed **only once** and then never executed again.
- `++=` is used when the subscription closure must be executed any time an emitter emits a value or a signal and immediately with the last emitted value, if presented.
- `~+=` is used when the subscription closure must be executed with the new value and the previous emitted value, which allows computing diffing between two emitted values. 

## Components

Compose is built with components tree and event-driven communication between them. Compose heavily utilises structures, keypaths, SwiftUI, and Combine to achieve the desired result and abstract complex logic from the user. 

### `Component`

A basic building block for presenting content. A component is usually a single screen of content.  Components define their presentation using SwiftUI `View`. 

`Component` is a protocol which doesn't conform to any other protocol. 

Each component must be a `struct` and must conform to the `Component` protocol. Usually component body contains emitters, stores, and subcomponents.

```swift
// Auth.swift
struct AuthComponent : Component {

    let logIn = SignalEmitter()

}
```

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

---

#### Preinstalled Lifecycle Emitters

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

---

### `RouterComponent`

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

---

#### `Router`

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

---

#### `RouterView`

`RouterView` doesn't expose any configuration because its purpose is to present the children content. It is 

---

#### `RoutableView`

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

---

### `StartupComponent`

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

---

### `LazyComponent`

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

---

#### Lifecycle Emitters

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

---

### `DynamicComponent`

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

---

#### Lifecycle Emitters

`DynamicComponent` provides two lifecycle emitters:

- `didCreate` is invoked as soon as dynamic component was created.
- `didDestroy` is invoked as soon as dynamic component was destroyed.

Lifecycle emitters for `DynamicComponent` instances are used much more rarely because the developer usually controls the lifecycle of dynamic components manually. 

