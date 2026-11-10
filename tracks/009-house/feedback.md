- viel zu viele harmonsiche lines; piano + rhodes unnötig; dann lieber einen slider für den veränderten klang; 
- piano line und rhodes und auch manche der anderen lines richtig schwach; rhythmisch vor allem; kannst du dir nicht gut house samples raus suchen? das ist viel ikonischer,nicht einfach so simpel im tackt
- wir bruachen verspieltere oberstimmen; bei denen kann auch randomization wichrig sein, damit es nicht langweilig wird 


## Umsetzung in 009 dry (2026-11-05)
- Piano, Piano-Riff, Orgel, Rhodes → eine Spalte **Keys** (Jonas 1), Reihe 3 = Klang: M1-Piano → Flügel → Rhodes → Orgel
- Keys-Rhythmen synkopiert: 3-3-2, Push in den nächsten Takt, Gospel mit Ghost-Akkorden, Ruf
- House-Samples (Dirt-Samples): Trompeten-Stabs (Horns), Tenor-Sax, gesungenes „ah“ (Vocal), Rave-Shouts (Vocal, Knopf 2)
- Oberstimmen Horns / Sax / Vocal / Pluck / Marimba aus einem Improviser: Riff wiederholt sich (Play = 0), Play hoch = Zufallsvarianten; Knopf 1 = nächstes Riff
- Orch Hit raus, Pad nach Spalte 7; Bass-Ghosts (Jojo 4, Reihe 3) jetzt zufällig


- keine veränderung über die 8 takte! beständigkeit ist super wichtig im house / techno! und manche der variationen sind schlecht, also kann ich fast nicht sagen, was mir gefällt, weil oft eine variation dann weird ist... kannst du das als erstes anpassen? 
- gut: 

## 009 house (2026-11-06) — new base after the keys lab
- New file 009-house-dual.strudel; cool, happy and dry versions moved to old/. Rhythm section (Jojo) as in 009 dry.
- Jonas 1 Keys = the keys lab result (lab/keys round 19): Steinway ↔ Rhodes Mark I (row 3), Kerri voicing (Am9 G B C E,
  D9 F♯ A C E), 8 stab rhythms with push, accent before rests with brighter accents (overtones at half), brightness
  per sound over its own range (knob 0 = warm, not muffled), button 2 echo. −21 LUFS at fader 1 (kick −14, clap −23.5).
- Jonas 2-7 empty for now (horns, sax, vocal, pluck, marimba, pad removed with their samples).
- Note: kick + keys both at fader 1 peak at 1.16 (offline): leave headroom on the faders.
- Transfer fixed (user: a lab column goes 1:1 onto a track column): Jonas 1 now has exactly lab 19 column 2's controls
  (Brightness, Space, Length, Level, button 1 = 8 rhythms, button 2 = shift: knobs = sound mix piano → Rhodes, B3 →
  M1, vibes → marimba, fader = overtones), its swing (56 %), space mapping and start values. Track additions: chords
  from Chapter (D9 voicing F♯ A C E), global Fog / Room / Tension. −21 LUFS at the lab's settings. New skill:
  .claude/skills/lab-to-track.

## Vibraphon → Jonas 3 (2026-11-07)
- Aus lab/melodie/melodie-2 Spalte 1, 1:1 (Hell, Weich, Komplex, Pegel, Taste 1 Phrase, Taste 2 Echo-Wurf); 40 % lauter
  als im Labor (Nutzer: 30–50 %). Akkorde vom Kapitel (Am9 / D9) statt der Labor-Progressionen; eigener Orbit 3.
- Jonas 2 bleibt frei für die Harmonie (harmonie-4). Offen: Track auf die 16 Akkordfolgen umstellen.
- Set 011 nicht neu gebaut: make-set scheitert seit dem Keys-Port an `await samples(…)` in 009 (nicht durch diese Änderung).

## 2026-11-08 — Harmonie-Spalte + Akkordfolgen (aus lab/harmonie/harmonie-4, Spalte 2)
- Jonas 1 = Harmonie (JX-10-Strings ↔ B3 16'+8' auf Reihe 3, gehaltene Akkorde, Echo-Wurf), Taste 1 = nächste von
  10 Akkordfolgen (nächste 8-Takt-Phrase). Keys auf Jonas 2 verschoben (unverändert).
