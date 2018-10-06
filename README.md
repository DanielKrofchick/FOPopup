# FOPopup

FOPopup is a simple sliding panel control. It currently only works from the bottom.

Initialize an `FOPopup` with a `UIViewController` that conforms to the  `FOPopupProtocol`.
```
let content = UIViewController() 
let popup = FOPopup(content: content)
```
Then present the controller.
```
viewController.present(content, animated: true, completion: nil)
```
In the view controller, assign values for:
```
anchorPoints
startAnchorPoint
```

## Example

Try the example project in the `FOPopup_Example` target.

## Installation

FOPopup is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FOPopup', :git => 'https://github.com/DanielKrofchick/FOPopup.git'
```

## Author

Daniel Krofchick, krofchick@gmail.com

## License

FOPopup is available under the MIT license. See the LICENSE file for more info.
