// Hats: the TR-909 open and closed hat and the TR-727 shakers (tidal-drum-machines) on the sampler voice sdSample.
~ce.loadSound(\sdSample).copy.putAll((name: \hats909, role: \hats,
	about: "TR-909 open / closed hats and TR-727 shakers on sdSample",
	files: ["tr909/oh-00.wav", "tr909/hh-00.wav", "tr727/sh-00.wav", "tr727/sh-01.wav"]))
