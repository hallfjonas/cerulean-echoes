# Sound-Bibliothek

Jeder Klang ist **eine Datei** `<name>.scd`, die ein Event in festem Format zurückgibt. Tracks verweisen per Name
(+ Preset) auf Klänge und kopieren keinen Klang-Code. Ein Klang ist „fertig“ (darf in die Bibliothek), wenn
`~ce.checkSound` nichts findet (wird beim Laden geprüft).

```
(
name:    \kick909,                 // = Dateiname
role:    \kick,                    // kick, bass, sub, hats, keys, pad, lead, perc, fx, …
about:   "…",                       // eine Zeile: was der Klang ist, woher er kommt
mono:    true,                     // Bass und Kick mono, alles andere darf Stereo sein
hpf:     0,                        // Default-Hochpass in Hz (0 = keiner); Thin multipliziert ihn
samples: (bd: "tr909/bd-01.wav"),  // optional: Buffer-Argument → Pfad unter sc/samples/
params:  (                         // jeder Parameter: Default, Wertebereich, Name auf dem Controller
  punch: (default: 0, spec: [0, 1], label: "Punch", about: "tight ↔ hard"),
),
def: SynthDef(\ce_kick909, { |out, amp = 1, hold = 0.1, …| … })
)
```

Standard-Eingänge jedes SynthDefs: `out` (Stereo-Bus des Kanals), `amp` (linear), `hold` (Notenlänge in Sekunden,
der Klang endet selbst nach hold + Release, kein `gate`). Außerdem `post` (linear, ganz am Ende der Kette): der Fader beim Anschlag der Note, wie
Strudels `postgain` — die Engine setzt ihn, ein Fader wirkt so erst ab der nächsten Note. Klänge mit Tiefpass haben außerdem `bright` (0..1),
`lo`/`hi` (Hz) und `tone` (globaler Faktor aus Fog/Tension). Regler-Parameter sind in den Tracks auf Control-Busse
gemappt und wirken damit auch auf schon klingende Töne.

Hüllkurven und Filter folgen superdough (Strudel): `~ce.adsr` bildet `getParamADSR` nach, WebAudio-Biquads haben
Q in dB (`~ce.rq`).
