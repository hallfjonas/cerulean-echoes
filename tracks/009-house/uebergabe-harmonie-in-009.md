# Übergabe: Harmonie-Spalte + Akkordfolgen in Track 009 (Stand 2026-11-08, laufend)

Für einen anderen Agenten, falls diese Sitzung abbricht. Sprache mit dem Nutzer: Deutsch; Code-Kommentare Englisch.

## Auftrag (vom Nutzer bestätigt)
- `lab/harmonie/harmonie-4.strudel`, Spalte 2 „Liegend, B3 sanft“ 1:1 auf **Jonas Spalte 1** von
  `tracks/009-house/009-house-dual.strudel` (Skill `lab-to-track`).
- Die bisherigen **Keys** (Jonas 1) ziehen auf **Jonas Spalte 2** (Code unverändert, nur Spalte/CCs/Tags/COLVIEW).
- **Akkordfolgen**: Taste 1 der Harmonie-Spalte schaltet durch 10 Folgen (Wechsel zur nächsten 8-Takt-Phrase).
  Der Chapter-Knopf (Jonas 8, Taste 1) bleibt: **Vamp** = alle auf Am9; **Wechsel** = die auf Jonas 1 gewählte Folge.
- **Die Keys bleiben monoton** (Nutzer: Keys sind nicht für Akkordfolgen da): Am9, nur in Folge 1 „Am9 D9“
  (= der bisherige Wechsel) gehen sie wie bisher auf D9. Harmonie-Spalte, Sub, Bass (+ Ghosts) und Vibraphon
  (Jonas 3) folgen der Folge.
- Nur Folgen, die unter dem Am9 der Keys (G H C E) nicht reiben (kein F♯ außer Folge 1):
  1 Am9 D9 (Keys folgen) · 2 Am7 C Em7 · 3 Am F G · 4 F G Am · 5 Em7 Fmaj7 · 6 Fmaj7 G · 7 F Am C Dm ·
  8 Am7 Dm7 · 9 C F Am Em · 10 F Em Am. Akkordreihenfolgen aus Hooktheory (recherche-harmonie.md), Taktlängen
  aus dem Lab (engine3 HARMONIES). Folge 1 dorisch, 2–10 aeolisch (Vibraphon-Tonleiter folgt).

## Plan / Stand
1. ☑ Track gelesen, Backup: Scratchpad `009-before.strudel` (nicht im Repo).
2. ☑ Umbau in `009-house-dual.strudel`:
   - CHORDS = Liste aller Akkord-Objekte (Am9, D9 + Am7 Cmaj7 Em7 Fmaj7 Fadd9 Gadd9 G11 Dm7; Bässe E1–D2 um A1),
     PROGS (10 Folgen à 8 Takte), `progLatch = barLatch(8)`, `chordIdAt(bar)`; `harmId` = Folge (für Sub, Bass,
     Ghosts, Vibraphon, Harmonie), `keysHarm` = Am9 bzw. Folge 1 (für die Keys).
   - Harmonie-Spalte (Jonas 1): JX-10 ↔ B3 16'+8' auf Reihe 3 (gleiche Leistung, Gate bei 0), gehaltene Akkorde
     (Lab-`padPat`, Push 2 Sechzehntel), Lab-Kanalzug (Hell 400–6000 Hz ±2 dB, Raum: 1/8-Echo dann Hall, Echo-Wurf
     auf Taste 2), Orbit 3 (wie Vibraphon), COLVIEW 'jonas:1', Status-Zeile 0 = „Akkorde“.
   - Keys: `colJonas(1)` → `colJonas(2)`, `@ctl 16:1.*` → `16:2.*`, COLVIEW 'jonas:2', `stemN2_keys`, `keysHarm`.
   - Vibraphon: Grundton-Stufe für alle Akkorde, Tonleiter dorisch/aeolisch je Folge.
   - Statusbox / LC-Ansicht: „Akkorde“ zeigt die Folge, Zyklus 8 Takte.
3. ☑ Prüfen (Transpiler dual + single ok; Harness: Vamp/Folgen 1,3,5,7 Takt für Takt ok, Keys bleiben Am9; nach Optimierung ~5 ms pro Tick (vorher 2 ms ohne Harmonie); Harmonie offline −27,8 LUFS bei Fader 1 = wie im Lab, 6–7 dB unter den Keys): `node strudel-sim/transpile-check.mjs`, Node-Harness (Akkorde pro Takt in Vamp / jeder Folge, Keys
   bleiben Am9), Rechenzeit pro Tick (`tcpu`-Skript: Harness `run` über 8 Takte), Pegel der Harmonie-Spalte offline
   (`BPM=124 node strudel-sim/render.mjs <file> stemN1_harm '{"5":1,"12":1}'`) gegen Keys.
4. ☑ `node lcxl-layout/make-single.mjs`, `gen-layout.mjs` (dual + single), `make-syx.mjs`; Layout-PNG prüfen.
5. ☑ Set 011 neu bauen (make-set.mjs: Track-Wrapper async wegen `await samples` in 009; check-set: nur Start-Abweichungen, s. feedback.md): `npm run set` in `tools/` (baut + `check-set.mjs`).
6. ☑ feedback.md + stems-ideen.md nachgetragen; Nutzer berichtet. **Fertig** — offen: im Browser anhören.

## Bekannte Punkte
- Der Escravos-Ruf des Vibraphons (Phrase 3) enthält F♯: reibt in den aeolischen Folgen (wie im Lab).
- Andere Sitzungen haben heute ebenfalls an 009 gearbeitet (Vibraphon auf Jonas 3): vor dem Schreiben Datei neu lesen.
