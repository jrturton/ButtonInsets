ButtonInsets
============

Demo project for Reactive Cocoa and editing button insets. 

Image, content and title edge insets are fiddly to change, hard to understand and poorly documented. This project is an iPad app to allow easy visual editing of the insets.

Whilst writing it I decided it would be a nice and simple introduction (for me!) to Reactive Cocoa, at least the UI binding parts of it.

To enable Reactive Cocoa, you need to install it via Cocoapods to the project (the podfile is included) then uncomment the following line in the prefix.pch file: 

    // Comment or uncomment this line to use the RAC functionality.
    //#define USE_RAC

The non-reactive cocoa code is still in the project; you can see the difference by examining which code is included in the various `#ifdef` blocks.

If you don't want to use Reactive Cocoa or cocoapods then you'll need to amend the project to remove all of the podification. Though you really ought to be using Cocapods!
