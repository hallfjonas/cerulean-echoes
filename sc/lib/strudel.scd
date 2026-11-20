// Strudel's continuous signals and random numbers, bit for bit (legacy RNG, the Strudel default), so ported
// patterns pick the same random values at the same time as the Strudel tracks. t in cycles (= bars).
(
// 32-bit integer helpers (JavaScript semantics)
~ce.i32 = { |self, x| if(x.isKindOf(Float)) { x = x.asFloat.mod(4294967296.0).floor; if(x >= 2147483648.0) { x - 4294967296.0 } { x } } { x }.asInteger };
~ce.xorwise = { |self, x|
	var a = x.leftShift(13).bitXor(x), b = a.rightShift(17).bitXor(a);
	b.leftShift(5).bitXor(b)
};
~ce.jsRem = { |self, a, b| if(a < 0) { (a.abs % b).neg } { a % b } };
~ce.timeToIntSeed = { |self, t| var f = t / 300; self.xorwise((f - f.trunc * 536870912).trunc.asInteger) };
// rand (0..1) at time t
~ce.rand = { |self, t| (self.jsRem(self.timeToIntSeed(t), 536870912) / 536870912).abs };
// n random numbers at time t (Strudel's __timeToRandsPrime, used by chooseWith etc.)
~ce.rands = { |self, t, n| var seed = self.timeToIntSeed(t); n.collect { var v = self.jsRem(seed, 536870912) / 536870912; seed = self.xorwise(seed); v } };
~ce.irand = { |self, t, i| (self.rand(t) * i).trunc.asInteger };
~ce.perlin = { |self, t|
	var ta = t.floor, x = t - ta, ra = self.rand(ta), rb = self.rand(ta + 1);
	ra + (((6 * (x ** 5)) - (15 * (x ** 4)) + (10 * (x ** 3))) * (rb - ra))
};
~ce.sine = { |self, t| (sin(2pi * t) + 1) / 2 };
~ce.cosine = { |self, t| self.sine(t + 0.25) };
~ce.saw = { |self, t| t % 1 };
~ce.tri = { |self, t| var x = (t % 1) * 2; if(x < 1) { x } { 2 - x } };
~ce.square = { |self, t| ((t * 2).floor % 2) };
);

// Math.imul and the tracks' integer hash (009: hash(a, b, c) → 0..1), on unsigned 32-bit values held in Floats
(
~ce.u32 = { |self, x| x = x.asFloat.mod(4294967296.0).floor; x };
~ce.uxor = { |self, a, b| var r = self.i32(self.u32(a)).bitXor(self.i32(self.u32(b))); if(r < 0) { r + 4294967296.0 } { r.asFloat } };
~ce.imul = { |self, a, b| var lo, hi;
	a = self.u32(a); b = self.u32(b); lo = a.mod(65536.0); hi = (a / 65536.0).floor;
	((lo * b) + (((hi * b).mod(65536.0)) * 65536.0)).mod(4294967296.0) };
~ce.hash3 = { |self, a, b, c|
	var h = self.uxor(self.uxor(self.imul(a + 2654435769.0, 2246822507.0), self.imul(b + 1663821211.0, 3266489909.0)),
		self.imul(c + 668265263.0, 374761393.0));
	h = self.uxor(h, (h / 32768.0).floor); h = self.imul(h, 739982445.0);
	h = self.uxor(h, (h / 4096.0).floor); h = self.imul(h, 695872825.0);
	h = self.uxor(h, (h / 32768.0).floor);
	h / 4294967296.0 };
)
