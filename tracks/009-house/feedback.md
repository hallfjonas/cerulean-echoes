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
