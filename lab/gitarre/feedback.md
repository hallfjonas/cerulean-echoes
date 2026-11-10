# Gitarre — Feedback

## disco-gitarre-1 (gebaut 2026-11-08, für 009 Jonas 5–7) — NICHT gehört
- Auftrag (Nutzer): Disco-Gitarre, warm und organisch, wirklich an House angelehnt; frühere Gitarren-Loops waren „messy
  und nicht im Takt“ (lab/samples).
- Ansatz: einzelne Anschläge aus echten Aufnahmen geschnitten (Onsets per Spectral Flux, auf der Wellenform nachgeschärft,
  Akkord per Chroma geprüft) und auf unserem 16tel-Raster mit dem Track-Swing gespielt → Klang vom Spieler, Timing von uns.
  Akkorde: eine aufgenommene Griffform per Abspielgeschwindigkeit verschoben (wie ein Sampler-Stab, max. ±6 Halbtöne);
  Dur-/add9-Akkorde über die Moll-Form auf der Terz (Am7 über F = Fmaj9, Em7 über C = Cmaj9, Em7 über G = G6/9),
  G11/G7 mit Dm7, D9/D6 mit den D-Anschlägen der Tele (A C D E, ohne F♯).
- Quellen (Freesound-HQ-Vorschau, direkt von cdn.freesound.org):
  Tele = [Funk_Tele_Am@110_bpm](https://freesound.org/s/167390/) von guitarelement, **CC BY 3.0** (Credits nötig);
  Palm-Mute = [120_Dm_PMVibesRhythmGtr_01](https://freesound.org/s/716617/) von oceansonmars, CC0.
- Rhythmen (Taste 1, in allen Spalten gleich): Offbeat-Akzente auf „und“ und auf „e“, „alle drei 16tel“ = Premier Guitar,
  [Rhythm Rules: 16th-Note Accents](https://www.premierguitar.com/articles/Rhythm_Rules_16th_Note_Accents) Fig. 3 / 4 / 8;
  Get Lucky = Zählweise „1 & 2 e & a 3 & a 4 &“ aus [Modern Guitar Tuition](https://modernguitartuition.squarespace.com/all-posts/how-to-play-get-lucky-by-daft-punk).
  Reihe 3 = Dichte der gedämpften Ghost-Anschläge („steady motor“, [Cory Wong über Nile Rodgers](https://www.guitarworld.com/lessons/artist-lessons/cory-wong-on-what-he-learned-from-nile-rodgers)).
- Spalten: 1 Tele klingend, 2 Tele kurz (Chic-„Chank“), 3 Palm-Mute, 4 Doppelt (Tele links, Palm-Mute rechts).
- Geprüft: in Node (Noten/Anschläge je 16tel, ≤ 3 ms/Tick), alle Samples laden und dekodieren im Browser.
  Pegel NICHT gemessen (die Vorschauen lassen sich hier nicht offline rendern): Anschläge auf gleiche Lautheit gebracht, Spaltenpegel geschätzt.
- Verworfen beim Bauen: Wah-„Chicka“ (669643) — die Ghosts haben eine deutliche Tonhöhe (Wah-Resonanz) und würden reiben;
  ganze Loops im eigenen Raster — die Tele-Aufnahme liegt nicht sauber auf 110 BPM (Rasterfehler ⅓ 16tel).
- Feedback (Nutzer, 2026-11-08 abends): alle schlecht. In House-Songs ist die Gitarre eher gezupft, mit Melodie.
  Nachgelesen (danach): Stardust „Music Sounds Better With You“ = Gitarren-Riff aus Chaka Khan „Fate“ (Loopcloud-Nachbau:
  gezupfte hohe Töne im Ruf/Antwort mit dem E-Piano, je Takt zwei 16tel-Anschläge am Ende von Schlag 3 und 4 + Oktavton,
  Phaser, Overdrive); Modjo „Lady“ = Gitarren-Sample aus Chic „Soup for One“ (Rhythmusgitarre, Akkordfolge umgestellt).
  → Runde 2 nur nach OK: gezupfte Einzeltöne / Licks aus echten Aufnahmen (wie die Flöte) statt Akkord-Chanks.

## disco-gitarre-2 (gebaut 2026-11-08 nachts) — NICHT gehört
- Gezupfte Einzeltöne einer echten Stratocaster ([nyanshell.strat](https://github.com/nyanshell/nyanshell.strat), MIT:
  jeder Ton F2–D6 einzeln aufgenommen, 3 Takes, abwechselnd), wie ein Sampler auf den Akkordtönen der Folge.
- Figuren: 1 Stardust/„Fate“ (Loopcloud-Nachbau), 2 Oktaven in Dreiern (Claydes Charles Smith), 3 Terzen (Al McKay),
  4 „e & a 4“ (Claydes Charles Smith) — alle [Guitar World, 70s funk guitar masterclass](https://www.guitarworld.com/lessons/artist-lessons/70s-funk-guitar-masterclass);
  5–8 (Ruf + Antwort, wiederholter Ton auf 3-3-2, gebrochener Akkord, Pentatonik-Lick) in deren Sinn, Töne MEINE.
- Reihe 3 = Komplexität, Taste 1 = Solo ↔ Doppelt (zweite Gitarre eine Oktave höher), Taste 2 gehalten = Steigerung
  mit Phaser (über 2 Takte, zurück über 1 Takt).
- Feedback disco-gitarre-2 (Nutzer, Schulnoten): Stardust 2, Oktaven 4, Terzen 4, e & a 4 2, Ruf 3–4, wiederholter Ton 2,
  Akkord 4, Lick 3; groovigere Lines. „Doppelt“ raus — lieber etwas dumpfer Gezupftes. Komplexität muss bei allen viel
  weiter nach oben gehen. Klang noch nicht gut → auf einem eigenen Lab verschiedene Klänge zeigen.

## disco-gitarre-3 + gitarren-klaenge-1 (gebaut 2026-11-08 nachts) — NICHT gehört
- disco-gitarre-3: Stardust, e & a 4, Ruf + Antwort (straffer), wiederholter Ton, Lick + neu Dead-Note-Groove,
  Offbeat-Paare, Auftakt (MEINE, im Sinn der Favoriten). Reihe 3 in vier Stufen: Linie → + Dead Notes → + Slides und
  Variation in Takt 4/8 → + 16tel-Motor aus Dead Notes und Pentatonik-Fill in Takt 8. Taste 1 = offen ↔ gedämpft.
- gitarren-klaenge-1: dieselben Linien (Stardust, wiederholter Ton, e & a 4), acht Klänge aus der Strat: hohe Saite,
  tiefe Saiten, Jazz, Crunch, Phaser, gedämpft, Auto-Wah, Dub-Echo. Nächste Option, falls keiner taugt: FreePats FSBS
  Clean (CC0) — müsste erst ins Repo.
