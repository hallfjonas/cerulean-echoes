# Übergabe 009 (Stand 2026-11-08, nach Mitternacht) — HIER WEITERMACHEN

Sprache mit dem Nutzer: Deutsch, Code-Kommentare Englisch. Vorher lesen: `CLAUDE.md`, `stems-ideen.md` (Verworfen-Liste),
diese Datei, die vorige Übergabe `uebergabe-2026-11-08-abend.md` (offene Harmonie-Vorschläge A–C).

## Entscheidungen des Nutzers (diese Sitzung)
- Bass hat Priorität; ebenso: wie die 4 freien Spalten Jonas 4–7 gefüllt werden.
- Spaltenplan (von mir vorgeschlagen, Nutzer: „macht mal“): Jonas 4 Flöte hoch · 5 Bläser mit Aufbau · 6 Acid (Nutzer:
  „prinzipiell super, hier noch nicht überzeugt, es gibt auch Groove-Techno — ausprobieren“) · 7 Vocal-Hook nur mit
  ikonischen Samples, sonst frei. House-Piano mit 4/8-Takt-Folgen NICHT als eigene Spalte, sondern über die Keys.
- „Den Kerri hinzufügen“ = das Riff aus dem Kerri-Video (Am9 Dm9 Gm9).
- „Auf gute Modulationen achten“ (Akkordübergänge): in allen neuen Labs umgesetzt (s. u.).

## Neu gebaut (alles NICHT gehört; in Node geprüft: Noten je Takt, transpile ok, ≤ 3,6 ms/Tick mit allen Spalten)
1. `lab/bass/house-bass-1.strudel` (+ PDF) — 8 Bass-Stile für Jojo 4, Engine 3 (alle 21 Folgen): M1-Orgel, Juno,
   Disco-Oktaven, Grundton-Rhythmus, Daft Punk (FM), Akkordton-Themen (8 Takte), Jojo 4 wie im Track, Deep-Sub-Ostinato.
   Annäherungstöne in jeden Wechsel (A = Halbton drunter, B = Skalenton drüber, B A = Umspielung), Push 2/16.
   Pegel offline alle −25 LUFS (= Jojo 4). Recherche + Quellen: `recherche-bass.md`.
2. `lab/keys/house-keys-lab-22.strudel` (+ PDF; Lab 21 → old/, per mv) — 1 Am D, 2 Kerri-Video-Riff (eigener Rhythmus
   zuerst auf Taste 1), 3–8 Piano-Folgen über 4/8 Takte im Keys-Groove, Griffe von Hand mit Oberstimmen-Linie.
3. `lab/melodie/melodie-4.strudel` (+ PDF; melodie-3 → old/) — Bläser-Phrasen mit Aufbau-Regler (Reihe 3, 4 Stufen),
   eine Spalte pro Instrument + Trompete↔Sax; Flöten-Melodie aus echten Flötentönen (aus den juskiddink-Phrasen per
   begin/end/speed, keine neuen Dateien). Pegel NICHT gemessen (Samples hier offline nicht renderbar).
4. `lab/acid/acid-1.strudel` (+ PDF, neuer Ordner) — 303-Linien (Noten/Accent/Slide), Reihe 3 = Acid, 6 Kandidaten,
   alle −21 LUFS offline.
Feedback-Einträge: `lab/{bass,keys,melodie,acid}/feedback.md`.

## Offen
- NICHTS committet/gepusht: die Geräte-Shell hat kein Netz (kein push), und git braucht Lösch-Rechte (Lock-Dateien).
  Inklusive der Dateien aus der vorigen Übergabe (harmonie-5, keys-21, references.md …). Renames per `mv`, nicht `git mv`.
- Harmonie-Vorschläge A–C aus der vorigen Übergabe: in Keys-22 umgesetzt (Griffe von Hand, C♯m7, „Mommy“-Parallelfolge);
  harmonie-5 / Engine 3 selbst unverändert (Folge 13 dort noch D9) → harmonie-6 nur nach OK.
- Sarah-Wild-Trackliste ist jetzt in `docs/references.md`.
- Nach dem Anhören: Gewinner per `lab-to-track` in Jojo 4 / Jonas 4–6; Vocal-Hook (Jonas 7) erst mit guten Samples.
- Werkzeug-Notiz: `typst` fehlt auf dem Gerät; Layout-PDFs wurden in der Cloud-Umgebung erzeugt (gen-layout.mjs unverändert).
  `tools/render-offline.tmp.mjs` = render.mjs ohne Netz-Samples (nur Synths), für Pegelmessungen von Boards:
  `BPM=124 node render-offline.tmp.mjs <board> "(S.val[5+i]=1, column(i))" '{}'`.

## Nachtrag (nach 00:30) — zweite Runde
- Feedback eingetragen (lab/{melodie,acid,keys,bass}/feedback.md). Bläser: zu jazzig, Happy House → offen (braucht passende
  Samples). Keys: Rhythmus gehört zu den Akkorden; Frage offen, ob Keys per Knopf an die Harmonie-Spalte gekoppelt werden.
- Neu: lab/bass/house-bass-4 (Spalten = 8 Klänge, Taste 1 = dieselben 18 Linien; Bass 1–3 in old/), lab/keys/house-keys-lab-23
  (Riffs mit eigenem Rhythmus: Checkmate, Turn Off The Lights, Atmosphere, Chicago Spread, Retro-Disco), lab/acid/acid-2 (zahm).
- Track 009: Flöte (melodie-4 Spalte 6) als Jonas 4, Pegel = Vibraphon; single, syx, Layouts, Set 011 neu gebaut.
- Werkzeug: Pegel mit Samples lassen sich in der Cloud-Umgebung messen (npm ci in tools/, render.mjs + samples-Registrierung
  + Abfrage in 0,05-Zyklen-Schritten, sonst sehen zustandsbehaftete Regler nichts).
