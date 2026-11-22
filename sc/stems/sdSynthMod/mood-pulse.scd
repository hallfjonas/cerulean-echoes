// Column code of the ambient heartbeat (007): a soft kick on D, per bar one of three rhythms (heartbeat on 16ths, quarters, half
// notes). Punch (row 3), three steps: a soft sine thump gliding down into D2, a synth kick, a firm kick with more click.
// Button 2 pauses it while held. Sits out the Break.
(
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], kit = ce.moodOf(col), b = (k / 16).floor, s16 = k % 16, drive, lp, g;
	var rhythms = [[{ |s16| [1, 0.55, nil, nil][s16 % 4] }, 1], [{ |s16| if((s16 % 4) == 0) { 0.9 } }, 4],
		[{ |s16| if((s16 % 8) == 0) { 1 } }, 4]];
	var rh = rhythms[col[\patLatch].atBar(b)];
	g = rh[0].(s16);
	if(col.held(\b2) or: { g.isNil }) { [] } {
		drive = col.knob(\k3); drive = if(drive < (1/3)) { 0 } { if(drive < (2/3)) { 1 } { 2 } };
		lp = (lpOn: 1, bright: col.knob(\k1), lo: 180, hi: 1500, tone: kit[\tone], hold: rh[1]);
		if(drive == 0) {
			[kit[\syn].(\sine, 38, g, lp ++ (penv: -4) ++ kit[\padsr].(0.08) ++ kit[\adsr].(0.015, 0.45, 0, 0.15))]
		} {
			[ce.note(\sdSbd, (freq: 38.midicps, amp: g * 0.4, decay: 0.45, penv: [8, 12][drive - 1], pdecay: 0.06,
				tag: "sbd", g: g * 0.4, midi: 38) ++ lp)]
		}
	}
}
)
)
