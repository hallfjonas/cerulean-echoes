// MIDI monitor: prints every message from every MIDI input with its port name, one line each:
//   <seconds> | <port> | <type> ch <1-16> <number> <value>
// Run: /Applications/SuperCollider.app/Contents/MacOS/sclang sc/tools/midi-trace.scd   (Ctrl-C ends it)
// Used to measure what a controller sends (midi-layouts/devices.md).
(
var start = Main.elapsedTime, names = (), show;
MIDIClient.init(verbose: false);
MIDIClient.sources.do { |src| names[src.uid] = "% / %".format(src.device, src.name) };
"Inputs:".postln;
MIDIClient.sources.do { |src| "  %".format(names[src.uid]).postln };
MIDIIn.connectAll;
show = { |type, src, chan, num, val|
	"% | % | % ch % % %".format((Main.elapsedTime - start).round(0.001), names[src] ? src, type, chan + 1, num ? "",
		val ? "").postln };
MIDIFunc.cc({ |val, num, chan, src| show.("cc", src, chan, num, val) });
MIDIFunc.noteOn({ |val, num, chan, src| show.("noteOn", src, chan, num, val) });
MIDIFunc.noteOff({ |val, num, chan, src| show.("noteOff", src, chan, num, val) });
MIDIFunc.program({ |val, chan, src| show.("program", src, chan, val) });
MIDIFunc.bend({ |val, chan, src| show.("bend", src, chan, val) });
MIDIFunc.touch({ |val, chan, src| show.("touch", src, chan, val) });
MIDIFunc.polytouch({ |val, num, chan, src| show.("polytouch", src, chan, num, val) });
MIDIFunc.sysex({ |data, src| "% | % | sysex %".format((Main.elapsedTime - start).round(0.001), names[src] ? src,
	data.collect { |b| b.asHexString(2) }.join(" ")).postln });
"Listening.".postln;
)
