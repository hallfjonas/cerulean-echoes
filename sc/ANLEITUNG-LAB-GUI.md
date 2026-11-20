# Anleitung: Lab-Oberflächen direkt in SuperCollider (Qt)

Stand 19.11.2026. Für schnelle Experimente im Sound Lab: Klänge mit Reglern am Bildschirm erkunden, bevor
entschieden wird, was auf die Launch Control kommt. Alles, was regelmäßig gebraucht wird, wandert später in die
Web-UI (`sc/ui/`, siehe `PLAN-UI.md`).

Die Blöcke unten nacheinander in der SuperCollider-IDE ausführen: Cursor in den Block (zwischen die Klammern),
Cmd-Return. **Nicht gleichzeitig mit `live.scd` laufen lassen** (beide greifen auf Server und MIDI zu).
Stoppen: Cmd-Punkt.

## 1. Server starten

```supercollider
s.boot;
```

## 2. Ein Klang mit Reglern (Ndef + automatische Oberfläche)

Ein `Ndef` ist ein Klang, der sich **im Laufen** austauschen lässt: Code ändern, Block neu ausführen, man hört
sofort die neue Version, ohne Stopp. Damit die Regler sinnvolle Bereiche haben, legt man vorher **Specs** fest
(Bereich und Kurve pro Parametername).

```supercollider
(
// ranges of the controls (name → [min, max, curve]); the GUI finds them by name
Spec.add(\cutoff, [80, 8000, \exp]);
Spec.add(\res, [0.05, 1]);
Spec.add(\decay, [0.05, 2, \exp]);
Spec.add(\drive, [1, 8, \exp]);

// a plucked bass: saw through a resonant low-pass, retriggered by t_trig
Ndef(\lab, { |freq = 55, cutoff = 600, res = 0.3, decay = 0.3, drive = 1, amp = 0.3, t_trig = 0|
	var env = EnvGen.ar(Env.perc(0.005, decay), t_trig);
	var sig = RLPF.ar(Saw.ar(freq), cutoff * (1 + (env * 3)), res);
	(sig * drive).tanh * env * amp ! 2
}).play;

// rhythm: a pattern sets notes and triggers (boards need rhythm, not held notes)
Ndef(\lab)[1] = \set -> Pbind(
	\dur, 0.25,
	\freq, Pseq([55, 55, 110, 55, 82.5, 55, 110, 73.4], inf),
	\t_trig, 1
);
)

// window with one slider per parameter, play/stop, volume
Ndef(\lab).gui;
```

Ändern und neu ausführen: z. B. `Saw` durch `Pulse` ersetzen, den Block erneut ausführen. Die Regler behalten
ihre Werte.

Mehrere Klänge gleichzeitig (jeder mit eigenem `Ndef(\name)`) zeigt das Mischpult:

```supercollider
NdefMixer(s);
```

## 3. Hören und sehen

```supercollider
s.scope;       // oscilloscope (waveform)
s.freqscope;   // spectrum: where the energy sits, e.g. kick vs. bass
s.meter;       // levels in and out
```

Für Vergleiche mit einem Vorbild: die Referenzaufnahme als Buffer laden und abspielen, dann zwischen beiden
umschalten (die A/B-Aufnahmen in `sc/ab/` sind ein Beispiel):

```supercollider
~ref = Buffer.read(s, "/pfad/zur/referenz.wav");
Ndef(\ref, { PlayBuf.ar(2, ~ref, BufRateScale.kr(~ref), loop: 1) * 0.5 });
Ndef(\ref).play;  Ndef(\lab).stop;   // A
Ndef(\lab).play;  Ndef(\ref).stop;   // B
```

## 4. Presets und Würfeln (Quark JITLibExtensions)

Einmal installieren, danach Cmd-Shift-L (Klassenbibliothek neu laden):

```supercollider
Quarks.install("JITLibExtensions");
```

Dann:

```supercollider
(
~pre = NdefPreset(\lab);
~pre.addSet(\start);          // save the current knob positions under a name
NdefPresetGui(~pre, 8);       // list of presets, buttons to store, recall, step through
)

~pre.setRand(0.25);           // roll: random variation around the current state (0 = none, 1 = anywhere)
~pre.addSet(\gefunden1);      // keep what you like
~pre.setCurr(\start);         // back
~pre.morph(0.5, \start, \gefunden1);   // halfway between two presets
```

Das ist im Kleinen der „Würfel-Modus“ aus `PLAN-STEM-LIBRARY.md`. Genaue Methoden und das Speichern auf die
Festplatte: Hilfe zu `NdefPreset` (Cursor auf das Wort, Cmd-D).

## 5. Eigene kleine Fenster

Wenn die automatische Oberfläche nicht reicht, z. B. für ein Step-Raster:

```supercollider
(
var w = Window("steps", Rect(100, 100, 440, 200)).front;
w.addFlowLayout;
~steps = 0.5 ! 16;
// 16 bars: height = brightness per step
MultiSliderView(w, 420 @ 120).size_(16).elasticMode_(1).value_(~steps)
	.action_({ |v| ~steps = v.value });
EZSlider(w, 420 @ 20, "decay", \decay.asSpec, { |ez| Ndef(\lab).set(\decay, ez.value) }, 0.3);

// the pattern reads the raster on every step
Ndef(\lab)[1] = \set -> Pbind(
	\dur, 0.25,
	\freq, 55,
	\cutoff, Pseq((0..15), inf).collect { |i| \cutoff.asSpec.map(~steps[i]) },
	\t_trig, 1
);
)
```

Bausteine: `Slider`, `Knob`, `Button`, `EZSlider` (Regler mit Name und Zahl), `MultiSliderView` (Raster),
`UserView` (frei zeichnen). Übersicht: Hilfe → „Introduction to GUI“.

## 6. Launch Control dazunehmen

Ein Regler der LC steuert denselben Parameter wie der Schieberegler im Fenster (das Fenster folgt mit):

```supercollider
(
MIDIClient.init;
MIDIIn.connectAll;
// LC XL 3, Custom Mode 16 (channel 16 = chan 15): first knob of column 1 = CC 13
MIDIdef.cc(\labCutoff, { |val| Ndef(\lab).set(\cutoff, \cutoff.asSpec.map(val / 127)) }, 13, 15);
MIDIdef.cc(\labRes,    { |val| Ndef(\lab).set(\res,    \res.asSpec.map(val / 127)) }, 21, 15);
)
```

CC-Nummern der Belegung: `CLAUDE.md` im Repo-Hauptordner, Abschnitt „Controller mapping“.

## Grenzen

- Die Klänge aus `sc/sounds/` brauchen die Infrastruktur von `lib/ce.scd` (Samples, Wavetables, Busse) und laufen
  nicht einfach als `Ndef`. Ein kleiner Explorer, der einen Bibliotheksklang lädt und aus seinen `params` (Bereich
  und Name stehen schon drin) automatisch Regler baut, wäre der nächste Schritt.
- Qt-Fenster sind schlicht. Was bleibt und gut aussehen soll, gehört in die Web-UI.
