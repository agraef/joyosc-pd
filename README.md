# joyosc.pd: gamepad to OSC interface for Pd

The joyosc.pd patch lets you interface to your game controllers via Pd's built-in OSC ([Open Sound Control][]) support, using either [joyosc][] by Dan Wilcox or hexler's [TouchOSC][]. Unlike the various available hid externals for Pd, this should work with most modern game controllers (as long as your OS supports them) across all major platforms (Linux, Mac, Windows) and requires very little setup. Also, using OSC has the advantage that the interface can be customized more easily at the OSC level, and that the Pd patch and the gamepad to OSC conversion software can be run on different computers on the same local network. E.g., you might want to run Pd on your desktop PC in your studio, while having your game controller connected to some laptop computer, or even a mobile Android or iOS device.

## Overview

Besides this README file, the package includes:

- joyosc.pd, the main patch
- j_controller.pd, a helper abstraction from Dan Wilcox' [joyosc][] package
- j_controller-help.pd, help patch for the abstraction
- joyosc.tosc, a version of hexler's gamepad example which has the OSC messages configured to match the output of the joyosc program
- radar.pd_lua, a pd-lua external which provides the joystick visualization in the main patch
- spooky.pd, a little sound design example which can be used alongside the main patch

For the gamepad to OSC conversion you'll need one of these:

- Dan Wilcox' [joyosc][] program (open-source, works on Linux, Mac, and Windows)
- hexler's [TouchOSC][] (commercial software, but the desktop app can be downloaded for free and has no limitations)

I recommend joyosc, because it's open-source, seems to have better controller support on Linux (in particular with Xbox-compatible controllers), enables you to switch between multiple joysticks, and offers better accuracy of the joystick position values. The downside is that at present there aren't any ready-to-use binary packages, so you will have to compile joyosc yourself.

As an alternative, you can use TouchOSC with the provided joyosc.tosc template, which works on Linux/Mac/Windows as well as Android and iOS devices. This has the advantage that it also works on mobile devices and you can just use the template itself as a virtual gamepad. Or you can hook it up to your controller and have TouchOSC do the OSC conversion.

**NOTE:** The patch uses a special radar GUI object written in Lua for visualization purposes, so you'll need to have [pd-lua][] installed.

## Setup: joyosc

Install [joyosc][] on the computer that you want to run the patch on. Make sure that your gamepad is connected, and invoke the program as `joyosc` in a terminal window. **NOTE:** If you're running joyosc on a Mac or Windows, use `joyosc -w` instead, see the [Tips and Tricks](#tips-and-tricks) section below for details.

## Setup: TouchOSC

The easiest way to go about this is to run the [TouchOSC][] desktop application on the same computer as the joyosc.pd patch. Then you can just run the joyosc.tosc template in TouchOSC and set up an [OSC connection](https://hexler.net/touchosc/manual/connections-osc) using localhost as the host IP address and 8880 as the send port. (The joyosc.pd patch currently doesn't send back OSC data, so the receive port can be left empty.)

If you're using a hardware controller, you can set it up in the [Gamepad connections](https://hexler.net/touchosc/manual/connections-gamepad). Once you have done that, press the ▶ icon in the [toolbar](https://hexler.net/touchosc/manual/editor-interface#toolbar) and you're off to the races. If you wiggle the controls on your gamepad, the TouchOSC display should visualize your inputs, and OSC messages will be sent to the joyosc.pd patch.

**NOTE:** Another useful utility by hexler is [Protokol][] which can be used to check and monitor your OSC and Gamepad connections. This is available as freeware on hexler's website and also runs on Linux, Mac, and Windows as well as Android and iOS devices.

## Usage

Having set up the gamepad to OSC conversion with either joyosc or TouchOSC as explained above, you should be ready to go now. Launch the joyosc.pd patch and turn on the `poll` toggle in the upper left corner to have the patch receive OSC messages. Wiggle the controls on your gamepad (or in TouchOSC) to test that it works. If it doesn't, double-check that the `poll` toggle is turned on. When using TouchOSC, make sure that you have entered the correct OSC host and port information, that both the OSC and gamepad connections are actually enabled, and that TouchOSC is in run mode (if you can see TouchOSC's toolbar, press the ▶ icon to enter run mode).

There are various configuration options for the j_controller.pd abstraction which may become useful if you'd like to tailor joyosc.pd for your own applications. Please check the included j_controller-help.pd patch or the `config` subpatch in joyosc.pd for details. In particular, the `config` subpatch lets you switch between different controllers when using the joyosc program, please see the [Tips and Tricks](#tips-and-tricks) section below for details.

## Example

Note that the joyosc.pd patch only visualizes your controller input. To actually do something with the provided values, you can set up the following global receivers in your target patch which does the processing:

