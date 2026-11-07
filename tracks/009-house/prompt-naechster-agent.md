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

**Was noch fehlt (in dieser Reihenfolge mit mir abstimmen, nicht alles auf einmal bauen):**
1. **Anhören & Feinschliff Harmonie im Browser** (wurde nur in Node getestet): Pegel der Harmonie-Spalte gegen Keys,
   Akkordwechsel, Rechenzeit (stottert es?). Mein Feedback abwarten.
2. **Vibraphon-Phrase „Ruf-Echo“** enthält F♯; in den aeolischen Folgen (alle außer „Am9 D9“) reibt das. Vorschlag:
   F♯ → F, wenn `modeAt(bar) === 'aeolian'`.
3. **Zweite Melodie-Spalte (Jonas 4): echte Bläser-Phrasen.** Trompeten aus Einzelton-Multisamples sind verworfen
   (nicht warm, mechanisch). Plan: längere echte Aufnahmen (z. B. Freesound 424876 / 424894 emirdemirel
   „Improvisation on Dorian“ Trompete / Sax, CC BY; 77706–77717 sorohanro Trompeten-Phrasen, CC BY) an Pausen in
   Phrasen schneiden, nur ruhige (wenige, lange Töne) behalten, nach A transponieren, in einem Lab
   (`lab/melodie/melodie-3`) als Auswahl anbieten. Ich wähle nach Gehör. Quellen in
   `tracks/009-house/recherche-melodien.md`.
4. **Einwürfe (Jonas 5–6):** `lab/einwurf/einwurf-1.strudel` ist gebaut (Rufe, yeah yeah yeah, Jubel, Flöten-Triller,
   Flöten-Lauf, Zither-Gliss, Posaunen-Fall, Cuíca; Reihe 3 „Wie oft“, Taste 1 „Jetzt!“), aber noch nicht gehört →
   erst mein Feedback holen, dann Gewinner mit dem Skill `lab-to-track` übernehmen.
5. **Launchkey-Pads später:** Sammlung in `samples/pads/` (Flöten-Triller ohne Drop, „yeah yeah yeah“).

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
- Den Plan und Stand laufend in einer Übergabe-md im Track-Ordner dokumentieren.
