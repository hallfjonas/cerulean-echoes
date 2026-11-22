// String section: Sonatina Symphonic Orchestra (CC Sampling Plus 1.0) and VSCO 2 CE (CC0) string sections on sdSample.
// VSCO sounds an octave above its file name (Strudel: vscoUp8). maps: instrument → [[key MIDI, file] …].
(
var sso = [
	[\sso_vn, "1st Violins", "1st-violins-stc-rr1-", "g3 c#4 e4 g4 a#4 c#5 e5 g5 a#5 c#6 e6 g6"],
	[\sso_vn2, "2nd Violins", "2nd-violins-stc-rr1-", "g3 a#3 c#4 e4 g4 a#4 c#5 e5 g5 a#5"],
	[\sso_va, "Violas", "violas-stc-rr1-", "c3 d#3 f#3 a3 c4 d#4 f#4 a4 c5"],
	[\sso_vc, "Celli", "celli-stc-rr1-", "c2 d#2 f#2 a2 c3 d#3 f#3 a3 c4"],
	[\sso_vn_sus, "1st Violins", "1st-violins-sus-", "g3 a#3 c#4 e4 g4 a#4 c#5 e5 g5 a#5 c#6"],
	[\sso_va_sus, "Violas", "violas-sus-", "c3 d#3 f#3 a3 c4 d#4 f#4 a4 c5"],
	[\sso_vn_piz, "1st Violins", "1st-violins-piz-rr1-", "g3 a#3 c#4 e4 g4 a#4 c#5 e5 a#5 c#6"],
].collect { |m| m[0] -> m[3].split($ ).collect { |n| [~ce.noteNumber(n), "sso/" ++ m[1] ++ "/" ++ m[2] ++ n ++ ".flac"] } };
var vsco = [
	[\vs_vn, "Violin Section/Spic/VlnEns_Spic_", "G2 A2 B2 D3 F#3 A3 C4 E4 G4 B4 D5"],
	[\vs_va, "Viola Section/spic/Violas_spic_", "C2 E2 G2 B2 D3 F3 A3 C4 E4 G4"],
].collect { |m| m[0] -> m[2].split($ ).collect { |n| [~ce.noteNumber(n) + 12, "vsco/" ++ m[1] ++ n ++ "_v2_rr1.flac"] } };
~ce.loadSound(\sdSample).copy.putAll((name: \stringSection, role: \pad,
	about: "SSO and VSCO string sections (staccato, sustain, pizzicato)", maps: (sso ++ vsco).asDict,
	files: (sso ++ vsco).collect { |m| m.value.collect(_[1]) }.flatten))
)
