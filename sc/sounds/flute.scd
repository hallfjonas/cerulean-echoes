// Flute: single notes cut from recorded flute phrases (juskiddink "Flute2", Freesound, CC BY 4.0; repo
// samples/horn-phrases) on sdSample. notes: [phrase, from s, to s, MIDI] (the lab's YIN analysis); lens: phrase lengths.
(
var files = ["0003", "0068", "0133"].collect { |n| "repo:horn-phrases/flute-65509-" ++ n ++ ".flac" };
~ce.loadSound(\sdSample).copy.putAll((name: \flute, role: \lead,
	about: "recorded flute notes (cut from phrases) on sdSample", files: files, lens: [6.45, 6.11, 7.12],
	notes: [[2, 1.86, 4.46, 61.97], [0, 3.87, 4.53, 64.07], [2, 0.45, 0.71, 65.12], [1, 2.02, 2.61, 67.11],
		[1, 0.11, 1.63, 68.94], [1, 2.67, 3.14, 70.98], [0, 0.77, 2.39, 72.03]]))
)
