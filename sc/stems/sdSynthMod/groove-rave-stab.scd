// Column code of the groove rave stab (001, 002): root, third, fifth and octave of the chord on three detuned saws and a
// square an octave down, the filter snapping shut. Rave, Call, Off-beat; Drive (row 3) overdrives and ducks the level;
// button 2 ratchets 16ths.
(
strip: (space: \k2, echo: 0.2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame];
	var b = (k / 16).floor, out = List[], d = col.knob(\k3), gd = kit[\dB].(-6 * d), adsr = kit[\adsr], syn = kit[\syn];
	st[\raves] = st[\raves] ?? { ["~ ~ x ~ ~ x ~ ~ ~ ~ x ~ ~ ~ x ~", "<[x ~ ~ x ~ ~ x ~ ~ ~ ~ ~ ~ ~ ~ ~] ~>", "[~ ~ x ~]*4"].collect(kit[\table]) };
	st[\ratchet] = st[\ratchet] ?? { kit[\table].("x*16") };
	kit[\eventsAt].(if(col.held(\b2)) { st[\ratchet] } { st[\raves][col[\patLatch].atBar(b)] }, k).do { |e|
		var lp = (lpOn: 1, bright: col.knob(\k1), lo: 600, hi: 8000, tone: kit[\tone], lpq: 6, lpenv: 2, la: 0.002, ld: 0.1, ls: 0, lr: 0.01,
			shape: 0.2 + (0.5 * d), at: e[0], hold: e[1]) ++ adsr.(0.002, 0.2, 0, 0.1);
		fr.tonesAt(tr, b, [0, 2, 4, 7], 4).do { |m|
			[0, 0.12, -0.12].do { |dm| out.add(syn.(\sawtooth, m + dm, 0.125 * gd, lp)) };
			out.add(syn.(\square, m - 12, 0.1 * gd, lp))
		}
	};
	out
}
)
