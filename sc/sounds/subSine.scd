// Sub: superdough's oscillator voice (sdSynth) as a named instrument for sub stems, a sine with a soft triangle on top
// (the stem plays both waves). Same SynthDef as sdSynth.
~ce.loadSound(\sdSynth).copy.putAll((name: \subSine, role: \sub,
	about: "sub bass: sdSynth's sine (and triangle) as a named instrument"))
