// Column code of the ambient hats (010): a 909 open hat on the 8th off-beats, closed 16ths (Off-beat, 16ths, Shuffle: swung 0.4).
// Complexity (row 3): random quiet 16ths, then little 32nd rolls. Button 2: long open hats on every 8th. The low-pass is
// Brightness x Fog only. Plays in the Break.
(
var fx = ~ce.ambientFx;
(
states: fx.startStates([\hats]),
strip: (roomR: \hatsRoom, echoSend: \hatsEcho),
update: { |col, send| fx.apply(col, send, \hats) },
start: { |col, ce| ce.onCC(ce.stemGlobal.tension, { |v, send| col.refreshStates(send) }) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.ambientOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, v = col[\patLatch].atBar(b), d = col.knob(\k3), out = List[], g;
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 3000, hi: 16000, tone: kit[\fog], pan: 0.56), adsr = kit[\adsr], ramp = kit[\ramp];
	var hh = { |gain, args| out.add(kit[\smp].("tr909/hh-00.wav", "RolandTR909_hh:0", gain * 1.2, lp ++ (args ? ()))) };
	var closed = [nil, [0.2, 0.1, 0, 0.12], [0.22, 0.08, 0.14, 0.1]];
	fr.rootAt(tr, b);
	if((k % 4) == 2) { out.add(kit[\smp].("tr909/oh-00.wav", "RolandTR909_oh:0", 0.4 * 1.2, lp ++ adsr.(nil, 0.12, 0, nil))) };
	closed[v] !? { |c| g = c[k % 4]; if(g > 0) { hh.(g, if(v == 2 and: { k.odd }) { (at: 0.4) } { () }) } };
	if(d > 0 and: { ce.rand(t) >= 0.4 }) { hh.(ramp.(d, 0, 0.5) * 0.12) };
	if(d > 0.5) { 2.do { |j| if(ce.rand(t + (j / 32)) >= 0.8) { hh.(ramp.(d, 0.5, 1) * 0.18, (at: j / 2)) } } };
	if(col.held(\b2) and: { k.even }) { out.add(kit[\smp].("tr909/oh-00.wav", "RolandTR909_oh:0", 0.3 * 1.2, lp)) };
	out
}
)
)
