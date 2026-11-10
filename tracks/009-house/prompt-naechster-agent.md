# Prompt für den nächsten Agenten (Track 009, Stand 2026-11-08)

Kopiere den Block unten als ersten Auftrag in die neue Sitzung.

---

Du arbeitest im Repo `cerulean-echoes` (Strudel-Live-Tracks für zwei Novation Launch Control XL 3). Sprich Deutsch mit
mir, Code-Kommentare bleiben Englisch. Lies zuerst `CLAUDE.md`, dann für den Track 009:
`tracks/009-house/stems-ideen.md` (oben die Liste „✗ Verworfen“ – nichts davon wieder einbauen),
`tracks/009-house/feedback.md`, `tracks/009-house/uebergabe-harmonie-in-009.md` (was zuletzt gebaut wurde) und die
`feedback.md` in `lab/harmonie/`, `lab/melodie/`, `lab/einwurf/`.

**Ziel des Projekts:** eine niederschwellige MIDI-Belegung, mit der Leute ohne Vorkenntnisse bei einem Treffen
gemeinsam spielen; alles muss leicht gut klingen. Track 009 = klassischer House (124 BPM, A-Moll). Jojo = Rhythmus
(8 Spalten), Jonas = Farbe (Spalten 1–7) + globale Spalte 8.

**Stand Jonas (Track 009):**
- Spalte 1 Harmonie (JX-10 ↔ B3, gehaltene Akkorde) mit 10 Akkordfolgen auf Taste 1; Chapter (Spalte 8) Vamp = Am9,
  Wechsel = gewählte Folge. Keys bleiben bewusst monoton auf Am9 (nur in „Am9 D9“ D9). Nutzer: „die drei
  Harmonie-Sachen sind super“ (Harmonie-Spalte, Akkordfolgen, monotone Keys).
- Spalte 2 Keys, Spalte 3 Vibraphon (aus `lab/melodie/melodie-2`), Spalten 4–7 leer.

**Ich bin heute Abend weg und kann nichts anhören.** Arbeite selbstständig an dem, was ohne mein Gehör geht, und
präsentiere mir morgen früh die Ergebnisse (kurz, auf Deutsch: was gebaut ist, was ich anhören soll, was offen ist).
Keine Rückfragen nötig; wo du entscheiden musst, nimm die naheliegende Variante und schreib die Entscheidung auf.
Den Track 009 nur für Punkt 1 ändern; alles andere als Lab-Board vorbereiten, nichts ungehört in Tracks übernehmen.

**Heute Abend (in dieser Reihenfolge):**
1. **Vibraphon-Phrase „Ruf-Echo“** (Track 009, Jonas 3) enthält F♯; in den aeolischen Folgen (alle außer „Am9 D9“)
   reibt das. F♯ → F, wenn `modeAt(bar) === 'aeolian'` (sonst unverändert). Danach die üblichen Track-Schritte
   (siehe Arbeitsregeln) inkl. `npm run set`.
2. **Zweite Melodie-Spalte (Jonas 4): echte Bläser-Phrasen als Lab vorbereiten.** Trompeten aus
   Einzelton-Multisamples sind verworfen (nicht warm, mechanisch); im ersten Sample-Lab waren schnelle, unruhige
   Jazz-Phrasen und 1-Takt-Loops schlecht. Plan: längere echte Aufnahmen (z. B. Freesound 424876 / 424894
   emirdemirel „Improvisation on Dorian“ Trompete / Sax, CC BY; 77706–77717 sorohanro Trompeten-Phrasen, CC BY; weitere
   nur mit Quelle und freier Lizenz) an Pausen in Phrasen schneiden, per Analyse (Tonhöhe, Tonanzahl pro Sekunde) nur
   ruhige behalten (wenige, lange Töne), nach A (dorisch/aeolisch) transponieren, Credits notieren. Lab
   `lab/melodie/melodie-3.strudel` (Engine 3): pro Spalte ein Instrument/Quelle, Taste 1 = nächste Phrase,
   Einsatz auf Phrasenpunkten (alle 4 bzw. 8 Takte), Reihe 3 = wie oft; das Vibraphon aus melodie-2 als Vergleich
   drinlassen. Quellen/Hinweise: `tracks/009-house/recherche-melodien.md`. Lieber 10–20 gute Kandidaten als viele
   mittelmäßige; alle in Headless-Chromium laden/dekodieren.
3. **Einwurf-Lab prüfen:** `lab/einwurf/einwurf-1.strudel` ist gebaut, aber nie gehört. Nur technisch prüfen
   (Transpiler, Rechenzeit, Samples laden in Chromium, Pegel grob angleichen) und Auffälliges notieren; nichts
   inhaltlich umbauen.
4. **Morgen-Übersicht** oben in `tracks/009-house/stems-ideen.md` („▶ Für morgen früh“) und im Übergabe-md:
   was zum Anhören bereitliegt, mit Dateipfaden, worauf ich achten soll, was nicht geprüft werden konnte.
5. Zum Schluss committen und auf Branch `johannes` pushen (Commit-Nachricht wie im Repo üblich).

**Danach, mit mir abzustimmen (nicht heute):** Harmonie im Browser anhören und feinschleifen (nur in Node getestet:
Pegel gegen Keys, Akkordwechsel, Rechenzeit); Gewinner aus melodie-3 und einwurf-1 mit dem Skill `lab-to-track` in
Jonas 4–6 übernehmen; Launchkey-Pads später (Sammlung in `samples/pads/`).

**Arbeitsregeln (wichtig, wurden oft verletzt):**
- Vor jedem Bauen die Verworfen-Liste und die feedback.md lesen; Abgelehntes sofort raus, pro Runde lieber mehr
  Optionen/Komplexität als kleine Schritte.
- Recherchieren mit Quellen, nichts erfinden; was unbelegt ist, so benennen.
- Lab-Boards: `lab/<rolle>/<rolle>-N.strudel`, alte Runden in `old/`; Engine 3 via `node tools/stem-lab/sync.mjs`
  (läuft automatisch die Transpiler-Prüfung).
- Vor jeder Übergabe: `node tools/strudel-sim/transpile-check.mjs <dateien>` (fängt z. B. doppelte Anführungszeichen,
  die Strudel als Mini-Notation liest), Rechenzeit pro Scheduler-Tick in Node messen (≲ 8 ms), neue Samples in
  Headless-Chromium laden/dekodieren (Playwright-Chromium unter `~/Library/Caches/ms-playwright`).
- Track-Änderungen: `make-single.mjs`, `gen-layout.mjs` (Layout-PNG auf Textüberlauf prüfen), `make-syx.mjs`, danach
  `npm run set` in `tools/` (Set 011 wird aus den Tracks gebaut; check-set zeigt für 009 bekannte Start-Abweichungen,
  siehe feedback.md).
- Taste 1 unter dem Fader = Wechseln (Muster bzw. Akkordfolge), Taste 2 = Moment; Labels ohne Theorie-Begriffe.
- Den Plan und Stand laufend in einer Übergabe-md im Track-Ordner dokumentieren (falls dir die Rechenzeit ausgeht,
  muss ein anderer Agent dort weitermachen können).
- Rechner: M2 Air, geteilt; nur ein schwerer Job gleichzeitig, keine Hintergrundprozesse zurücklassen.
