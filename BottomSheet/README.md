#  BottomSheet Static Library

This is for UIKit, and is only needed if you gotta support pre-iOS15.  iOS 15 has 'detents' for view controllers.

However, this works sell enough.

## Usage

Take a look at the 'BottomSheetExample' target.  The TL:DR is:

* Link your project to this 'BottomSheet' static library
* In your presenting view controller (the one that wants to show a child bottom shset), create an instance of BottomSheetTransitionController, and hold on to a reference (easiest way is to make it a property of the vc)
* Create a child VC.  Set its transitioningDelegate to the BottomSheetTransitionController.transitioningDelegate.  Set the child vc modalPresentationStyle to .custom
* Add a PanAxisGestureRecognizer (set to vertical) to the child vc view.  Add a target, and in that target, use whatever method you like to call back into the presenter (I used protocol-delegate, but use Rx, Combine, NotificationCenter, escaping closure, whatever you like, just don't create a retain cycle)
* In the presenter's callback for the pan gesture, it needs to call the transitionController''s handlePan method.  
* The default height for the bottom sheet is found in the BottomSheetTransitionController.PresentationControler.Constants enum, but you can set the height to whatever you want in the parent by setting transitionController.dialogHeight to something else.  Do this before presenting the bottom sheet, of course.


That's about it.  It was a fun little project, but has limited lifespan.  Most shops will probably drop support for iOS 14 when iOS 17 comes out, I reckon.


