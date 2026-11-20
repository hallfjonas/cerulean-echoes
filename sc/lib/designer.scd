// Sample Designer: a project file (sc/lab/samples/<name>.sample.json, format: sc/lab/samples/sample.schema.json) as a
// track the engine plays. The machine schema on the Launch Control (Mode 1):
//   columns 1-7  the blocks in signal order (sources, then the chain); row 1 / 2 / 3 = the block's main / shape and
//                time / fine and modulation knob, fader = block level, button 1 = block on / off, button 2 = next type
//   column 8     k1 Accent, k2 Space, k3 Length (of the audition notes), fader Master, b1 Pattern (next audition
//                pattern at the next bar), b2 Save (the player's server writes the project file, /ce/save)
// Knob values live on state buses: a knob acts at once, also on sounding notes. sampleProject(path, soundName) plays
// the library sound soundName (an export of the project) instead of the machine, with the same parameters.
// Loaded by sc/engine.scd and sc/tools/render.scd for a .sample.json path.
(
~ce.sampleBlocks = { |self| File.readAllString(self.root +/+ "lab" +/+ "samples" +/+ "blocks.json").parseJSON };
~ce.sampleParam = { |self, id, key| (id.asString ++ key[0].toUpper ++ key.drop(1)).asSymbol };

~ce.sampleProject = { |self, path, soundName|
	var ce = self, project = File.readAllString(path).parseJSON, lib = self.sampleBlocks, kinds = lib["kinds"];
	var num = { |x, default = 0| if(x.isNil) { default } { x.asFloat } };
	var cols = (project["sources"] ? []) ++ (project["chain"] ? []);
	var aud = project["audition"], patterns = aud["patterns"];
	var setupLabel = lib["setups"][project["setup"]] !? { |s| s["label"] } ? "Free arrangement";
	var vals = (), params = (), tags = (), names = (), snd, sndName, track;
	var colLabel = { |b, i| var kind = b["kind"], same = cols.select { |c| c["kind"] == kind };
		kinds[kind]["label"] ++ if(same.size > 1) { " " ++ (same.indexOf(b) + 1) } { "" } };
	cols.do { |b|
		var id = b["id"], kind = kinds[b["kind"]], types = kind["types"];
		kind["knobs"].do { |kn, j| var p = self.sampleParam(id, kn["key"]);
			vals[p] = num.(b["k" ++ (j + 1)]);
			params[p] = (default: vals[p], spec: [0, 1], label: kind["label"] ++ " " ++ kn["label"], about: kn["about"]) };
		vals[self.sampleParam(id, "level")] = num.(b["level"], 1);
		vals[self.sampleParam(id, "on")] = if(b["on"] == "false") { 0 } { 1 };
		vals[self.sampleParam(id, "type")] = (types.indexOfEqual(b["type"]) ? 0);
		params[self.sampleParam(id, "level")] = (default: vals[self.sampleParam(id, "level")], spec: [0, 1],
			label: kind["label"] ++ " " ++ kind["fader"]["label"], about: kind["fader"]["about"]);
		params[self.sampleParam(id, "on")] = (default: vals[self.sampleParam(id, "on")], spec: [0, 1, \lin, 1],
			label: kind["label"] ++ " On", about: "block on / off");
		params[self.sampleParam(id, "type")] = (default: vals[self.sampleParam(id, "type")],
			spec: [0, types.size - 1, \lin, 1], label: kind["label"] ++ " Type", about: types.join(", "));
	};
	if(soundName.isNil) {
		var def = (self.root +/+ "lab" +/+ "samples" +/+ "machine.scd").load.(\ce_sampleDesigner,
			cols.collect { |b| [b["id"].asSymbol, b["kind"].asSymbol] }, vals);
		sndName = \sampleDesigner;
		snd = (name: sndName, role: (project["role"] ? "perc").asSymbol, about: project["about"] ? "", mono: true, hpf: 0,
			params: params ++ (bright: (default: 1, spec: [0, 1], label: "Brightness", about: "dull ↔ open"),
				tone: (default: 1, spec: [0.05, 2.5, \exp], label: "Tone", about: "global factor (Fog, Tension)")),
			def: def);
		self.checkSound(snd, sndName).do { |p| Error("Sample Designer: " ++ p).throw };
		self.sounds[sndName] = snd;
		self.defs[def.name] = def;
	} { sndName = soundName.asSymbol };

	tags["layout"] = "Sample Designer — " ++ project["name"];
	tags["16"] = "Sample: " ++ project["name"] ++ " · " ++ setupLabel;
	cols.do { |b, i| var n = i + 1, kind = kinds[b["kind"]], at = "16:" ++ n;
		tags[at] = n.asString ++ " " ++ colLabel.(b, i);
		kind["knobs"].do { |kn, j| tags[at ++ ".k" ++ (j + 1)] = kn["label"] ++ " | " ++ kn["about"] };
		tags[at ++ ".fader"] = kind["fader"]["label"] ++ " | " ++ kind["fader"]["about"];
		tags[at ++ ".b1"] = "On | " ++ kind["label"] ++ " on / off.";
		tags[at ++ ".b2"] = "Type | " ++ kind["types"].join(" → ") ++ ".";
	};
	tags["g.k1"] = "Accent | even hits ↔ strong accents.";
	tags["g.k2"] = "Space | dry ↔ room.";
	tags["g.k3"] = "Length | short notes ↔ long notes.";
	tags["g.fader"] = "Master | volume of the sound.";
	tags["g.b1"] = "Pattern | next audition pattern at the next bar.";
	tags["g.b2"] = "Save | writes the project file.";

	track = (
		name: "sample-" ++ project["name"],
		bpm: num.(aud["bpm"], 120),
		tags: tags,
		project: project,
		global: (fog: 125, thin: 126, tension: 127),
		aliases: [20, 28, 36, 12, 44, 52].collect { |c| (c + 48) -> c }.asDict,
		orbits: (1: (ir: "ir/orbit-1.2.wav")),
		states: vals ++ (master: num.(aud["master"], 0.8), room: 0.9 * num.(aud["space"])),
		stems: [(name: \voice, sounds: [sndName], level: 1.0, fade: \master, roomR: \room, orbit: 1, thin: false,
			tensionEcho: false)],
		uiHead: { |t, ce| [["Sample", project["name"]], ["Setup", setupLabel]] ++ (t.saved !? { |s| [["Saved", s]] } ? []) },
		uiGlobal: { |t, ce| var nm = { |i| patterns[i]["label"] };
			(b1: [nm.(t.audPattern.now), nm.(t.audPattern.pending)], b2: ["Save", "Save"]) },
		uiCols: { |t, ce| var rows = (), labels = (), on = ();
			cols.do { |b, i| var id = b["id"], o = ce.stateVal[ce.sampleParam(id, "on")] > 0.5, n = i + 1;
				rows[("jojo:" ++ n).asSymbol] = [if(o) { "On" } { "Off" }] ! 2;
				labels[44 + n] = kinds[b["kind"]]["types"][ce.stateVal[ce.sampleParam(id, "type")]] };
			(rows: rows, labels: labels, designer: t.designerValues(ce)) },
		designerValues: { |t, ce|
			(blocks: cols.collect { |b|
				var id = b["id"], kind = kinds[b["kind"]], v = { |k| ce.stateVal[ce.sampleParam(id, k)] };
				(id: id, on: v.("on") > 0.5, type: kind["types"][v.("type")], level: v.("level"))
					++ kind["knobs"].collect { |kn, j| ("k" ++ (j + 1)).asSymbol -> v.(kn["key"]) }.asDict },
			audition: (pattern: t.audPattern.pending, accent: t.audAccent, space: ce.stateVal[\room] / 0.9, length: t.audLength,
				master: ce.stateVal[\master]))
		},
		build: { |t, ce| ce.sampleBuild(t, cols, kinds, sndName) },
	);
	track.audAccent = num.(aud["accent"]);
	track.audLength = num.(aud["length"], 0.5);
	track
};

// Language side: start values on the controls, the controls' hooks, the audition notes
~ce.sampleBuild = { |self, t, cols, kinds, sndName|
	var ce = self, aud = t.project["audition"], pats, mapped = (), valueAt, lengthOf;
	var push = { ce.uiPush };
	var knob = { |cc, v, fn| ce.cc[cc] = v; ce.onCC(cc, { |x, send| fn.(x, send); push.value }) };
	var press = { |cc, fn| ce.onCC(cc, { |x, send| if(x > 0.5) { fn.(send); push.value } }) };
	cols.do { |b, i|
		var n = i + 1, id = b["id"], kind = kinds[b["kind"]], p = { |k| ce.sampleParam(id, k) };
		kind["knobs"].do { |kn, j| var param = p.(kn["key"]);
			knob.([12, 20, 28][j] + n, ce.stateVal[param], { |x, send| ce.setState(param, x, send) }) };
		knob.(4 + n, ce.stateVal[p.("level")], { |x, send| ce.setState(p.("level"), x, send) });
		press.(36 + n, { |send| ce.setState(p.("on"), 1 - ce.stateVal[p.("on")], send) });
		press.(44 + n, { |send| ce.setState(p.("type"), (ce.stateVal[p.("type")] + 1) % kind["types"].size, send) });
	};
	knob.(20, t.audAccent, { |x| t.audAccent = x });
	knob.(28, ce.stateVal[\room] / 0.9, { |x, send| ce.setState(\room, 0.9 * x, send) });
	knob.(36, t.audLength, { |x| t.audLength = x });
	knob.(12, ce.stateVal[\master], { |x, send| ce.setState(\master, x, send) });
	pats = aud["patterns"].collect { |pt|
		var r = ce.mini(pt["rhythm"]), steps = ();
		r.events.select { |e| e[2].notNil }.do { |e| var s = (e[0] * 16).floor.asInteger;
			steps[s] = (steps[s] ? []).add([(e[0] * 16) - s, e[1] * 16, e[0]]) };
		(period: r.period, steps: steps, notes: pt["notes"] !? { |x| ce.mini(x) },
			velocity: pt["velocity"] !? { |x| ce.mini(x) })
	};
	t.audPattern = ce.latch(1, (aud["pattern"] ? 0).asInteger.clip(0, pats.size - 1), { push.value });
	ce.onPress(44, { t.audPattern.pending = (t.audPattern.pending + 1) % pats.size; push.value });
	ce.onPress(52, { t.saved = Date.getDate.format("%H:%M:%S");
		ce.uiSend('/ce/save', ce.toJSON(t.designerValues(ce))); ce.status("Save", t.project["name"]); push.value });
	valueAt = { |m, time| var u = time % m.period;
		m.events.detect { |e| (e[0] <= u) and: { u < (e[0] + e[1]) } } !? { |e| e[2] } };
	lengthOf = { 2 ** ((t.audLength * 4) - 2) };
	ce.sounds[sndName].params.keysDo { |k| if(ce.stateBus[k].notNil) { mapped[k] = ce.stateMap(k) } };
	t.stems[0][\notes] = { |k|
		var bar = (k / 16).floor, pt = pats[t.audPattern.atBar(bar)], hits = pt.steps[k % (pt.period * 16)] ? [];
		var start = (bar / pt.period).floor * pt.period;
		hits.collect { |h|
			var note = pt.notes !? { |m| valueAt.(m, start + h[2]) } ? 48;
			var vel = pt.velocity !? { |m| valueAt.(m, start + h[2]) } ? 1;
			ce.note(sndName, mapped ++ (freq: note.asFloat.midicps, amp: 1 - (t.audAccent * (1 - vel.asFloat)),
				hold: h[1] * lengthOf.value, at: h[0]))
		}
	};
};
)
