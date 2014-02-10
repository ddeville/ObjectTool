This is a very simple GUI application adding a UI around `otool`.

I am trying to learn [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) and with this project I will attempt to replace the `NSOperation` architecture I usually use with one based on RAC.

The master branch will contain my original version based on a concurrent `NSOperation` wrapping an `NSTask` running `otool`. The idea is to refactor all this to use RAC.

