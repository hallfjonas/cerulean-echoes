// LC XL 3 DAW-mode device test (docs/reference/lcxl3-daw-mode.md): switches every connected Launch Control XL 3 into
// DAW mode, steps through four phases and tells the player on the LC's screen what to press. Every MIDI message from
// every input is printed with its port, one line each; read the log afterwards.
// Run (the player may keep running; it does not hear the LC on the DAW pages):
//   /Applications/SuperCollider.app/Contents/MacOS/sclang sc/tools/lcxl3-daw-test.scd | tee lcxl3-daw-test.log
// Environment: CE_DAW_TEST_PHASE  seconds per phase (default 40)
//              CE_DAW_TEST_DRY=1  send nothing to the devices (checks that the script runs)
// Phases (screen line 1):
//   1/4 custom    DAW mode on + Custom Mode 1 (ch 7 CC 30 = 6): knobs on MIDI Out? Record, Play, Shift on DAW Out?
//   2/4 daw page  DAW page (CC 30 = 1), every LED coloured: every button, knob and fader on DAW Out?
//   3/4 knob 1    the host sets knob 1 (ch 16 CC 13) to 127: does turning it continue from there (knob feedback)?
//   4/4 fader 1   asks the "DAW Fader Pickup" setting (ch 8 CC 70, reply on ch 7): does fader 1 report at once?
// At the end (and on Ctrl-C) DAW mode goes off (9F 0C 00): the LC is back in Custom Mode 1.
(
var start = Main.elapsedTime, names = (), show, outs, daw, leds, screen, phase;
var len = ("CE_DAW_TEST_PHASE".getenv ? "40").asFloat, dry = "CE_DAW_TEST_DRY".getenv == "1";
var t = { (Main.elapsedTime - start).round(0.01) };
var sx = { |o, bytes| o.sysex(Int8Array[0xF0, 0, 0x20, 0x29, 2, 0x15] ++ Int8Array.newFrom(bytes) ++ Int8Array[0xF7]) };
MIDIClient.init(verbose: false);
MIDIClient.sources.do { |src| names[src.uid] = "% / %".format(src.device, src.name) };
"Inputs:".postln; MIDIClient.sources.do { |src| "  %".format(names[src.uid]).postln };
MIDIIn.connectAll;
outs = if(dry) { [] } {
	MIDIClient.destinations.select { |d| var s = d.device ++ " " ++ d.name; s.contains("LCXL3") and: { s.contains("DAW") } }
		.collect { |d| var o = MIDIOut.newByName(d.device, d.name); o.latency = 0; "DAW port: % / %".format(d.device, d.name).postln; o } };
if(outs.isEmpty and: { dry.not }) { "No LC XL 3 DAW port found: plug one in and run again".warn };
daw = { |on| outs.do { |o| o.noteOn(15, 12, if(on, 127, 0)) }; "% | >>> daw mode %".format(t.(), if(on, "on", "off")).postln };
ShutDown.add { daw.(false) };
// every LED: bottom rows two rainbows, knob rows red / yellow / green, side buttons in their own colours
leds = { |o|
	[37, 38, 39, 40, 41, 42, 43, 44].do { |i, k| o.control(0, i, [5, 9, 13, 21, 37, 45, 49, 53][k]) };
	[45, 46, 47, 48, 49, 50, 51, 52].do { |i, k| o.control(0, i, [53, 49, 45, 37, 21, 13, 9, 5][k]) };
	(13..36).do { |i, k| o.control(0, i, [5, 13, 21][k div: 8]) };
	o.control(0, 65, 13); o.control(0, 66, 49); o.control(0, 104, 53);
	o.control(0, 106, 45); o.control(0, 107, 45); o.control(0, 103, 13); o.control(0, 102, 13);
	o.control(0, 118, 5); o.control(0, 116, 21) };
// stationary display (target 0x35), arrangement 2: three text lines
screen = { |o, lines|
	sx.(o, [4, 0x35, 0x62]);
	lines.do { |txt, f| sx.(o, [6, 0x35, f] ++ txt.ascii) };
	sx.(o, [4, 0x35, 0x7F]) };
phase = { |lines, fn| outs.do { |o| fn.(o); screen.(o, lines) }; "% | >>> phase: %".format(t.(), lines.join(" / ")).postln };
show = { |type, src, chan, num, val| "% | % | % ch % % %".format(t.(), names[src] ? src, type, chan + 1, num ? "", val ? "").postln };
MIDIFunc.cc({ |val, num, chan, src| show.("cc", src, chan, num, val) });
MIDIFunc.noteOn({ |val, num, chan, src| show.("noteOn", src, chan, num, val) });
MIDIFunc.noteOff({ |val, num, chan, src| show.("noteOff", src, chan, num, val) });
MIDIFunc.sysex({ |data, src| "% | % | sysex %".format(t.(), names[src] ? src, data.collect { |b| b.asHexString(2) }.join(" ")).postln });
"% | listening (phase % s%)".format(t.(), len, if(dry, ", dry", "")).postln;
fork {
	2.wait; daw.(true); 0.3.wait;
	phase.(["1/4 custom", "turn a knob, press", "record play shift"], { |o| o.control(6, 30, 6); 0.3.wait });
	len.wait;
	phase.(["2/4 daw page", "press every button", "knob, fader"], { |o| o.control(6, 30, 1); 0.3.wait; leds.(o) });
	len.wait;
	phase.(["3/4 knob 1", "set to max by app", "now turn it down"], { |o| o.control(15, 13, 127) });
	len.wait;
	phase.(["4/4 fader 1", "move it slowly", "top to bottom"], { |o| o.control(7, 70, 0) });
	len.wait;
	daw.(false);
	1.wait; 0.exit;
};
)
