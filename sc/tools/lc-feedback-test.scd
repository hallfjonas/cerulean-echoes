// Does a Launch Control XL 3 in a custom mode take a knob value sent to it? (If yes, SC can keep two LCs in step and
// knobs never jump.) Run in a terminal, with the LC in Mode 1:
//   /Applications/SuperCollider.app/Contents/MacOS/sclang sc/tools/lc-feedback-test.scd
// It sends knob row 1 / column 1 (CC 13, every channel) the value 100 on every LC, then waits for you to turn that
// knob one step: about 99 or 101 = the device took the value; anything else = it keeps its own.
(
var outs, verdict = false;
MIDIClient.init(verbose: false);
outs = MIDIClient.destinations.select { |d| var n = d.device ++ " " ++ d.name; n.containsi("LCXL3") and: { n.containsi("DAW").not } };
if(outs.isEmpty) { "No Launch Control XL 3 found.".postln; 0.exit };
MIDIClient.sources.do { |s| MIDIIn.connect(0, s) };
outs.do { |d| var o = MIDIOut.newByName(d.device, d.name); o.latency = 0; 16.do { |ch| o.control(ch, 13, 100) };
	"sent CC 13 = 100 to %".format(d.device + d.name).postln };
"\nNow turn knob row 1 / column 1 ONE step (within 60 s) ...".postln;
MIDIdef.cc(\lcFeedbackTest, { |val, num, chan, src|
	if(verdict.not) { verdict = true;
		"received CC 13 = %".format(val).postln;
		if((val - 100).abs <= 3) { "\nRESULT: the LC took the value (feedback works)".postln }
			{ "\nRESULT: the LC kept its own value (no feedback in custom modes)".postln };
		{ 0.exit }.defer(0.5) } }, 13);
{ 60.wait; if(verdict.not) { "\nno knob turn received in 60 s".postln; 0.exit } }.fork;
)