- Chapter (Jonas 8): Vamp = alle Am9; Wechsel = die Folge von Jonas 1 (Start: Am9 D9 = wie bisher).
- Keys bleiben monoton auf Am9 (Nutzer: Keys sind nicht für Akkordfolgen da); nur in „Am9 D9“ gehen sie auf D9.
  Sub, Bass, Harmonie und Vibraphon folgen der Folge; Vibraphon-Tonleiter dorisch/aeolisch je Folge.
- Nur Folgen, die unter Am9 nicht reiben (kein F♯ außer Am9 D9). Nicht gehört; Harmonie −27,8 LUFS bei Fader 1.
- Set 011 neu gebaut (make-set: Track-Funktionen jetzt async, weil 009 Samples mit await lädt). check-set: 009 zeigt
  Abweichungen nur im allerersten Moment (erster Harmonie-Anschlag bei 0 bzw. Keys bei 0.07: Reihenfolge, in der die
  Regler-Zustände beim ersten Abfragen gesetzt werden), sonst identisch.

## 2026-11-08 (Nacht) — Ruf-Echo ohne Reibung
- Vibraphon (Jonas 3) „Ruf-Echo“: F♯ → F, wenn die Folge aeolisch ist (`vibModeFix`, `modeAt`); Vamp und „Am9 D9“
  unverändert. Set 011 neu gebaut; check-set unverändert gegenüber vorher (Start-Abweichungen, bei „ride“ in Takt 0–1).

## Akkordfolgen (Nutzer, 2026-11-08)
- Progressive-House-Folgen (audiblegenius-Artikel: vi IV V I usw.) nein: eher klassischer House.

## Referenz Sarah Wild (Fusion 2025, Nutzer 2026-11-08) — was 009 noch braucht
- Viel House-Piano: nicht nur monoton, teils 8-taktige Akkordfolgen, aber immer mit gutem, groovigem Rhythmus.
- House-Basslines mit viel Groove: da ist noch Bedarf (Jojo-Seite).
- Höhere Melodien, Richtung Flöte: verspielt, aber weniger komplex als das Vibraphon-Solo. Vibraphon bleibt.
- Acid: super, muss aber nicht sein.

## 2026-11-08 (Nacht) — Flöte → Jonas 4
- Aus lab/melodie/melodie-4 Spalte 6 („Flöte höher“), 1:1 (Hell, Raum, Verspielt, Pegel, Taste 1 Motiv, Taste 2 Echo-Wurf),
  echte Flötentöne aus den juskiddink-Phrasen (begin/end/speed), Motive auf den Akkordtönen ab G4, Orbit 3 (mit Vibraphon).
- Einzige Abweichung: Akkorde aus dem Track (Kapitel + Folge, Push 2/16). Pegel: Nutzer „zu leise“ → Gain 0,6 → 2,0;
  offline im Track bei Fader 1 −23,9 LUFS = Vibraphon (−23,8). Nicht gehört.
- make-single, make-syx (009 + Set), Layouts (in der Cloud erzeugt, typst fehlt auf dem Gerät), Set 011 neu gebaut;
  check-set: 009 wie bisher nur Start-Abweichungen (erster Harmonie-Anschlag), sonst identisch.

## 2026-11-08 abends — neuer Bass (Jojo 4) aus lab/bass/house-bass-4
- Nutzer: Klänge FM und M1 gut, Warm (hart) am besten; Rund schlecht → Reihe 3 = Klang FM → M1 → Warm (gleiche Leistung).
  Noten der Linien: 1 → 2, 2 → 4, 3 → 3, 4 → 2, 5 → 3, 6 → 2, 7 → 2, 8 → 2, 9 → 2 (wie 8), 10 → 2+, 11 → 2+ (wie 10),
  12 → 4, 13 → 2, 14 → 2+, 15 → 3−, 16 → 3. Mehr als 3 Optionen auf Taste 1 sind ok, wenn verschieden und gut.
- Im Track: Taste 1 = 6 Linien (Lab 14, 10, 1, 4, 7, 13), Taste 2 Oktave, Reihe 1 Hell (je Klang eigener Bereich), Reihe 2
  Raum; der alte Ghost-Improviser (Groove) ist raus. Länge fest auf dem Lab-Startwert. Pegel: wie der alte Jojo 4 (−24,2
  LUFS bei Fader 1, Knöpfe 0). Single, syx, Layouts, Set neu; check-set wie bisher. Nicht gehört.

