# Übergabe 009 (Stand 2026-11-08, später Abend) — HIER WEITERMACHEN

Sprache mit dem Nutzer: Deutsch, Code-Kommentare Englisch. Vorher lesen: `CLAUDE.md`, `stems-ideen.md` (Liste
„✗ Verworfen“), `feedback.md` (009, unten die neuesten Einträge), `lab/keys/feedback.md`, `lab/melodie/feedback.md`,
`lab/harmonie/feedback.md`, `lab/einwurf/feedback.md`. Vorherige Übergabe: `uebergabe-nacht-2026-11-08.md`.

## Was diese Sitzung gemacht hat
- Track 009: Vibraphon „Ruf-Echo“ F♯ → F in Moll-Folgen (gepusht, bbe18e2 / 9631f63).
- `lab/melodie/melodie-3.strudel` + `samples/horn-phrases/` (20 echte Trompeten/Sax/Flöten-Phrasen, CC BY 4.0) +
  `tools/phrase-cut/` (gepusht).
- `lab/einwurf/einwurf-1.strudel` Pegel angeglichen (gepusht).
- NICHT committet (bitte committen + pushen, Branch `johannes`):
  - `lab/harmonie/harmonie-5.strudel` (+ PDF): harmonie-4 + Folgen 17–21 (C F Whistle Song, F Em Am G Digital Love,
    Am G/F F Dm Modjo, F C G Am Another Chance, Em Am Keep Me Inside); harmonie-4 nach `old/` (git mv).
    Neue Akkorde/Folgen in `tools/stem-lab/engine3.strudel-part` angehängt (CH: G7/F, G7sus2, Am/C; HARMONIES 17–21).
    Andere Engine-3-Boards wurden NICHT neu gesynct (brauchen es nicht).
  - `lab/keys/house-keys-lab-21.strudel` (+ PDF): 8 Spalten = 1-Takt-Akkord-Riffs mit dem Keys-Groove (RIFFS +
    PEDAL, Bass folgt dem Riff der linkesten offenen Spalte); lab-20 nach `old/` (git mv).
  - `docs/references.md`: Sarah-Wild-Set als Hauptreferenz; Feedback-Einträge in den feedback.md-Dateien.

## Nutzer-Feedback dieser Runde (alles schon in den feedback.md eingetragen, außer den letzten zwei Punkten)
- Einwürfe: ALLE Quatsch (verworfen, in stems-ideen.md). Wenn überhaupt: ikonischere Vocal-Samples.
- Bläser (melodie-3): Trompete/Sax klingen gut, aber zu sparsam, zu lange Pausen = Einwürfe statt Melodien; es muss
  sich etwas aufbauen. Vorschlag (noch nicht gebaut): melodie-4 mit Aufbau-Regler (Reihe 3: 1 Phrase/8 Takte →
  Ruf + Antwort → Phrasen direkt hintereinander; oben auch lebhaftere Phrasen; Spalten pro Instrument zusammenlegen).
- Akkordfolgen: klassischer House, KEIN Progressive House (vi IV V I …).
- Hauptreferenz: Sarah Wild, Fusion 2025 (SoundCloud-Link in docs/references.md). Trackliste (1001tracklists, vom
  Nutzer eingefügt; Seite blockt Bots — nicht umgehen): Pink Floyd – Is There Anybody Out There · Sarah Wild – Fly With
  Me To The Moon · Maltitz – Yepiyano · Hot Since 82 & Tomaz vs. Filterheadz – Sunshine 2025 · Krystal Klear – Deathlagg ·
  Freddie Mercury – Living On My Own · Baron Von Trax – If I Only Knew · Arpeggio – The Fighter · Austher – Expectations ·
  Borai & Denham Audio – Make Me (Paul Sirrell Remix) · L.P. Rhythm ft. Gaskin – In The House · Val Verra – House Music
  Is A Spiritual Thing · Krystal Klear – Detol Samba · Sarah Wild – Disco Extase · Harry Nipples & jo.desaga – Dance Now
  (Piano House Original) · Laroze – Pure Water · Sarah Wild – Drum Extase · Austher – Memory Code · Herr Krank & Deborah
  Aime La Bagarre – Eurogenic · Miguel De Bois – Is Everything Cool? · Demi Riquísimo & Clint – Love State · JOVE – Don't
  Let Me Go · Doctr ft. Daniella – Training (French Version) · Narciss & Gerd Janson – Chicco's Chips. Genre: House, Tech House.
  → in docs/references.md nachtragen.
- Was der Nutzer im Set hört und für 009 will:
  1. Viel House-Piano: nicht nur monoton, auch 8-taktige Folgen, aber immer mit groovigem Rhythmus.
  2. House-Basslines mit viel Groove (Jojo Spalte 4) — „braucht Arbeit, mehr Optionen und bessere“.
  3. Höhere, verspielte Melodie Richtung Flöte, weniger komplex als das Vibraphon (Vibraphon bleibt).
  Acid: super, muss aber nicht sein.
- **Keys-21 (neueste Antwort):** von den Riffs nur „Am D“ (Spalte 6: Am9 3/8 + D9 5/8 in einem Takt) okay. Nutzer:
  „bitte da nochmal den Kerri hinzufügen, weißt du, was ich mein?“ → UNKLAR, nachfragen. Vermutungen: (a) Am D mit dem
  Kerri-Riff-Rhythmus `x..x..x..x..x.x.` bzw. Kerri-Push; (b) das Kerri-Video-Riff (Am Dm Gm) nur mit Am/D-Akkorden.
  Außerdem: „und bitte doch sagen, die über 4 oder 8 Takte gehen“ → wohl: Riffs/Piano, die über 4 oder 8 Takte laufen
  (passt zu Punkt 1: 8-Takt-Folgen mit Groove). Ebenfalls kurz bestätigen lassen.

