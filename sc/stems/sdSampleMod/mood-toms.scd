// Column code of the ambient toms (007; the lab's figures, Takada): the VCSL low tom playing figures of scale degrees, six
// patterns: cycles, canon, Euclid, build-up, crossing, Clapping Music. Complexity (row 3), Density: the figure's rests fill up one
// by one; in Canon more voices; in Crossing a copy drifts away; in Clapping Music the second voice moves faster. Button 2 = a long
// dotted-8th echo while held.
(
var fx = ~ce.moodFx, fkit = ~ce.figureKit;
(
gate: false,
states: (echo: 0.06, room: 0.225),
maps: (trim: (ccs: [\k1], fn: { |b| 14 * (10 ** (4 * (b - 0.5) / 20)) })),
strip: (roomR: \room, echoSend: \echo, trim: \trim),
update: { |col, send| fx.roomSend(col, send, \room); fx.echoSend(col, send, \echo, 0.12, true, true) },
start: { |col, ce| fx.tensionHook(col, ce) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.moodOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t0 = k / 16;
	var kn = col.knob(\k3), lvl = (4 * kn).round.min(4), ls, out = List[], opt = col[\patLatch].atBar(b);
	var fk = st[\fk] ?? { var f = fkit, layer = f[\layer], toks = f[\toks], md = f[\md], euclid = f[\euclid];
		var rank = { |n| if(n == 0) { [] } { (0..n - 1) }.sort { |a, b| ce.hash3(a, n, 7) <= ce.hash3(b, n, 7) } };
		var denseFig = { |fig, level| var t = toks.(fig), rests = t.selectIndices { |x| x == "~" };
			var fill = rank.(rests.size).keep((rests.size * level / 4).round.asInteger).collect { |r| rests[r] };
			var last = t.detect { |x| x != "~" }.asFloat, n = 0, first = t.detectIndex { |x| x != "~" }, d = List[], vel = List[];
			t.do { |x, j|
				if(x != "~") { last = x.asFloat; d.add(last); vel.add(if(j == first) { 1 } { 0.6 }) } {
					if(fill.includes(j).not) { d.add(nil); vel.add(0) } {
						n = n + 1; d.add(last + if(n.odd) { 1 } { -1 } + if(level >= 2 and: { (n % 4) == 0 }) { 7 } { 0 }); vel.add(0.55) } } };
			(fig: d.asArray, vel: vel.asArray, oct: 1, pan: 0.4, g: 0.5, steps: 16, late: 0) };
		var denseLv = { |fig| (0..4).collect { |l| denseFig.(fig, l) } };
		var kfig = "0 4 ~ 7 4 ~ 2 ~";
		var clapFig = { |notes| var j = 0; toks.("x x x ~ x x ~ x ~ x x ~").collect { |x| if(x == "~") { x } { var y = notes[j % notes.size]; j = j + 1; y.asString } }.join(" ") };
		var moving = { |every, n, stepLen| { |b| md.((b / every).floor, n) * stepLen } };
		var v = (
			cycles: denseLv.("4 ~ 7 ~ 9"), euclid: denseLv.(euclid.(3, 8, [4, 7, 2])), build: denseLv.("0 ~ 4 7 ~ 4 2 ~"),
			canon: [layer.(kfig, 1, 0.45), layer.(kfig, 1, 0.75, 0.4) ++ (late: 3/16), layer.(kfig, 1, 0.2, 0.35) ++ (late: 5/16)],
			clapV1: layer.(clapFig.([0, 4, 7, 4, 2, 4, 7, 9]), 1, 0.3, 0.5, 12),
			clapRates: [8, 4, 2].collect { |e| var m = moving.(e, 12, 1/12);
				layer.(clapFig.([7, 9, 11, 9, 7, 4, 7, 6]), 1, 0.7, 0.5, 12) ++ (late: { |b| m.(b).neg }) },
			crossing: layer.("4 2", 1, 0.35, 0.45, 8));
		st[\fk] = v; v };
	var hits = fkit[\hits], md = fkit[\md];
	if(opt == 4 and: { kn > 0.02 }) { st[\drift] = (st[\drift] ? 0) + ((1/16) * 0.1 * (kn ** 2)) };
	ls = switch(opt,
		0, { [fk[\cycles][lvl]] },
		1, { fk[\canon].select { |x, v| (v == 0) or: { kn > (v / 3) } } },
		2, { [fk[\euclid][lvl]] },
		3, { [fk[\build][(md.(b, 32) / 4).floor.min(1 + (3 * kn).round)]] },
		4, { [fk[\crossing]] ++ if(kn > 0.02) { [fk[\crossing] ++ (pan: 0.75, late: (st[\drift] ? 0).neg)] } { [] } },
		5, { [fk[\clapV1]] ++ if(kn > 0.02) { [fk[\clapRates][(3 * kn).floor.min(2)]] } { [] } });
	ls.do { |ly| hits.(ly, t0, b).do { |h|
		var m = fr.degMidi(h[\deg], 3 + ly[\oct], fr.moodAt(tr, h[\u].floor)) - 26, vel = 0.6 + (0.4 * (h[\vel] - 0.6));
		out.add(kit[\smp].("vcsl/tom2_mallet/TomL_HitM_v2_rr1_Mid.flac", "tom2_mallet", ly[\g] * vel, (rate: 2 ** ((m - 36) / 12), midi: m,
			at: h[\at], pan: ly[\pan], lpOn: 1, bright: col.knob(\k1), lo: 600, hi: 6000, tone: kit[\tone])))
	} };
	out
}
)
)
