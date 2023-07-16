# IMProgressHUD

![Pod Version](https://img.shields.io/cocoapods/v/IMProgressHUD.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/IMProgressHUD.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/IMProgressHUD.svg?style=flat)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-compatible-green.svg?style=flat)](https://cocoapods.org)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

`IMProgressHUD` is a clean and easy-to-use HUD meant to display the progress of an ongoing task on iOS.

<img src="https://github.com/immortal-it/IMProgressHUD/blob/main/Gifs/demo002.png">
<img src="https://github.com/immortal-it/IMProgressHUD/blob/main/Gifs/demo001.gif">

## Requirements

- iOS 11.0+
- Xcode 11+
- Swift 5.0+

## Installation

### From CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects, which automates and simplifies the process of using 3rd-party libraries like `IMProgressHUD` in your projects. First, add the following line to your [Podfile](http://guides.cocoapods.org/using/using-cocoapods.html):

```ruby
pod 'IMProgressHUD'
```

If you want to use the latest features of `IMProgressHUD` use normal external source dependencies.

```ruby
pod 'IMProgressHUD', :git => 'https://github.com/immortal-it/IMProgressHUD.git'
```

This pulls from the `main` branch directly.

Second, install `IMProgressHUD` into your project:

```ruby
pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate IMProgressHUD into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "immortal-it/IMProgressHUD" ~> 1.0.0
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but IMProgressHUD does support its use on supported platforms.

Once you have your Swift package set up, adding IMProgressHUD as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/immortal-it/IMProgressHUD", .upToNextMajor(from: "1.0.0"))
]
```

### Manually

* Drag the `immortal-it/IMProgressHUD` folder into your project.

## Usage

(see sample Xcode project in `Demo`)

`IMProgressHUD` is created as a singleton.

**Use `IMProgressHUD` wisely! Only use it if you absolutely need to perform a task before taking the user forward. Bad use case examples: pull to refresh, infinite scrolling, sending message.**

Using `IMProgressHUD` in your app will usually look as simple as this (using Grand Central Dispatch):

```
IMProgressHUD.show()
DispatchQueue.global().async {
  DispatchQueue.main.async {
    IMProgressHUD.hide()
  }
}
```

### Showing the HUD

- #### Showing the Toast
```swift
showToast(_ message: String)
showToast(message: String, location: Location) -> IMProgressHUD
```
- #### Showing the Status
```swift
show(message: String? = nil, image: UIImage? = nil)
showSuccess(_ message: String? = nil)
showFail(_ message: String? = nil)
```

- #### Showing the Progress Indicator
```swift
showProgress(_ progress: CGFloat, indicatorType: ProgressIndicatorType = .default, message: String? = nil)
```

### Dismissing the HUD

The HUD can be dismissed using:

```swift
hide()
hideAfterDelay(_ delay: TimeInterval)
```

## Customization

`IMProgressHUD` can be customized via the `Configuration`:

## License

`IMProgressHUD` is distributed under the terms and conditions of the [MIT license](https://github.com/immortal-it/IMProgressHUD/LICENSE).
