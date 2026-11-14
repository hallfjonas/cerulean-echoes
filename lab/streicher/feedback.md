# Streicher — Feedback

## disco-streicher-1 (gebaut 2026-11-08, für 009 Jonas 5–7) — NICHT gehört
- Auftrag (Nutzer): Disco-Streicher, warm und organisch, an House angelehnt. Die echte VSCO-Section war als GEHALTENE
  Harmonie raus (lab/harmonie); hier spielen Streicher Rhythmus: Stabs, Läufe, fallende Figuren — keine Fläche.
- Figuren (Taste 1): Echo-Stab alle 2 Takte ([Purple Disco Machine „In My Arms“, Attack Magazine](https://www.attackmagazine.com/technique/deconstructed/purple-disco-machine-in-your-arms/)),
  Offbeat-Stabs („sharp stabs“ wie Le Freak), Lauf hoch in den Stab, fallende Figur auf jedem Schlag
  ([VI-Control: idioms of funk/disco strings](https://vi-control.net/community/threads/what-are-the-idioms-and-techniques-behind-funk-disco-strings.150009/)).
  Töne MEINE, auf den Akkorden der Folge (Oberstimme = Akkordton nahe E5, Läufe in der Tonleiter der Folge).
- Reihe 3 = Aufbau: Violinen unisono → + Oktave → + Akkord darunter (Bratschen, Celli auf dem Grundton) → + Scoop in die Stabs.
- Klänge: [Sonatina Symphonic Orchestra](https://github.com/peastman/sso) (CC Sampling Plus 1.0) 1./2. Violinen, Bratschen,
  Celli staccato; [VSCO 2 CE](https://github.com/sgossner/VSCO-2-CE) (CC0) Violinen-/Bratschen-Section spiccato.
  Tonhöhen Datei für Datei geprüft: SSO-Namen = Klang; die SSO-rr2-Dateien klingen einen Halbton höher (nicht benutzt);
  VSCO klingt eine Oktave über dem Dateinamen.
- Spalten: 1 SSO-Violinen, 2 VSCO-Violinen, 3 beide (große Section), 4 dunkel (Linie eine Oktave tiefer auf Bratschen).
- Geprüft: Node (Noten je 16tel, ≤ 3 ms/Tick), alle Samples laden im Browser. Pegel aus dem RMS der Dateien, nicht gerendert.
- Feedback (Nutzer, 2026-11-08 abends): noch etwas langweilig; „Beide“ oder „Dunkel“ besser. Offbeat langweilig,
  Fallend viel zu stressig, Lauf + Stab ok — Lauf OHNE Stab viel besser, Echo-Stab ganz gut. Wie die Bläser: 8 Spalten,
  ein Klang, verschiedene Figuren. Frage: an die globalen Akkorde anpassen? → Sie folgen schon der Folge (hier Mode 2
  Spalte 5; im Track automatisch der Folge von Jonas 1).

## disco-streicher-2 (gebaut 2026-11-08 abends) — NICHT gehört
- Ein Klang überall = „Beide“ (SSO + VSCO); Taste 1 = normal ↔ eine Oktave tiefer („Dunkel“).
- 8 Figuren: Echo-Stab, Lauf hoch (landet eine 16tel vor der Eins, kein Stab), langer Lauf (8 Töne, alle 4 Takte),
  Lauf runter nach der Kick, Lauf + Echo auf dem letzten Ton, hoch und runter, Schweller (ein Akkord über 2 Takte,
  Purple Disco Machine), Pizzicato zwischen den Kicks ([Andrés „New For U“, Mixmag](https://mixmag.net/feature/20-best-house-music-samples-funk-soul-disco-kerri-chandler-larry-heard-chic)).
  Töne MEINE: Läufe in der Tonleiter der Folge auf die Oberstimme des nächsten Akkords.
- Reihe 3 = Aufbau: unisono → + Oktave → + Terzen unter den Läufen / Akkord unter Stab und Schweller → + Scoop.
- Neu: SSO-Sustain (Violinen, Bratschen) und -Pizzicato; Tonhöhen geprüft. Node ok, ≤ 4 ms/Tick im Mittel.
- Feedback disco-streicher-2 (Nutzer, Schulnoten): Echo-Stab 2; Lauf hoch 3 (die Eins oben wie beim Echo-Stab betonen);
  langer Lauf 2–3 (oben betonen); Lauf runter 4−; Lauf + Echo 4; hoch und runter 4; Schweller 2–3; Pizzicato 4−.
  Alle 4er raus, neue Versionen; nochmal nachlesen, was gute Streicher sind. Taste 1 (Oktave) macht keinen Spaß →
  Solo ↔ Ensemble; Taste 2 → Einwürfe oder Steigerung (immer organisch).

## disco-streicher-3 (gebaut 2026-11-08 nachts) — NICHT gehört
- Behalten: Echo-Stab, Lauf hoch und langer Lauf (landen jetzt AUF der Eins mit betontem Stab + Echo), Schweller.
- Neu: hohe Gegenstimme in Oktaven, wenige lange Töne ([Sound On Sound, Arranging Strings 4](https://www.soundonsound.com/techniques/arranging-strings-part-4): Descant),
  Echo-Stab + Schweller (Purple Disco Machine), Tremolo-Aufbau in die nächste 8-Takt-Phrase, 16tel-Figur in Takt 4
  (SOS: einfache 16tel-Phrasen, Oktavlauf über zwei Schläge). Töne MEINE.
- Taste 1 = Ensemble ↔ Solo (SSO-Solovioline), Taste 2 gehalten = Steigerung (Oktave und Stimmen kommen über 2 Takte dazu,
  heller, +3 dB; zurück über 1 Takt). Reihe 3 = Aufbau wie Runde 2. Neu: SSO-Tremolo, Solovioline (Tonhöhen geprüft).
- Feedback disco-streicher-3 (Nutzer): Läufe brauchen fast einen „Beat“ — harter Anschlag oben (nicht das Echo ist
  entscheidend; der Echo-Stab ist viel härter). Klang insgesamt cheap und knacksig — muss besser werden. Schweller,
  Gegenstimme, Tremolo (nichts zu hören) raus. Stab + Schweller ganz gut, 16tel-Figur ganz cool.

## disco-streicher-4 (gebaut 2026-11-08 nachts) — NICHT gehört
- Vermutete Ursachen für „cheap/knacksig“ und Änderungen: (1) drei Violin-Sections spielten denselben Ton 0–10 ms versetzt
  = Kammfilter (dünn, phasig) → jetzt eine Section pro Ton, abwechselnd; die zweite nur in der Oktave; (2) jede Note wurde
  nach ihrer 16tel abgeschnitten (clip) → Staccato klingt jetzt aus wie aufgenommen; (3) Scoop (Pitch-Hüllkurve) raus.
- Harter Anschlag: der Lauf landet auf der Eins mit dem vollen Echo-Stab-Akkord (Violinen, Bratschen, Celli) + Pizzicato-Klick.
- Spalten: Echo-Stab, Lauf hoch, langer Lauf, Stab + Schweller, 16tel-Figur. Reihe 3: unisono → + Oktave → + Terzen
  unter den Läufen → + Celli zwei Oktaven tiefer.

## techno-strings-1 (gebaut 2026-11-12, für 008, Hintergrund) — NICHT gehört
- Wunsch: ikonische Hintergrund-Streicher; Moll, dessen Quinte einen Halbton steigt und ihn zu Dur macht (Fm → D♭/F),
  oder andere sparsame Bewegungen.
- Spalten = Bewegungen auf offenem Fm (F4 C5 F5 A♭5): Fm→D♭ (Leittonwechsel), Fm→F, Fm→A♭, Linie hoch (Bond-Klischee
  5–♯5–6), Linie runter (m, m(maj7), m7, m6), Fm→E (Slide), Fm→C, Kette Fm→D♭→B♭m. Quellen: Wikipedia „Contrast chord“,
  Kopp „Chromatic Transformations“ (UCI), thejazzpianosite.com „Line clichés“, Attack „Strings of Life“ (Stabs) und
  „Analogue string synthesis“. Fm→C und die Kette = meine Wahl.
- Taste 1 = Langsam (6 Takte Grund, 2 bewegt) / Pendel (jeder Takt) / Stabs; Reihe 3 = JX-10 (harmonie-5) ↔ Analog-Strings.
- Engine techno (Kontext-Beat schwach, Nutzer-Feedback zu techno-pads-1; Engine nicht geändert, gemeinsamer Code).
- Node: Noten je Takt geprüft, transpiliert. Pegel geschätzt.
