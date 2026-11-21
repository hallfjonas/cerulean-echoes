// Brass section: Sonatina Symphonic Orchestra trumpets, trombones, horns (CC Sampling Plus 1.0), staccato and sustain,
// on sdSample. maps: instrument → [[key MIDI, file] …] in the order of Strudel's sample maps.
(
var maps = [
	[\sso_tp, "Trumpets", "trumpets-stc-rr1-", "e3 g3 a#3 c#4 e4 g4 a#4 c#5 e5 g5 a#5", ""],
	[\sso_tb, "Trombones", "trombones-stc-rr1-", "e2 g2 a#2 c#3 e3 g3 a#3 c#4 e4", ""],
	[\sso_hn, "Horns", "horns-stc-rr1-", "e2 g2 a#2 c#3 e3 g3 a#3 c#4 e4 g4 a#4", ""],
	[\sso_tp_sus, "Trumpets", "trumpets-sus-", "e3 g3 a#3 c#4 e4 g4 a#4 c#5 e5 g5", ""],
	[\sso_tb_sus, "Trombones", "trombones-sus-", "e2 g2 a#2 c#3 e3 g3 a#3 c#4 e4", ""],
	[\sso_hn_sus, "Horns", "horns-sus-mp-", "e2 g2 a#2 c#3 e3 g3 a#3 c#4 e4 g4 a#4", "-PB-loop"],
].collect { |m| m[0] -> m[3].split($ ).collect { |n|
	[~ce.noteNumber(n), "sso/" ++ m[1] ++ "/" ++ m[2] ++ n ++ m[4] ++ ".flac"] } };
~ce.loadSound(\sdSample).copy.putAll((name: \brassSection, role: \lead,
	about: "SSO trumpets, trombones, horns (staccato, sustain) on sdSample", maps: maps.asDict,
	files: maps.collect { |m| m.value.collect(_[1]) }.flatten))
)
