#set document(title: "Strudel + SuperDirt Setup")
#set page(paper: "a4", margin: 2.2cm)
#set text(size: 10.5pt)
#set heading(numbering: "1.")
#show raw.where(block: true): block.with(
  fill: luma(245), inset: 8pt, radius: 3pt, width: 100%,
)

#align(center)[
  #text(size: 18pt, weight: "bold")[Strudel + SuperDirt Setup]
  #v(-4pt)
  #text(size: 10pt, fill: luma(90))[macOS · first-time installation and daily start]
]

= How it works

Strudel normally does two jobs in the browser: (1) computing which events play when, and (2) making the sound. With this setup, job (1) stays in the browser, while job (2) is handed to *SuperCollider/SuperDirt*, a native audio engine that handles many overlapping samples much more robustly.

The browser cannot send OSC messages itself, so a small bridge program (`@strudel/osc`) runs in Terminal and forwards Strudel's events to SuperDirt:

#align(center)[Strudel (browser) #sym.arrow.r bridge in Terminal (port 8080) #sym.arrow.r SuperDirt (port 57120)]

= First-time installation

== Install SuperCollider
Download from #link("https://supercollider.github.io")[supercollider.github.io] and move it to Applications, or:
```sh
brew install --cask supercollider
```

== Install SuperDirt
Open SuperCollider, paste the line below, put the cursor on it and press *Cmd+Enter*:
```
Quarks.install("SuperDirt");
```
Wait until it finishes (it also downloads the default samples), then run *Language → Recompile Class Library*.

== Create the startup file
In SuperCollider, create a new document (*Cmd+N*), paste the block below and save it, e.g. as `superdirt-start.scd`:
```
(
s.options.numInputBusChannels = 0;   // no audio input (see 2.7)
s.options.numBuffers = 1024 * 256;   // room for many samples
s.options.memSize = 8192 * 32;       // more realtime memory
s.options.maxNodes = 1024 * 32;      // many overlapping voices
s.waitForBoot {
  ~dirt = SuperDirt(2, s);
  ~dirt.loadSoundFiles;
  // ~dirt.loadSoundFiles("/Users/YOU/samples/*");  // own samples, see 4.
  ~dirt.start(57120, 0 ! 12);
};
)
```
To run it: click anywhere inside the outer parentheses and press *Cmd+Enter*. Success looks like this in the post window:
```
SuperDirt: listening on port 57120
```

== Install Node.js
```sh
brew install node
node -v    # should print a version number
```

== Start the bridge
```sh
npx @strudel/osc
```
The first time, answer `y` to the install question. It is running when it shows:
```
[Sending OSC] 127.0.0.1:57120
[Listening WS] ws://localhost:8080
```

== Test in Strudel
On #link("https://strudel.cc")[strudel.cc], replace the editor content with the lines below and press play:
```js
$: s("bd*4")
all(osc)
```
You should hear a kick, now coming from SuperCollider.

== Issues we ran into

*Output device is fixed at boot.* SuperCollider uses whatever output is selected in the macOS sound menu _at the moment the server boots_. Unlike the browser, it does not follow later changes. Select the headphones first, then boot. To switch outputs while running: `s.quit;` and run the startup block again.

*Bluetooth headphones: sample-rate error.* With Bluetooth headphones (e.g. Momentum 4), macOS may use the headset microphone as input. It runs at 16 kHz while the output runs at 44.1 kHz, and the server fails to boot with:
```
WARNING: Input sample rate is 16000, but output is 44100.
ERROR: Setting sample rate failed.
could not initialize audio.
```
Fix: the line `s.options.numInputBusChannels = 0;` in the startup file switches audio input off (MIDI from controller or piano is unaffected).

*Bluetooth headphones: scratchy, bad sound.* While the headset microphone is in use, macOS switches the headphones into low-quality "headset mode" (phone-call quality, mono). Fix: in *System Settings → Sound → Input*, select *MacBook Air-Mikrofon*, then `s.quit;` and boot again. Quick check: other apps (Spotify, YouTube) also sound bad while this mode is active.

*Harmless messages.* "SC3-Plugins not found" and "could not load some synths … sc3plugins are necessary" only affect a few extra synths, not sample playback. A few `late …` lines right after booting can be ignored.

= Daily start

+ In macOS, select the output (headphones or speakers) and make sure the input is *MacBook Air-Mikrofon*.
+ Open SuperCollider, open `superdirt-start.scd`, click inside the block, press *Cmd+Enter*. Wait for `SuperDirt: listening on port 57120`.
+ In Terminal: `npx @strudel/osc` (no install question anymore). Leave the window open.
+ Open strudel.cc and make sure the code contains `all(osc)`.

To stop or restart: stop playback in Strudel, then in SuperCollider press *Cmd+.* and run `s.quit;`. The bridge and the Strudel tab can stay open; they reconnect on their own.

*Optional:* paste the startup block into *File → Open startup file* so SuperDirt boots automatically when SuperCollider opens. Then the output device must be chosen _before_ opening SuperCollider.

= Own samples

SuperDirt plays from local folders; Strudel's online sample banks are not available. Put each sound in its own subfolder, e.g. `samples/snowbell/`, which becomes `s("snowbell")`. To get the folder path: in Finder, right-click the samples folder while holding *Option* and choose "Copy … as Pathname". Then uncomment the `loadSoundFiles` line in the startup file and paste the path, keeping the `/*` at the end.
