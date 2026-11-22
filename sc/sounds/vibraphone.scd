// Vibraphone: the VCSL vibraphone (strudel.cc's built-in 'vibraphone', CC0), hard mallets, on sdSample.
// keys: [key MIDI, file] in the order of Strudel's sample map (the first wins on a tie).
(
var names = ["A2", "A4", "B3", "C3", "C5", "D4", "E3", "E5", "F2", "F4", "G3"];
var keys = names.collect { |n| [~ce.noteNumber(n), "vibraphone/Vibes_hard_" ++ n ++ "_v3_rr1_Main.flac"] };
~ce.loadSound(\sdSample).copy.putAll((name: \vibraphone, role: \keys,
	about: "VCSL vibraphone, hard mallets, on the sdSample voice", keys: keys, files: keys.collect(_[1])))
)
