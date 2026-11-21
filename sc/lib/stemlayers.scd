// Stem format 2 (docs/features/stems.md): the parts of a stem file that stems.scd reads into a column. A stem plays
// layers: each layer is one sound with its own patterns (inherited from the stem's patterns), parameters, envelope,
// transpose, swing, an amount (from a knob, button 2 or Tension) and a chance. A format 1 stem is one layer made of its
// patterns. Values of parameters and velocities: a number, a mini-notation (one value per hit) or a wave over time.
(
// a number, (mini: …) or (wave: \sine | \perlin | \rand, lo, hi, bars, atBar)
~ce.stemValue = { |self, x|
	case
	{ x.isKindOf(Dictionary) } { var r = x[\range] ? [0, 1];
		(wave: x[\wave].asSymbol, lo: self.numOf(r[0]), hi: self.numOf(r[1]), bars: self.numOf(x[\bars] ? 1),
			atBar: x[\at] == "bar") }
	{ x.isString and: { "^-?[0-9.]+$".matchRegexp(x) } } { x.asFloat }
	{ x.isString } { (mini: self.mini(x)) }
	{ x }
};
// the value of a stem value at cycle time t (nil on a rest of a mini-notation)
~ce.stemValueAt = { |self, x, t, col|
	case
	{ x.isNumber } { x }
	{ x[\mini].notNil } { col.miniValue(x[\mini], t) }
	{ var tt = (if(x[\atBar]) { t.floor } { t }) / x[\bars];
		x[\lo] + ((x[\hi] - x[\lo]) * switch(x[\wave], \sine, { self.sine(tt) }, \perlin, { self.perlin(tt) },
			\rand, { self.rand(tt) })) }
};
// a pattern-like part of a stem file (a pattern, a layer, a layer's pattern) → Event of what it sets
~ce.stemPart = { |self, p|
	var out = ();
	p !? {
		p[\label] !? { |x| out[\label] = x };
		[\rhythm, \notes, \length].do { |key| p[key] !? { |s| out[key] = self.mini(s.asString) } };
		p[\velocity] !? { |v| out[\vel] = self.stemValue(v) };
		p[\params] !? { |ps| out[\params] = (); ps.keysValuesDo { |k, v| out[\params][k] = self.stemValue(v) } };
		p[\env] !? { |e| out[\env] = (); e.keysValuesDo { |k, v| out[\env][k] = self.numOf(v) } };
		p[\voices] !? { |vs| out[\voices] = vs.collect { |v| self.numOf(v) } };
		p[\strike] !? { |s| out[\strike] = self.numOf(s[\bars] ? 4) * 16 };
	};
	out
};
// b over a: every key b sets wins, params are merged
~ce.stemMerge = { |self, a, b|
	var out = a.copy;
	b.keysValuesDo { |k, v| out[k] = if(k == \params) { (a[\params] ? ()).copy.putAll(v) } { v } };
	out
};
// an amount or a chance: (source: \k1 … \k3 | \b2 | \tension, points: [[x, y] …], power, param, play)
~ce.stemAmount = { |self, a|
	(source: (a[\source] ? "k3").asSymbol, points: (a[\points] ? [[0, 0], [1, 1]]).collect { |pt| pt.collect { |x|
		self.numOf(x) } }, power: a[\curve] == "power", param: a[\param] !? { |x| x.asSymbol }, play: a[\zero] == "play")
};
// y at x = v on a line through the points (before the first: its y, after the last: its y); power: equal power
// (sine up, cosine down), and 0 within 0.001 of a point at 0 (a side that is off plays nothing)
~ce.stemCurve = { |self, pts, v, power = false|
	var i = 1, p0, p1, u, y;
	if(v <= pts[0][0]) { pts[0][1] } {
		while { (i < pts.size) and: { v > pts[i][0] } } { i = i + 1 };
		if(i >= pts.size) { pts.last[1] } {
			p0 = pts[i - 1]; p1 = pts[i];
			u = if(p1[0] > p0[0]) { (v - p0[0]) / (p1[0] - p0[0]) } { 1 };
			y = case
			{ power.not } { p0[1] + ((p1[1] - p0[1]) * u) }
			{ p1[1] >= p0[1] } { p0[1] + ((p1[1] - p0[1]) * sin(u * 0.5pi)) }
			{ p1[1] + ((p0[1] - p1[1]) * cos(u * 0.5pi)) };
			if(power and: { pts.any { |p| (p[1] == 0) and: { (v - p[0]).abs <= 0.0010001 } } }) { 0 } { y }
		}
	}
};
// the layers of a stem: its "layers", or one layer of its patterns (format 1)
~ce.stemLayers = { |self, stem|
	var pats = stem[\patterns].collect { |p| self.stemPart(p) };
	(stem[\layers] ?? { [()] }).collect { |l, i|
		var own = self.stemPart(l), lp = (l[\patterns] ? []).collect { |p| self.stemPart(p) };
		var sound = (l[\sound] ?? { stem[\sample][\name] }).asSymbol;
		var def = (self.sounds[sound] ?? { self.loadSound(sound) }).def, names = def.allControlNames;
		var dflt = { |n| names.detect { |c| c.name == n } !? { |c| c.defaultValue } };
		(
			name: (l[\name] ? "main").asSymbol, index: i, sound: sound, inputs: names.collect(_.name),
			pats: pats.collect { |sp, j| self.stemMerge(self.stemMerge(sp, own), lp[j] ? ()) },
			transpose: self.numOf(l[\transpose] ? 0), swing: l[\swing] !? { |x| self.numOf(x) },
			amount: l[\amount] !? { |a| self.stemAmount(a) },
			chance: l[\chance] !? { |c| if(c.isKindOf(Dictionary)) { self.stemAmount(c) } { self.numOf(c) } },
			live: ("mix_" ++ (l[\name] ? i)).asSymbol,
			envDefault: if(names.any { |c| c.name == \a }) { [\a, \d, \s, \r].collect(dflt) }
		)
	}
};
)
