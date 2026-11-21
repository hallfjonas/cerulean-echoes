// Frame of the stem demo track (090-stem-demo.track): the harmony and the column 8 texts. Vamp = Am9 throughout,
// Progression = Am9 and D9, two bars each. Format: sc/lib/stemtrack.scd.
// @col 16:8 8 Global
// @col 2:8 8 Global
// @ctl g.k1 Fog | clear ↔ muffled (all low-passes down).
// @ctl g.k2 Thin | full ↔ thin (all high-passes up).
// @ctl g.k3 Tension | build-up: echo, reverb, open filters.
// @ctl g.fader Master | volume of everything.
// @ctl g.b1 Chapter | Vamp (Am9) ↔ Progression (Am9 D9).
// @ctl g.b2 Break | 1st: kick and bass out. 2nd: back on the one.
(
var chords = [~ce.chordOf("Am9", "a1", "c4 e4 g4 b4", "a b c d e f# g"),
	~ce.chordOf("D9", "d2", "c4 e4 f#4 a4", "d e f# g a b c")];
(
chapterBars: 4,
chordAt: { |frame, track, bar| if(track.chapterAt(bar) == 0) { chords[0] } { chords[(bar / 2).floor.asInteger % 2] } }
)
)
