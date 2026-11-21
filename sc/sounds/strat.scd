// Stratocaster: nyanshell.strat (MIT), three takes of every note 52..86 (E3..D6), cut to 1.5 s, on sdSample (the
// stem plays sdSamplePh for its phaser). Low notes from the D string, then G, then high E. maps: take → [[MIDI, file]].
(
var maps = (1..3).collect { |take| ("strat" ++ take).asSymbol -> (52..86).collect { |m|
	var n = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"][m % 12] ++ ((m / 12).floor.asInteger - 1);
	var dp = if(m < 62) { ["d_mp", "D"] } { if(m < 65) { ["g_mp", "G"] } { ["e4_mp", "E4"] } };
	[m, "strat/" ++ dp[0] ++ "/" ++ dp[1] ++ "_" ++ n ++ "_mp_" ++ take ++ ".flac"] } };
~ce.loadSound(\sdSample).copy.putAll((name: \strat, role: \lead,
	about: "Stratocaster single notes, three takes, on sdSample", maps: maps.asDict,
	files: maps.collect { |m| m.value.collect(_[1]) }.flatten))
)
