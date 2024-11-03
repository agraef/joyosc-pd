# joyosc.pd: gamepad to OSC interface for Pd

The main patch, joyosc.pd, will let you interface to your game controllers via Pd's built-in OSC support, using either [joyosc][] by Dan Wilcox or hexler's [TouchOSC][]. Unlike the various available hid externals for Pd, this works across all major platforms (Linux, Mac, Windows) and requires very little setup.

**NOTE:** The patch uses a special radar GUI object written in Lua for visualization purposes, so you'll need to have [pd-lua][] installed.

The package includes:

- joyosc.pd, the main patch
- j_controller.pd, a helper abstraction from Dan Wilcox' [joyosc][] package
- j_controller-help.pd, help patch for the abstraction
- joyosc.tosc, a version of hexler's gamepad example which has the OSC messages configured to match the output of the joyosc program
- radar.pd_lua, a pd-lua external which provides the joystick visualization in the main patch
- spooky.pd, a little sound design example which can be used alongside the main patch

For the gamepad to OSC conversion you'll need one of these:

- Dan Wilcox' [joyosc][] program (open-source, works on Linux and Mac)
- hexler's [TouchOSC][] (commercial software, but the desktop app can be downloaded for free and has no limitations)

I recommend joyosc on Linux, because it seems to have better controller support there (in particular with Xbox-compatible controllers), and offers better accuracy of the joystick position values. joyosc can also be used on the Mac if you have Homebrew installed and compile it yourself.

As an alternative, you can use TouchOSC with the provided joyosc.tosc template, which works on Linux/Mac/Windows as well as Android and iOS devices. This has the advantage that you can just use the template itself as a virtual gamepad. Or you can hook it up to your controller and have TouchOSC do the OSC conversion.

## Setup: joyosc

Install [joyosc][] on the computer that you want to run the patch on. Make sure that your gamepad is connected, and invoke the program as `joyosc` in a terminal window.

**NOTES:**

- You can run joyosc as `joyosc -e` to have it print the gamepad events it receives.
- On the Mac, run joyosc as `joyosc -w`. This pops up a little main window which makes sure that joyosc can receive game controller input. Closing the main window also terminates the program.
- joyosc sends out OSC messages to localhost and port 8880 by default, which is also the port that joyosc.pd listens on. You can change this with joyosc's `-p` option if needed, but then you'll also have to change the port number in the `oscreceive` subpatch of joyosc.pd accordingly.

## Setup: TouchOSC

The easiest way to go about this is to run the [TouchOSC][] desktop application on the same computer as the joyosc.pd patch. Then you can just run the joyosc.tosc template in TouchOSC and set up an [OSC connection](https://hexler.net/touchosc/manual/connections-osc) using localhost as the host IP address and 8880 as the send port. (The joyosc.pd patch currently doesn't send back OSC data, so the receive port can be left empty.)

If you're using a hardware controller, you can set it up in the [Gamepad connections](https://hexler.net/touchosc/manual/connections-gamepad). Once you have done that, press the "run" icon in the [toolbar](https://hexler.net/touchosc/manual/editor-interface#toolbar) and you're off to the races. If you wiggle the controls on your gamepad, the TouchOSC display should visualize your inputs, and OSC messages will be sent to the joyosc.pd patch.

TouchOSC offers many other possibilities. E.g., you could run TouchOSC on a secondary computer or a tablet in your local network. Please check the TouchOSC manual for details. Another useful utility by hexler is [Protokol][] which can be used to check and monitor your OSC and Gampad connections. This is available as freeware on hexler's website and also runs on Linux/Mac/Windows as well as Android and iOS devices.

## Usage

Having set up the gamepad to OSC conversion with either joyosc or TouchOSC as explained above, you should be ready to go now. Launch the joyosc.pd patch and turn on the `poll` toggle in the upper left corner to have the patch receive OSC messages. Wiggle the controls on your gamepad (or in TouchOSC) to test that it works. If it doesn't, double-check that the `poll` toggle is turned on. When using TouchOSC, make sure that you have entered the correct OSC host and port information, that both the OSC and gamepad connections are actually enabled, and that TouchOSC is in run mode (if you can see TouchOSC's toolbar, press the little play a.k.a. run icon to enter run mode).

In some configurations, the joystick axes may show non-zero values if the sticks are in their resting positions. (In particular, this seems to be the case when using TouchOSC.) To get rid of this, make sure that both joysticks are in their resting positions and press the `calibrate` button. You can also revert the patch to the raw stick positions as reported in the OSC data by pressing the `reset` button.

There are various configuration options for the j_controller.pd abstraction which may become useful if you'd like to tailor joyosc.pd for your own applications. Please check the included j_controller-help.pd patch for details.

## Example

Note that the joyosc.pd patch only visualizes your controller input. To actually do something with the provided values, you can set up the following global receivers in your target patch which does the processing:

- `leftx`, `lefty`, `rightx`, `righty`: left and right joystick position values, usually in the range -32768 to 32767.
- `leftstick`, `rightstick`: left and right joystick button presses (0 or 1)
- `a`, `b`, `x`, `y` (A/B/X/Y); `back`, `start`, `guide` (SELECT/START/HOME); `lefttrigger`, `righttrigger` (LT/RT); `leftshoulder`, `rightshoulder` (LB/RB); `dpleft`, `dpright`, `dpup`, `dpdown` (d-pad): various button presses (0 or 1). **NB:** The names in parentheses indicate the button labels from the TouchOSC template.

The included spooky.pd patch (aptly named as I'm writing this shortly after Halloween) illustrates how these controller values might be put to good use in a little sound-generating patch. You can run this alongside the joyosc.pd patch. Use the joystick y axes for controlling the filter parameters, the d-pad (up/down) for controlling volume, and the A, B, and X buttons for toggling various features of the patch.

[pd-lua]: https://agraef.github.io/pd-lua/
[joyosc]: https://github.com/danomatika/joyosc
[TouchOSC]: https://hexler.net/touchosc
[Protokol]: https://hexler.net/protokol