## 2026-11-08 — Variante „riffs“ (009-house-riffs-dual.strudel, neue Datei; 009-house-dual und Set unverändert)
- Keys (Jonas 2) Taste 1: die 8 monotonen Rhythmen wie bisher, danach 6 Riffs aus keys lab 23 mit eigenen Akkorden und
  eigenem Rhythmus (Kerri-Video, Checkmate, Turn Off, Atmosphere, Chicago, Retro-Disco), 1:1 aus dem Lab. Ein Riff beginnt
  bei seinem ersten Takt, wenn er gewählt wird. Kerri-Riff (monoton) noch drin.
- Nicht gekoppelt (Nutzer: erst mal so testen): für einen Riff Chapter auf Vamp → Bass und Harmonie auf A als Orgelpunkt.
  Über A rau nur Checkmates Gm (kleine None A–B♭). Nächste Stufe, falls nötig: Harmonie fällt bei Riff automatisch auf Am9.
- Node: transpile ok (dual + single), Riffs ab Takt 1 und Rückkehr zu monoton geprüft, ~1,2 ms/Tick für die Keys. Nicht gehört.

## 2026-11-08 nachts — Bläser → Jonas 5 (aus lab/blaeser/disco-blaeser-3)
- Nutzer: „Auf der a“ und „Schweller + Fall“ raus, die übrigen sechs Figuren so in den Track.
- Jonas 5 = ganzer Satz (SSO Trompeten, Hörner, Posaunen), Reihe 3 Komplexität, Taste 2 gehalten = Steigerung wie im Lab.
  Einzige Abweichungen (eine Spalte hat nur zwei Tasten): Taste 1 = die sechs Figuren (im Lab: je eine Spalte; Taste 1 war
  Solo ↔ Ensemble) → im Track nur Ensemble; Akkorde aus dem Track (Kapitel + Folge, Push 2/16); Orbit 3 mit Vibraphon und
  Flöte (Raumgröße 2 statt 2,5).
- Pegel: Lab-Gain 0,9 = −14,6 LUFS bei Fader 1 (offline in der Cloud gerendert) → BRASS_LEVEL 0,42 = −21 LUFS (= Keys);
  Flöte −23,9 zum Vergleich. Nicht gehört.
- Komplexität wird gerade in einem eigenen Lab überarbeitet (Nutzer: fügt nur Schläge hinzu, zu wenig Steigerung).
- single, syx, Layouts (Cloud), Set 011 neu gebaut. check-set: 009 wie bisher nur Abweichungen im allerersten Moment
  (Reihenfolge, in der die Regler-Zustände beim ersten Abfragen gesetzt werden; jetzt auch je ein Bläser-Hit), sonst identisch.

## 2026-11-08 spät — Streicher → Jonas 6, Gitarre → Jonas 7 (aktueller Stand, NICHT gehört)
- Nutzer: „den aktuellen Stand in den Track einfügen“. Jonas 6 = lab/streicher/disco-streicher-4 (alle fünf Figuren auf
  Taste 1, Reihe 3 Aufbau, Taste 2 gehalten Steigerung), Jonas 7 = lab/gitarre/disco-gitarre-3 (alle acht Linien auf
  Taste 1, Reihe 3 Komplexität in 4 Stufen, Taste 2 gehalten Steigerung mit Phaser, Klang „offen“, hohe Saite).
- Abweichungen wie bei den Bläsern: Taste 1 = Figuren statt Ensemble/Solo bzw. offen/gedämpft (nur Ensemble / offen);
  Akkorde aus dem Track; Orbit 3, Raumgröße 2; Gitarre mit dem punktierten 1/8-Echo von Orbit 3 statt 1/8.
- Pegel offline (Cloud): Streicher Lab-Gain 0,9 = −17,3 LUFS → 0,59 (−21 LUFS = Keys, Bläser); Gitarre 1 = −15,3 LUFS →
  0,38 (−23,8 LUFS = Vibraphon, Flöte); Bläser −21,3.
- Offen: Gitarrenklang (lab/gitarre/gitarren-klaenge-1), Bläser-Komplexität (lab/blaeser/komplexitaet-1), Streicher-Klang
  prüfen (cheap/knacksig behoben?).
- single, syx, Layouts (Cloud), Set 011 neu gebaut; check-set: 009 nur Abweichungen im allerersten Moment, sonst identisch.
- Hinweis: 009-house-riffs-dual.strudel (+ single, syx, Layouts, 22:24) stammt aus einer anderen Sitzung; nicht angefasst.
