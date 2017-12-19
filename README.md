# MIIScrollableViews
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](/LICENSE)

Easily handle UIViews inside horizontal UIScrollView

![MIIScrollableViews Demo](https://github.com/mii-chan/MIIScrollableViews/blob/media/demo.gif)

## About
`MIIScrollableViews` makes it much easier to manage and add gestures to UIViews inside UIScrollView. 

## Requirements
* iOS 8.0+
* Xcode 9.0
* Swift 4

## Installation
### Carthage
```
github "mii-chan/MIIScrollableViews"
```
## Usage
### Array-Like Operation
Automatically expand `contentSize` and arrange the views added to `UIScrollView`

#### Access
```swift
// Get a view
_ = self.scrollableViews[0]

// Set a view
self.scrollableViews[0] = view1

// Get all views
_ = self.scrollableViews.all

// The number of views
self.scrollableViews.count

// Get the index
self.scrollableViews.index(of: view2)

// Also
self.scrollableViews.isEmpty,
self.scrollableViews.first,
self.scrollableViews.last...
```

#### Add
```swift
// Add a view to the end
self.scrollableViews.append(view)

// Add views to the end
self.scrollableViews.append(contentsOf: views)

// Add a view in the middle
self.scrollableViews.insert(view, at: 1)

// Add views in the middle
self.scrollableViews.insert(contentsOf: views, at: 0)
```

After addition, `setContentOffset` is automatically invoked to display the view added. If you fix the view displayed, set `shouldMoveWhenAdding` flag to `false`

#### Remove
```swift
// Remove the last view
self.scrollableViews.removeLast()

// Remove a view at the position
self.scrollableViews.remove(at: 1)

// Remove all views
self.scrollableViews.removeAll()
```

### Move to the Specific View
Automatically invoke `setContentOffset` to display the view

```swift
self.scrollableViews.move(to: view)
```

### Delegate Methods
The methods declared by `MIIScrollableViewsDelegate` protocol

```swift
// Setup MIIScrollableViewsDelegate
self.scrollableViews.svDelegate = self
```

#### Required

Method | Description | Parameters
---|:---:|---
didViewsCountChange | Tells the delegate when the number of views changed | `index`: The number of the views
didViewDisplayedChange | Tells the delegate when a view displayed in the scroll view changed | `viewDisplayed`: The view object displayed in the scroll view <br><br> `index`: The index of the view object

#### Optional
Support a wide variety of gestures (`Tap`, `Double Tap`, `Pan`, `Pinch`, `Long Press`).

##### Parameters

Name | Description |
---|:---:|
view | The view touched
index | The index of the view touched
gesture | The sender

Method | Description |
---|:---:|
didTap | Tells the delegate when the user tapped a view in the scroll view
didDoubleTap | Tells the delegate when the user tapped a view in the scroll view twice
didPan | Tells the delegate when the user dragged a view in the scroll view
didPinch | Tells the delegate when the user pinched in or out a view in the scroll view 
didLongPress | Tells the delegate when the user pressed and held a view in the scroll view 

Add or remove the gestures by changing the value of `shouldAdd<GestureName>Gesture` flags. By default, set to `false`

```swift
// Add `Tap` gesture to the views
self.scrollableViews.shouldAddTapGesture = true

// Remove `Long Press` gesture from the views
self.scrollableViews.shouldAddLongPressGesture = false

// Add all gestures
self.scrollableViews.addAllGesturesToViews()

// Remove all gestures
self.scrollableViews.removeAllGesturesFromViews()
```

## Demo
This library includes Demo project to see how it works.

**Photo Credit** <br>
All materials are downloaded from [PAKUTASO](https://www.pakutaso.com/). If you continue to use the photos, you need to download them yourself from the Official Website or agree to the [Terms of Use](https://www.pakutaso.com/userpolicy.html). If you do not agree, you are not permitted to use the photos.

## License
MIT License, see [LICENSE](/LICENSE).