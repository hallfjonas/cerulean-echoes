// House keys: the Steinway (VCSL, CC0) and the jRhodes3d Rhodes samples on sdSample, plus the General MIDI vibraphone
// and marimba zones the keys stem plays on sdFont. maps: [key MIDI, file] per sampled instrument.
(
var maps = (
	piano: [[54, "F#3"], [56, "G#3"], [58, "A#3"], [60, "C4"], [62, "D4"], [64, "E4"]].collect { |x|
		[x[0], "repo:vcsl-keys/JHPiano_Sus_Close_" ++ x[1] ++ "_vl3_rr1.flac"] },
	rhodes: [[55, "jrhodes/A_055__G3_3.flac"], [59, "jrhodes/A_059__B3_3.flac"], [62, "jrhodes/A_062__D4_3.flac"],
		[65, "jrhodes/A_065__F4_3.flac"]]);
~ce.loadSound(\sdSample).copy.putAll((name: \houseKeys, role: \keys,
	about: "Steinway and Rhodes samples (+ GM vibraphone, marimba zones)", maps: maps,
	files: (maps[\piano] ++ maps[\rhodes]).collect(_[1])
		++ ~ce.fontFiles("0110_JCLive_sf2_file") ++ ~ce.fontFiles("0120_JCLive_sf2_file")))
)
