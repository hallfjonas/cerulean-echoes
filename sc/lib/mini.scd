// Strudel mini-notation, the part the tracks use: steps, rests (~), weights (@n), repeats (!n), speed-ups (*n, whole
// numbers), sub-sequences ([a b]), alternation (<a b c>, one item per cycle). ~ce.mini(str) → (period: cycles, events: [[begin, dur, value]])
// with begin / dur in cycles from the start of the period. Values: numbers as numbers, everything else (note names)
// as strings. Example: ~ce.mini("<[0 ~ 2]!3 [~ 4@2]>") → period 4, the first bar three times, then the second.
// Checked against Strudel's own parser by tools/sc-port/mini-check.mjs.
(
~ce.miniParse = { |self, str|
	var toks = List[], i = 0, cur = "", pos = 0, item, seq;
	// tokens: brackets, @, !, *, words
	str.do { |ch|
		if("[]<>@!* ".includes(ch)) {
			if(cur.size > 0) { toks.add(cur); cur = "" };
			if(ch != $ ) { toks.add(ch.asString) }
		} { cur = cur ++ ch }
	};
	if(cur.size > 0) { toks.add(cur) };
	// item: a word or a bracketed group; seq: items with @ weights, ! repeats and * speed-ups up to a closing bracket
	item = { var t = toks[pos], r;
		pos = pos + 1;
		case
		{ t == "[" } { r = seq.("]"); (type: \seq, steps: r) }
		{ t == "<" } { r = seq.(">"); (type: \alt, items: r.collect(_[0]) ) }
		{ t == "~" } { (type: \rest) }
		{ (type: \leaf, v: if("^-?[0-9.]+$".matchRegexp(t)) { if(t.includes($.)) { t.asFloat } { t.asInteger } } { t }) }
	};
	seq = { |close| var steps = List[];
		while { pos < toks.size and: { toks[pos] != close } } {
			case
			{ toks[pos] == "@" } { steps.last[1] = toks[pos + 1].asFloat; pos = pos + 2 }
			{ toks[pos] == "!" } { var n = toks[pos + 1].asInteger; (n - 1).do { steps.add(steps.last.copy) }; pos = pos + 2 }
			{ toks[pos] == "*" } { steps.last[0] = (type: \fast, n: toks[pos + 1].asInteger, node: steps.last[0]); pos = pos + 2 }
			{ steps.add([item.(), 1]) }
		};
		pos = pos + 1;   // the closing bracket
		steps
	};
	toks.addFirst("["); toks.add("]"); pos = 1;
	(type: \seq, steps: seq.("]"))
};
// events of node n in cycle c, placed in [begin, begin + dur)
~ce.miniEvents = { |self, n, c, begin, dur|
	switch(n.type,
		\rest, { [] },
		\leaf, { [[begin, dur, n[\v]]] },
		\alt, { self.miniEvents(n.items[c % n.items.size], (c / n.items.size).floor, begin, dur) },
		// x*n: x n times in the slot, cycles c × n … c × n + n − 1 (an alternation inside moves on n steps per cycle)
		\fast, { n.n.collect { |i| self.miniEvents(n.node, (c * n.n) + i, begin + (i * dur / n.n), dur / n.n) }.flatten(1) },
		\seq, { var w = n.steps.collect(_[1]).sum, t = begin;
			// a sequence of one alternation: the alternation itself
			n.steps.collect { |s| var d = dur * s[1] / w, e = self.miniEvents(s[0], c, t, d); t = t + d; e }.flatten(1) }
	)
};
~ce.miniPeriod = { |self, n|
	switch(n.type,
		\alt, { n.items.size * n.items.collect { |x| self.miniPeriod(x) }.reduce(\lcm) },
		\seq, { n.steps.collect { |s| self.miniPeriod(s[0]) }.reduce(\lcm) ? 1 },
		\fast, { var p = self.miniPeriod(n.node); p.div(gcd(p, n.n)) },
		{ 1 })
};
~ce.mini = { |self, str|
	var n = self.miniParse(str), p = self.miniPeriod(n);
	(period: p, events: (0..p - 1).collect { |c| self.miniEvents(n, c, c, 1) }.flatten(1))
};
)
