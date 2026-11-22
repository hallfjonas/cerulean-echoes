// Column code of the ambient congas (010): TR-727 percussion: congas low, bongos high and low (Pillow, Rolling, Latin). Complexity
// (row 3): fingertip ghost notes, then agogo bells; button 2: a conga run over the bar. Panning slowly. Plays in the Break.
(
var fx = ~ce.ambientFx;
(
states: fx.startStates([\perc]),
strip: (roomR: \percRoom, echoSend: \percEcho),
update: { |col, send| fx.apply(col, send, \perc) },
start: { |col, ce| ce.onCC(ce.stemGlobal.tension, { |v, send| col.refreshStates(send) }) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.ambientOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, s16 = k % 16, d = col.knob(\k3), r = ce.rand(t), out = List[];
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 600, hi: 12000, tone: kit[\tone], pan: 0.35 + (0.3 * ce.sine(t / 4))), ramp = kit[\ramp], line = kit[\line];
	var hit = { |n, g| out.add(kit[\smp].("tr727/perc-0" ++ n.asInteger ++ ".wav", "RolandTR727_perc:" ++ n.asInteger, g, lp)) };
	st[\pats] = st[\pats] ?? { ["4 ~ ~ 2 ~ ~ 3 ~ 4 ~ ~ 2 ~ 3 ~ ~", "~ ~ 4 2 ~ ~ 4 ~ ~ 3 ~ 2 ~ ~ 4 ~", "3 ~ 2 ~ 4 ~ 2 3 ~ 2 ~ 4 ~ ~ 2 ~"].collect(line) };
	st[\agogo] = st[\agogo] ?? { line.("~ 0 ~ ~ 1 ~ ~ 0 ~ ~ 1 ~ 0 ~ ~ ~") };
	st[\fill] = st[\fill] ?? { line.("2 2 3 3 2 3 4 4 2 2 3 3 4 3 4 4") };
	fr.rootAt(tr, b);
	st[\pats][col[\patLatch].atBar(b)][s16] !? { |n| hit.(n, 0.2 + (0.1 * ce.perlin(t))) };
	if(d > 0 and: { r >= 0.55 }) { hit.(2 + (2 * r).trunc, ramp.(d, 0, 0.5) * 0.09) };
	if(d > 0.5) { st[\agogo][s16] !? { |n| hit.(n, ramp.(d, 0.5, 1) * 0.13) } };
	if(col.held(\b2)) { hit.(st[\fill][s16], 0.25) };
	out
}
)
)