## Harmonie-Check (Nutzerfrage „auf gute Modulation geachtet?“, 2026-11-08) — NICHTS geändert, Antwort offen
Analyse der 21 Folgen in `harmonie-5.strudel` / Engine 3 (Skript: Stimmen = `stabOf(CH[name], 52, 4)` je Wechsel):
- Gut: Stimmführung eng — gemeinsame Töne bleiben, Sprünge meist 1–2, max. 4 Halbtöne. Wechsel zwischen den Folgen
  am 8-Takt-Anfang (mit Push) bleibt in a-Moll/C-Dur, nur dorisch↔äolisch (F♯/F) — weich, keine echte Modulation.
- Problem 1: Die in `CH` notierten Kerri-Griffe (Septime unten, ohne Grundton) klingen NICHT — `stabOf` sortiert neu ab
  E3: fast immer E3 unten, Em7 in Grundstellung, Fmaj7 = E3 F3 A3 C4 (kleine Sekunde bei 165 Hz = matschig, v. a. mit
  Supersaws); Fadd9 / G11 / G7sus2 enge Cluster um F3/G3.
- Problem 2: Oberstimme fast immer C4/D4 — keine Linie oben (Attack: „highest and lowest notes … give context and melody“).
- Problem 3: Folge 13 „Attack-Beispiel“: Takt 8 muss C♯m7 sein (Überraschungsakkord, so in recherche-harmonie.md R4),
  im Board steht D9. Modjo „Lady“: Bm7♭5/D fehlt.
- Recherche (Attack Magazine: kerri-chandler-chords, …-part2, parallel-chords, passing-notes-deep-house-chords,
  lessons-from-disco-chords/2; Soundfly open-voiced sevenths; NI voice-leading): KC-Stabs ohne Grundton/Quinte, Septime
  unten, gemeinsame Töne halten + oben ergänzen, 1/16 früh zurück; Übergangsakkord geliehen (A7 zwischen A♯m und G♯m,
  „Rain“ ii–V-Ketten); Parallelakkorde = gleicher Griff verschoben (Mommy What's a Record Cm7 → Gm7 → Am7) = sanftester
  Tonartwechsel; Orgelpunkt-Bass darunter; Zwei-Akkord-Vamps tragen viel klassischen House.
- Vorschläge an den Nutzer (Antwort abwarten): A) Griffe wie notiert spielen, Umkehrung pro Wechsel nach kürzesten
  Wegen, unter G3 keine Sekunden (ändert ALLE Folgen → nur mit OK); B) Folge 13 auf C♯m7; C) neue Folgen anhängen:
  „Mommy“ (Am7 → Em7 → F♯m7 parallel über E-Orgelpunkt) + eine Folge mit Übergangsakkord.

## Nächste Schritte (Vorschlag, mit Nutzer abstimmen)
1. Kurz nachfragen: was „den Kerri hinzufügen“ meint; ob 4/8-Takt-Piano-Folgen gemeint sind.
2. **Bass (Priorität laut Nutzer):** erst recherchieren (Quellen notieren in einer `recherche-bass.md`): wie klassische
   House-/Piano-House-Basslines gebaut sind (Synkopen, Oktavsprünge, Ghost Notes, Slides, Klänge: M1-/Juno-/Organ-Bass,
   Sub + Mitten), möglichst an Tracks aus der Trackliste (Beschreibungen, Analysen). Bestehendes prüfen: `lab/bass/`
   (Ordner + feedback.md) und Jojo 4 in `009-house-dual.strudel` (3 Linien, Sinus + Oktave + Square, Ghost-Improviser).
   Dann Bass-Lab mit vielen Kandidaten-Spalten (Engine 3, folgt den Akkordfolgen; Kontext: Drums, Keys).
3. Keys-22: „Am D“ als Basis + Kerri-Variante(n) + Piano mit 4/8-Takt-Folgen im Keys-Groove (die 8 Rhythmen auf Taste 1).
   Idee: Keys-Spalte im Track bekommt die Riffs über die freie Taste im Klang-Modus (Runde 20 offen) statt eigene Spalte.
4. melodie-4 (Bläser mit Aufbau) und eine Flöten-Melodie-Spalte (verspielt, einfache Motive, höher).
5. Spaltenplan Jonas 4–7 (Entwurf): Piano/Folge · Flöte hoch · Bläser · offen (Vocal-Hook nur mit guten Samples).

## Arbeitsregeln (Kurzfassung)
Labs nicht ungefragt umbauen; Verworfen-Liste beachten; recherchieren mit Quellen; vor Übergabe
`node tools/strudel-sim/transpile-check.mjs`, Rechenzeit ≲ 8 ms/Tick, Samples in Headless-Chrome dekodieren
(`tools/phrase-cut/chrome-decode.mjs`); Lab-Runden: neue Datei, alte nach `old/`; Track-Änderungen: make-single,
gen-layout, make-syx, `npm run set`. M2 Air geteilt: ein schwerer Job, keine Hintergrundprozesse.
