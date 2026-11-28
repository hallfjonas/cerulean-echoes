// cerulean-echoes — SuperCollider core.
// Load once:  ~ce = (thisProcess.nowExecutingPath.dirname +/+ "lib/ce.scd").load   (from a file in sc/)
// The same code runs live (server = s, MIDI from the Launch Controls) and offline (server = a score recorder, the
// controls come from a scenario): tools/render.scd. Everything the musicians touch lives on control buses, so a knob
// changes sounding notes at once; only buttons that switch patterns wait for the bar (latches).
(
var dir = thisProcess.nowExecutingPath.dirname;
~ce = (
	root: dir.dirname,            // sc/
	sounds: (),                   // name → sound description (sounds/*.scd, see sounds/README.md)
	defs: (),                     // SynthDef name → SynthDef (sounds + mixer), sent to the server by init
	cc: 0 ! 256,                  // language-side copy of every CC (0..1; 128-255: stems no controller moves, stemlab.scd)
	ccAlias: (),                  // cc → cc whose bus it shares (column 8: Mode 2 CC + 48 → Mode 1 CC)
	pressFns: (),                 // cc → [functions] called on every press (rising edge)
	log: nil,                     // an Array while rendering: every note played, for the event comparison
	trimDb: -9,                   // master trim before the limiter: all faders up peaks at -6 to -3 dBFS, so the
	                              // limiter (-1 dBFS) only catches extremes (0 = as loud as Strudel, which clips)
	limit: 1,                     // 1 = limiter on the master (ceiling -1 dBFS), 0 = off (comparisons)
);
["sounds.scd", "controls.scd", "lcxl3-custom.scd", "launchkey-mk4.scd", "mixer.scd", "steps.scd", "score.scd",
	"setup.scd", "ui.scd", "strudel.scd", "mini.scd", "addons.scd", "stems.scd", "stemlayers.scd", "stemtrack.scd",
	"stemkit.scd"].do { |f| (dir +/+ f).load };
~ce
)