- `leftx`, `lefty`, `rightx`, `righty`: left and right joystick position values, usually in the range -32768 to 32767.
- `leftstick`, `rightstick`: left and right joystick button presses (0 or 1)
- `a`, `b`, `x`, `y` (A/B/X/Y); `back`, `start`, `guide` (SELECT/START/HOME); `lefttrigger`, `righttrigger` (LT/RT); `leftshoulder`, `rightshoulder` (LB/RB); `dpleft`, `dpright`, `dpup`, `dpdown` (d-pad): various button presses (0 or 1).
- `leftz`, `rightz`: alternative axis values for the LT/RT buttons if enabled (see the [Tips and Tricks](#tips-and-tricks) section below for details).

**NOTE:** While the receiver names correspond to the button names of the SDL2 library, the names in parentheses indicate the button labels in the TouchOSC template (these also correspond to what's printed on many real gamepads).

The included spooky.pd patch (aptly named as I'm writing this shortly after Halloween) illustrates how these controller values might be put to good use in a little sound-generating patch. You can run this alongside the joyosc.pd patch. Use the joystick y axes for controlling the filter parameters, the d-pad (up/down) for controlling volume, and the A, B, and X buttons for toggling various features of the patch.

## Tips and Tricks

Here is a list of useful features you may want to know about, as well as some tips to make joyosc and TouchOSC work with joyosc.pd on various systems.

### joyosc

- You can run joyosc as `joyosc -e` to have it print the gamepad events it receives.

- On **Mac** and **Windows**, always run joyosc as `joyosc -w` (or `joyosc -ew` to also print controller events). This pops up a little main window which makes sure that joyosc can receive game controller input on those platforms. Closing the main window also terminates the program.

- You can also invoke joyosc as `joyosc -t` (adding `-e` and `-w` options as needed) to have the left and right trigger buttons report analog axis values (`leftz` and `rightz`) instead of digital on/off values (`lefttrigger`, `righttrigger`). This gives you two more axes to feed your patch with additional control values. Note that joyosc can only generate either button or axes values, not both at the same time. (The TouchOSC template generates both, if you need this.)

- joyosc sends out OSC messages to localhost and port 8880 by default, which is also the port that joyosc.pd listens on. You can change this with joyosc's `-p` option if needed, but then you'll also have to change the port number in the `oscreceive` subpatch of joyosc.pd accordingly (and your TouchOSC connection if you're using this as well).
- If you wish, you can run joyosc on a separate computer in your local network. To do this, you will have to figure out the IP address of the computer on which you run the joyosc.pd patch. This is most easily done using TouchOSC, please check the corresponding tip in the TouchOSC section below. You can also use whatever command your OS provides (e.g., `ip a` or `ifconfig` on Linux). Once you know the address (usually something like 192.168.x.y), you can invoke joyosc as `joyosc -i 192.168.x.y` to have it connect to the host computer on which Pd is running.
- If you have multiple game controllers connected, joyosc will send received data to different OSC prefixes named `/gc0`, `/gc1 `, etc. While joyosc.pd can only work with a single controller at any one time, you can switch between controllers with the `gc` numbox in the main patch. The default `gc` value is zero which connects to the first gamepad, but you can enter the desired controller number (ranging from 0 to 9) in the numbox to switch to a different controller.

### TouchOSC

- In some configurations, the joystick axes may show non-zero values if the sticks are in their resting positions. (I've never seen this with joyosc, but TouchOSC suffers from this.) The easiest way to deal with this situation is to increase the deadzone of joyosc.pd by turning on the corresponding toggle in the main patch. If that doesn't work, you can also calibrate joyosc.pd to make it report the center position as (0,0). To do this, make sure that both joysticks are in their resting positions and press the `calibrate` button. You can also revert the patch to the raw stick positions as reported in the OSC data by pressing the `reset` button.
- The left and right trigger buttons also report analog axis values (`leftz` and `rightz`) in addition to the button presses (`lefttrigger`, `righttrigger`). This gives you two more axes if your patch requires additional control values. Note that in contrast to joyosc, which can only report *either* button presses *or* axis values for the LT and RT controls, in the TouchOSC template both are enabled by default. If only one of these is needed/wanted, you can disable the unwanted OSC messages by configuring the LT and RT elements in the template accordingly.
- If you wish, you can run TouchOSC on a secondary computer or a tablet in your local network. To do this, you will have to figure out the IP address of the computer on which you run the joyosc.pd patch.  This is most easily done by first running TouchOSC on the *host* computer (the one on which Pd is running) , by opening the [OSC connections](https://hexler.net/touchosc/manual/connections-osc) dialog and clicking on the 🛈 (network information) button in the dialog. This will show you the available network addresses. There may be more than one address if the host computer has multiple network interfaces (like, e.g., a hardwired Ethernet connection and a wireless WiFi connection), in which case you need to pick a connection that matches one of the network addresses on the other computer. In any case, the address will usually be something like 192.168.x.y, indicating a local network address. Enter that address as the host address in the [OSC connections](https://hexler.net/touchosc/manual/connections-osc) dialog on the *secondary* computer or tablet, along with the send port 8880, and you should be set.
- If you have multiple game controllers connected, TouchOSC will always send their data to the `/gc0` OSC prefix (see [joyosc](#joyosc) above). So you can use all connected controllers at the same time, but they will just look like a single controller to joyosc.pd.
- **Linux** users: At the time of this writing, TouchOSC seems to have trouble with some types of controllers on Linux. In particular, while modern Xbox controllers are recognized (which generally require medusalix' [xone][] driver to work), they don't seem to report any input data in TouchOSC. This seems to be a defect in the Linux version of TouchOSC only (it works fine on Mac and Windows). Thus, if you run into this, just use joyosc instead.

[Open Sound Control]: https://en.wikipedia.org/wiki/Open_Sound_Control
[pd-lua]: https://agraef.github.io/pd-lua/
[joyosc]: https://github.com/danomatika/joyosc
[TouchOSC]: https://hexler.net/touchosc
[Protokol]: https://hexler.net/protokol
[xone]: https://github.com/medusalix/xone