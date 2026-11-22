// Column code of the groove kick (001, 002): a tight 909 kick with a short sine body on D, three rhythms. Master (column 8's
// fader) drives it: louder, longer, more drive. Out in the Break and while button 2 (Hold) is held.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), b = (k / 16).floor, out = List[];
	var adsr = kit[\adsr], syn = kit[\syn], smp = kit[\smp], dB = kit[\dB];
	st[\kicks] = st[\kicks] ?? { ["x*4", "<x*4 [x x x [x ~ ~ x]]>", "x ~ x ~"].collect(kit[\table]) };
	if(col[\track].breakAt(b).not and: { col.held(\b2).not }) {
		kit[\eventsAt].(st[\kicks][col[\patLatch].atBar(b)], k).do { |e|
			var p = col.knob(\k3), w = ce.val(ce.stemGlobal.master), gw = 0.9 * dB.(1.5 * w);
			var lp = (lpOn: 1, bright: col.knob(\k1), lo: 600, hi: 9000, tone: kit[\tone], shape: 0.25 * w, at: e[0], hold: e[1]);
			out.add(smp.("tr909/bd-01.wav", "RolandTR909_bd:0", (0.45 + (0.4 * p)) * gw, lp ++ (hold: -1) ++ adsr.(nil, 0.5, 0, nil), \sdSampleMod));
			out.add(syn.(\sine, 38, (0.75 - (0.25 * p)) * gw, lp ++ (penv: 14 + (6 * w), pd: 0.05)
				++ adsr.(0.002, 0.28 * (1 + (0.4 * w)), 0, 0.05)))
		}
	};
	out
}
)
