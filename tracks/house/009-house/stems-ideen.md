# 009 — mögliche Stems für Jonas 2–7 (Entwurf, nicht final)

## ▶ Stand 2026-11-08 abends — Disco-Labs für Jonas 5–7 (NICHT gehört)
Nutzer: Disco-Gitarre, Disco-Streicher, Bläser — warm, organisch, an House angelehnt (Referenz: Vera „Take Me to the Bridge“).
Vocals kommen auf ein eigenes Sample-Pad, nicht in eine Spalte.
- Im Track (2026-11-08 spät): Jonas 5 Bläser (disco-blaeser-3), Jonas 6 Streicher (disco-streicher-4), Jonas 7 Gitarre
  (disco-gitarre-3) — Streicher und Gitarre NICHT gehört. Offen: Bläser-Komplexität (`lab/blaeser/komplexitaet-1`), Gitarrenklang.
- Aktuell: `lab/streicher/disco-streicher-4` (5 Figuren, sauberer Klang, harter Anschlag oben), `lab/gitarre/disco-gitarre-3`
  (Linien, Komplexität in 4 Stufen, offen ↔ gedämpft) und `lab/gitarre/gitarren-klaenge-1` (8 Klänge). Ältere Runden in `old/`.
Details und Quellen: `feedback.md` im jeweiligen Ordner. Danach: Gewinner per `lab-to-track` in Jonas 5–7.

## ▶ Stand 2026-11-08 (spät) — Details: uebergabe-2026-11-08-spaet.md
Spaltenplan: Jonas 4 Flöte hoch · 5 Bläser mit Aufbau · 6 Acid (Probe) · 7 Vocal-Hook nur mit ikonischen Samples.
Neue Labs zum Anhören: lab/bass/house-bass-1 (Jojo 4), lab/keys/house-keys-lab-22, lab/melodie/melodie-4, lab/acid/acid-1.

## ▶ Für morgen früh (Nachtschicht 2026-11-08) — Details: uebergabe-nacht-2026-11-08.md
Nichts davon gehört; alles in Node / Headless-Chrome geprüft.
1. **009, Jonas 3 Vibraphon „Ruf-Echo“**: F♯ wird in den Moll-Folgen (alle außer „Am9 D9“) zu F. Anhören: Jonas 1
   Taste 1 auf eine Moll-Folge (z. B. „Am F G“), Chapter auf Wechsel, Jonas 3 Taste 1 auf „Ruf-Echo“ (Takt 7–8).
   Set 011 neu gebaut.
2. **`lab/melodie/melodie-3.strudel`** — echte Bläser-Phrasen für Jonas 4: Spalte 2–4 Trompete A/B/C, 5 Tenorsax,
   6 Flöte (je 3–5 ruhige Phrasen aus langen Freesound-Improvisationen, nach A transponiert), Spalte 1 Vibraphon zum
   Vergleich. Fader hoch, Taste 1 = nächste Phrase, Reihe 3 = wie oft (16 / 8 / 4 Takte). Worauf achten: warm und
   lebendig statt mechanisch? Welche Phrase hält Wiederholung aus? Alle 8 oder alle 4 Takte? Rauschen bei leisen
   Aufnahmen (bis +14 dB angehoben)? Akkordfolge in Mode 2 Spalte 5 Taste 1 wechseln: Phrasen mit F♯/F weichen
   in unpassenden Folgen auf die nächste passende aus.
3. **`lab/einwurf/einwurf-1.strudel`** — technisch ok (alle 26 Samples laden), war aber viel zu laut (bis −13,7 LUFS,
   drei Spalten übersteuerten) → Spalten auf ≈ −19 LUFS angeglichen. Inhalt unverändert, jetzt zum ersten Mal anhören.
Danach: Gewinner aus melodie-3 / einwurf-1 per `lab-to-track` in Jonas 4–6; Harmonie im Browser feinschleifen.

Ziel: happy / jazzy House, trocken. Jonas 1 = Keys (fertig, aus dem Keys-Lab). Die übrigen Spalten sollen bunt,
verspielt und melodisch sein, ohne den Takt zu verändern (Beständigkeit über 8 Takte ist wichtig, siehe feedback.md).
Vor dem Bauen: Referenz-Tracks anhören (docs/references.md) und nachlesen, welche Rollen dort wirklich vorkommen;
jeder Stem bekommt ein eigenes Lab, der Gewinner geht 1:1 in den Track (Skill lab-to-track).

| Spalte | Stem | Rolle | Offene Fragen |
|---|---|---|---|
| 2 | Bläser-Stabs (Trompete / Sax) | kurze jazzige Antworten auf die Keys | Samples oder Synth? Dry hatte Dirt-Samples (trump, sax) |
| 3 | Lead / Hook (Flöte, Sax oder eine Rhodes-Linie) | die Melodie zum Mitsummen; etwas Zufall gegen Langeweile | wie viel Zufall, ohne dass die Hook sich auflöst? |
| 4 | Vocal-Chops | typisch House, verspielt | welche Vocal-Samples (Lizenz!) |
| 5 | Vibraphon / Marimba | bunte, perkussive Melodien, jazzig | steckt schon im Klang-Modus der Keys (Knopf 3): eigener Stem nötig? |
| 6 | Orgel (B3 oder M1 aus dem Lab) | zweite Harmonie-Farbe für den Drop | steckt ebenfalls im Klang-Modus der Keys (Knopf 2): eigener Stem nötig? |
| 7 | Pad / Strings | Fläche für Break und Aufbau | Dry hatte einen Saw-Pad; Strings waren unklar |

Notizen
- Harmonie: die Stems folgen dem Kapitel (Vamp = Am9, Wechsel = Am9 ↔ D9); Pentatonik je Akkord liegt im Track
  (`PENTA`), der Improviser (`improv`) ist noch drin (für die Bass-Ghosts) und kann wieder für Oberstimmen dienen.
- Effektkanäle: Jonas' Stems teilen sich Orbit 2 (Raum, Echo); bei mehr als zwei Echo-Stems eigene Orbits einplanen.
- Ladezeit: jede neue Sample-Quelle braucht Internet beim ersten Anschlag; möglichst wenige Quellen.

## ✗ Verworfen (vor jedem Lab prüfen!)
- Klänge: M1-Orgel (Stabs, Dub, Riff), „Orgel wie Strings“ (Pulse-Orgel), Strings + Orgel, String-Machine, echte Streicher-Section (VSCO), Marimba, Trompeten aus
  Einzelton-Multisamples (VSCO harmon / sus / vib, auch tpt_stac), Tenorsax/Flöte VCSL, Panflöte-Ersatz,
  synthetische Vocals (ah/oh), Chor, Bläser-Stabs „POP HORNS“, Orchestra Hit, Vinyl-Knistern, Rhodes/Orgel-Samples
  (verstaubter Jazz), Gitarren-Loops (messy), Rhodes-Antworten (A C E), M1/Trompeten-Dub.
- Spielweisen: 1-Takt-Loops, reine Zufallsmelodien, selbst ausgedachte brave Melodien, schnelle unruhige Jazz-Phrasen,
  Techno-Übernahmen aus 008/010, FX ohne hörbare Wirkung (Filter-Downer, Hochpass, Siren, Snare-Build).
- Einwürfe (einwurf-1, 2026-11-08): alle — Rufe, Jubel, Flöten-Triller/-Lauf, Zither, Posaunen-Fall, Cuíca. Wenn, dann
  ikonische Vocal-Samples. Progressive-House-Akkordfolgen (vi IV V I …): nein, klassischer House.
- Gut / behalten: JX-10, B3 weich, Strings + B3 (Harmonie; Akkordfolgen auf Taste 1 = weiterschalten); Vibraphon (Melodie); Dub Brass (Synth, „besser“);
  Flöten-Triller (selten), „yeah yeah yeah“; Akkordfolgen auf direkten Tasten.

## ☑ Im Track (2026-11-08): Jonas 1 Harmonie (harmonie-4 Sp. 2) mit 10 Akkordfolgen, Jonas 2 Keys, Jonas 3 Vibraphon — Details: uebergabe-harmonie-in-009.md, feedback.md

## ▶ Neu-Konzeption (Nutzer, 2026-11-08) — HIER WEITERMACHEN
Ziel des Ganzen: MIDI-Belegung, mit der Leute niederschwellig und schnell ausprobieren und bei einem Treffen gemeinsam
spielen können → es muss leicht sein, dass es gut klingt; viele schöne Samples für Melodien und Einwürfe.
Feedback zu den vier Nacht-Labs: in `lab/{einwurf,melodie,samples}/feedback.md`. Kurz: FX kaum hörbar; Antworten eintönig
(Dub Brass am besten); Samples meist schlecht, gut: Flöten-Triller (Einwurf/Pad), „yeah yeah yeah“ (Pad).
Neue Aufteilung Jonas 2–7 (je 2 Spalten, verschiedene Typen/Instrumente):
1. Harmonie (Orgel / Strings): übliche House-Progressionen über längere Zeit (bis 8 Takte), kein schneller Wechsel;
   Escravos: vermutlich 1 Takt, 3/8 erster Akkord, 5/8 zweiter (Nutzer hört Akkorde nicht sicher) → nachlesen.
2. Melodien: verspielt, groovig, über mehrere Takte; Bläser (Trompete/Sax wie Escravos) + Vibra/anderer Klang,
   evtl. verschiedene Stile; Zufall nur als Variation, nie komplett zufällig → nachlesen.
3. Einwürfe: rhythmisch, seltener, ikonisch, nicht Rhythmusgruppe → nachlesen, Vorschläge.
Später: Launchkey mit ~8 Pads für Samples → Sammlung in `samples/pads/`.
Status: Recherche fertig (recherche-harmonie.md, recherche-melodien.md, recherche-einwuerfe.md); Konzept unten
freigegeben (Akkordfolge: „verschiedene Optionen zum Probehören“). Gebaut 2026-11-08, warten aufs Anhören:
`lab/harmonie/harmonie-1`, `lab/melodie/melodie-1`, `lab/einwurf/einwurf-1` (Engine 3: tools/stem-lab/engine3,
Akkordfolge global in Mode 2 Spalte 5 Taste 1; Einwurf-Tasten „Jetzt!“). In Node geprüft, alle 89 neuen Samples in
Chromium geladen/dekodiert, Synth-Spalten offline eingepegelt; nichts gehört. Pad-Samples: samples/pads/.
Runde 2 (2026-11-08): `lab/harmonie/harmonie-2` (JX-10 + 3 Orgeln, 16 Progressionen inkl. klassischer House-Platten
aus Hooktheory; Mode 2 Spalte 5 Taste 2 = vorige), `lab/melodie/melodie-2` (nur Vibraphon, Weich + Komplexität;
Melodien folgen dem Modus dorisch/aeolisch). Offen: echte Bläser-Phrasen (Vorschlag: Freesound-Improvisationen
schneiden, ruhige auswählen) — wartet auf Ja.

### Konzept-Vorschlag (2026-11-08)
Grundsatz: alles läuft in 8-Takt-Phrasen; Varianten sind geschrieben und werden nach festem Plan gewählt (A A B A),
Zufall höchstens „einmal würfeln, dann fester 8-Takt-Plan“ (ribbon). Einwürfe nur auf Phrasenpunkten.
1. Harmonie — die Progression ist GLOBAL (Keys, Bass, Melodien müssen folgen) → Entscheidung nötig, ob Jojos Spalten mitgehen.
   Kandidaten, die zu A-dorisch passen: P1 jetzt Am9↔D9 (2+2 oder 4+4, Wechsel 1/16 vorgezogen wie KC „Checkmate“);
   P2 MAW „To Be In Love“ Am7 (2) – Cmaj7 (1) – Em7 (1); P3 Attack 8 Takte Am7 Am7 Em7 Em7 Am7 Am7 Em7 + Überraschung.
   (Can You Feel It braucht F statt F#, passt nicht zu dorisch.) 3/8+5/8 von Escravos unbelegt → als Rhythmus-Option.
   Spalte A Orgel „wie Strings gehalten“ (Mr Fingers) / M1-Riff; Spalte B Strings (Solina-PWM / VSCO-Section).
2. Melodien — Spalte A Bläser: Harmon-Trompete (VSCO) spielt Phrasen aus dem Volkslied „Escravos de Jó“
   (eine Quinte hoch = A-dorisch), Ruf 2 Takte + Pause + Antwort, Varianten per Plan; Alternative: echte Phrasen
   (sorohanro Trompeten-Loops, emirdemirel dorische Improvisation) geschnitten. Spalte B Vibraphon (VCSL):
   antwortet der Trompete in Takt 3–4 / Offbeat-Begleitung / Tresillo.
3. Einwürfe — Spalte A Stimme (Shouts-Pool + yeah yeah yeah), Spalte B Gesten (Flöten-Triller, Glock-/Zither-Gliss,
   Posaunen-Fall, Cuíca). Knopf „wie oft“ in Stufen (aus / 1 pro 16 / 1 pro 8 / + Antwort), Taste = zum nächsten
   Auftakt, Echo-Throw, Keys kurz geduckt.

## Für morgen früh (Stand 2026-11-08) — vier neue Labs zum Anhören
Alle in Node geprüft (Noten, Rhythmen, keine Fehler), Synth-Spalten offline eingepegelt; NICHT im Browser gehört.
1. `lab/harmonie/old/fundament-lab-1.strudel` — Spalte 2 Fundament: String-Machine (PWM, Sound on Sound), JX-10-Strings
   (zwei Saws 4 Cent), Orgel-wie-Strings (Mr Fingers), echte Section (VSCO 2). Knopf 1: liegend / atmen / Pedal-A.
2. `lab/melodie/old/answers-lab-1.strudel` — Spalte 3 Rhodes-Antworten (FM-Rhodes nach SuperCollider, Rhodes Mark I) in den
   Keys-Lücken, nur A C E, 1/8-Delay (Kerri „Checkmate“); Spalte 5 Dub-Stab (Grundton + Sexte, 1/4-Delay, NI) als
   Brass-Synth / M1-Orgel / echte Trompeten.
3. `lab/samples/sample-lab-1.strudel` — Spalte 4: spielt die Kandidaten der Hörliste (hoerliste.md) im Groove ab,
   8 Kategorien, Knopf 1 = nächster Kandidat, Reihe 3 = Startpunkt. Noch nicht auf Tonart/Tempo angepasst.
4. `lab/einwurf/old/fx-lab-1.strudel` — Spalten 6/7: Fill + Crash alle 8 Takte, Filter-Downer und Hochpass-bis-zum-Drop auf
   ALLEM (gehalten), Dub-Siren, Build (Snare-Rampe / Rausch-Riser), Vinyl (synthetisch / echte Platte).
Offen zur Entscheidung: Master-Hochpass in die globale Spalte 8 von 009? (im FX-Lab Spalte 3 zum Ausprobieren)

## Arbeitsstand Labs (Claude, 2026-11-06) — hier weitermachen
Auftrag: für jede Spalte 2–7 ein Vorschlags-Lab vorbereiten (Kandidaten-Spalten wie Track-Spalten, Aufbau wie
`lab/keys/house-keys-lab-20.strudel`). Reihenfolge und Status (☐ offen, ◐ angefangen, ☑ fertig):

- ☑ 0. Recherche je Rolle (Quellen notieren, unten unter „Recherche“) — Samples: freie Lizenz (CC0/CC-BY), wenige Quellen
- ☑ 1. `lab/horns/horns-lab.strudel` — Bläser-Stabs (Spalte 2): Dirt-Trompete, GM gedämpfte Trompete, VCSL-Tenorsax, GM-Bläsersatz; 3 Antwort-Rhythmen, kein Zufall
- ☑ 2. `lab/lead/lead-lab.strudel` — Lead (Spalte 3): GM-Flöte, VCSL-Tenorsax (Vibrato), GM-Panflöte, Rhodes-Linie; Hook A/B, Ruf, Zufall 1/2
- ☑ 3. `lab/vocal/vocal-lab.strudel` — Vocal (Spalte 4): Dirt „ah“ (rave/stabah), GM-Chor gehackt, GM „ooh“-Motiv, GM-Synth-Chor. Dirt `yeah` geprüft = 10–20 ms Klicks, unbrauchbar. Echte Vocal-Samples (Freesound CC0) = spätere Runde, falls gewünscht
- ☑ 4. `lab/mallets/mallets-lab.strudel` — Mallets (Spalte 5): VCSL-Vibes hart/weich, VCSL-Marimba, GM-Vibes (= Klang-Modus der Keys, Referenz); gebrochen, Terzen, 3 gegen 4, Zufall 1/2
- ☑ 5. `lab/organ/organ-lab.strudel` — Orgel (Spalte 6): M1-Stabs, B3-Akkorde (aus Keys-Lab 14), GM-Perk.-Orgel, M1 als tiefes Riff
- ☑ 6. `lab/pad/pad-lab.strudel` — Pad (Spalte 7): Juno-Pad und String-Machine aus Oszillatoren, GM-Strings, GM-Warm-Pad; liegend, Offbeat-Schwelle, Synkope
- ☐ 7. Im Browser testen (strudel.cc, Chrome): laden alle Samples (VCSL über raw GitHub, Dirt), stimmen die Pegel?
  Noch NICHT geprüft — nur Node-Abfrage (Noten, Rhythmen, keine Fehler). Pegel geschätzt, nicht gemessen.
- ☐ 8. Nach dem Anhören: Noten je Spalte in den lab-Ordnern als `feedback.md`, Gewinner per Skill lab-to-track

Gerüst (fertig): gemeinsamer Motor `tools/stem-lab/engine.strudel-part` (Harmonie Am9/D9 wie Track, Muster-Notation,
Zufalls-Riffs, Live-Ansicht, Kontext Drums/Bass/Keys in Mode 2). Jedes Lab = eigener Kopf (BOARD, COLS, Samples) +
Motor; `node stem-lab/sync.mjs <board>` (in tools/) kopiert den Motor hinein, `node stem-lab/check.mjs <board> '{"5":1}'`
fragt 4 Takte in Node ab. Steuerung je Spalte: Hell / Raum / Länge / Pegel, Knopf 1 = Muster (geschriebene + Zufall 1/2:
neues Riff beim Ankommen, dann konstant), Knopf 2 = Echo-Wurf (gehalten). Mode 2: Fader 6 Drums, 7 Bass, 8 Keys,
Spalte 5 Knopf 1 = Harmonie, Spalte 6 Drehregler 1 = Swing, Knopf 2 = Drums aus (gehalten).

Regeln dabei: Loops konstant (kein Wechsel über 8 Takte), Zufall nur in Melodien; Harmonie aus dem Track (Am9 / D9);
nichts im Track ändern, nur Labs. Nach jedem Schritt Status hier aktualisieren.

### Recherche
(Recherche 2026-11-06 per Websuche; Quellen dünn, genaue 16tel-Positionen für Bläser/Mallets/Chops fand keine
Quelle → Rhythmen in den Labs sind eigene Ableitung aus Kerri-Stil und House-Offbeats, so markiert.)
- Sample-Basis (geprüft in den Repos): VCSL ist CC0 und in Strudel eingebaut (dough-samples/vcsl.json): `sax`,
  `sax_stacc`, `sax_vib` (Tenor), `saxello_*`, `vibraphone`, `vibraphone_soft`, `marimba`, `organ_8inch`/`organ_full`
  (Renaissance-Orgel, keine Hammond), `recorder_*`. VCSL hat keine Trompete, Flöte, Chor, Streicher.
  GM-Soundfonts (Strudel gm.mjs): gm_trumpet, gm_muted_trumpet, gm_brass_section, gm_alto/tenor_sax, gm_flute,
  gm_pan_flute, gm_choir_aahs, gm_voice_oohs, gm_vibraphone, gm_marimba, gm_drawbar/percussive_organ,
  gm_string_ensemble_1, gm_synth_strings_1, gm_pad_warm (Ursprungs-Lizenzen nicht geprüft). Dirt-Samples: `trump`
  (tight stabs), `sax`, `yeah` (31 Vocal-One-Shots), `juno` (Pads) — Repo ohne Lizenzdatei, Lizenz unklar.
- Bläser: Latin-/Jazz-House-Merkmal (Nuyorican Soul „The Nervous Track“, djmag.com/longreads/how-masters-works-nuyorican-soul-took-duo-back-their-latin-roots;
  MAW „Our Mute Horn“ mit gedämpfter Trompete, en.wikipedia.org/wiki/Masters_at_Work). Delay auf Viertel für Stabs
  (native-instruments.com/de/blogs/blog/how-to-make-a-deep-house-track). Kerri: letzter Stab vorgezogen
  (attackmagazine.com/technique/passing-notes/kerri-chandler-chords/).
- Lead: St Germain „Tourist“: Sax + Flöte live (en.wikipedia.org/wiki/Tourist_(St_Germain_album)); Earth Trax &
  Newborn Jr „Flute Track“/„Sax Track“ (dummymag.com/10-best/…earth-trax-and-newborn-jr/); Melodie bewusst „soft“
  und „little“ (edmprod.com/how-to-make-classic-deep-house/).
- Vocal: „just a few single words at the right moment“, Hall/Delay nicht übertreiben (edmprod, s. o.); Chops =
  einzelne Wörter, „ooh“/„yeah“, rhythmisch oder melodisch (vocalfy.com/blog/vocal-samples). Freie Chops: Freesound-Packs
  nur mit Login + Lizenz je Sound → erst einfache Variante (Dirt `yeah`, GM-Chor).
- Mallets: Roy Ayers (Vibraphon) arbeitete mit MAW und Kerri Chandler (Wikipedia Roy Ayers). Keine Rhythmus-Quelle.
- Orgel: „Show Me Love“ = M1-Preset „Organ 2“, ursprünglich als Bass (en.wikipedia.org/wiki/Show_Me_Love_(Robin_S._song));
  Organ 2 punchiger als Organ 1 (gijs.substack.com/p/the-legendary-korg-m1-organ-2-preset). B3/M1-Bau aus Keys-Lab Runde 14.
- Pad: Juno-Pad (aulart.com/blog/make-lush-house-pads-in-ableton-live/): Säge + Square-Sub, zwei Sägen leicht
  verstimmt, LP 12 dB, langsame Attack (1,5–2 s), Chorus, Delay 25 %. Strings (attackmagazine.com/technique/tutorials/analogue-style-string-synthesis/):
  Puls mit PWM + Säge eine Oktave höher, LP mit wenig Resonanz. Pads leise, „fill out the spectrum“ (edmprod).

## Feedback Runde 1 (Nutzer, 2026-11-07)
Insgesamt: noch richtig schlecht, nicht zu gebrauchen; zu brav („Musiklehrer 8. Klasse“), muss viel organischer und
grooviger sein (008 Groove Techno hat besser funktioniert — nicht kopieren, aber da groovte es). Zu viel selbst
herumgedoktert statt nachgelesen / auf Bestehendes zurückgegriffen: Beschreibungen, Strudel-, Tidal-, SuperCollider-Code
und andere Vorlagen suchen.
- Horns: quäkig, sehr langweilig; Bläsersatz ganz ok, die anderen raus (super cheap).
- Lead: sehr schwach, kein Groove / Impro-Vibe; Zufall klingt nur random, nicht gut; Flöte und Tenorsax cheap.
  Panflöte bester Sound bisher. Ziel: echte Sax-House-Samples, Stil Joe Claussell & Kerri Chandler „Escravos De Jo“.
- Vocal: „Ah“ und „Ooh“ total panne, mega synthetisch; Chor boring.
- Mallets: alle Melodien super langweilig und zu gezirkelt, nichts groovt; Klang nicht überragend; Marimba fast still
  (da ist was kaputt).
- Orgel: ergibt keinen Sinn, ist über die Keys abgedeckt; Riff und Antwort ein kleiner Lichtblick.
- Pad: Strings als Grundlage evtl. spannend, ok; unklar, ob genug.
Nächster Schritt: erst Recherche (Vorlagen, Code, Samples, wie der Groove entsteht), Ergebnis berichten, dann bauen.
Befunde dazu (2026-11-07):
- Marimba „fast still“: die VCSL-Marimba in Strudel (`marimba`) sind die leisen „soft“-Anschläge, Spitze −48 dBFS
  (Vibes hart: −16 dBFS) → rund 32 dB leiser. Mein Fehler: Pegel nicht gemessen.
- Warum 008 groovt (aus dem Code): Strudels eigene Muster-Werkzeuge statt starrem Raster — Loops von 3/5/7 Schritten
  gegen den 4/4 (Polymetrik), `degradeBy`/`sometimesBy` für Lücken und Durchgangstöne, Anschlagstärke über
  `perlin`/`rand` (nie zwei Anschläge gleich), winzige Verstimmung pro Note, Pan-Bewegung, `swingBy`, lange Echos.
  Meine Labs: eigenes 16tel-Raster mit festen Anschlagstärken → steif.

## Recherche Runde 2a: Groove und vorhandener Code (2026-11-07, Quellen unten)
- Strudel-Quellcode gelesen: `nudge` wirkt im Browser nicht (nur OSC); Mikro-Timing per `.late()` / `swingBy`.
  `swingBy(x, 8)` bei 1 Takt pro Zyklus = MPC-Swing 0,5 + x/2 → 54 % = `swingBy(0.08, 8)`, 58 % = `swingBy(0.16, 8)`.
- Strudel-Beispiel-Tunes (Felix Roos, website/src/repl/tunes.mjs): „Festival of fingers“ (Euklid-Akkorde + leiser
  Oktav-Schatten per `off(1/7, …)`, Antizipation per `early`), „Belldub“ (`iter(4)` + Antwort in der Quinte per
  `off(1/3, add(7))`, `degradeBy(.2)`, Stimme 8 Takte an / 8 aus per `mask`), „Lounge sponge“ (`fast(2/3)` +
  `off(".25 .125", add("<2 4 -3 -1>"))`), „Arpoon“ (`lastOf(4, fast(2))` Phrasenende, Akzente per `gain`).
- `ribbon(seed, len)`: schneidet ein Stück Zufall heraus und wiederholt es → festes Riff, Seed = Preset;
  `wchooseCycles`: gewichtete Wahl ganzer Motive pro Takt (kindohm: generativ auf Motiv-/Rhythmus-Ebene, nicht Note für Note).
- Groove: MPC-Swing 54–58 %; Stabs lassen die Hauptschläge frei, betonen Off-16tel, kurz/lang im Wechsel, Takt 4
  leicht anders, Takt 8 Kontrast (Attack „Levelling up your chord stabs“); Ghost Notes 20–35 % Anschlag; Motiv-
  Entwicklung: Wiederholung, Sequenz, Fragment, rhythmische Verschiebung, Frage–Antwort (Marsalis-Studie).
- „Escravos De Jo“ (Bandcamp-Credits Joe Claussell): Gitarre, Trompete (Winston Byrd), Flöte (Talib Kibwe),
  Percussion (Claussell); „a deep jam with live musicians“. Ein Sax ist in den Credits nicht belegt.
- Ideen, die zuerst probiert werden sollten: (1) festes Zufalls-Riff per `ribbon`, gute Seeds als Presets;
  (2) Takt 2 = Variation, Takt 4/8 = Fill (`lastOf`); (3) Selbstantwort per `off(3/16, add(…))`; (4) Hauptschläge
  frei, Off-16tel betont, kurz/lang per `clip`; (5) Swing 56 % + Akzente nur auf den Oberstimmen; (6) Motiv-Bibliothek
  per `wchooseCycles`; (7) Bläser/Flöte etwas hinter dem Schlag (`late`); (8) Pausen: `mask` / `someCyclesBy`.
Quellen: codeberg.org/uzu/strudel (tunes.mjs, pattern.mjs, signal.mjs, controls.mjs), strudel.cc/learn/time-modifiers,
uzu.lurk.org/t/generative-strategies-and-workflows/3353, attackmagazine.com (levelling-up-your-chord-stabs,
kerri-chandler-chords, dusted-deep-house, ?p=10694), joe-claussell.bandcamp.com/album/escravos-de-jo-2x12,
so04.tci-thaijo.org/index.php/mmj/article/view/277872.

## Recherche Runde 2b: echte Samples (2026-11-07)
- Schon in Strudel (VCSL, CC0, CORS ok): `sax`/`sax_stacc`/`sax_vib` (Tenor), `saxello_*`, `vibraphone(_soft)`,
  `marimba` (leise!), `balafon(_soft/_hard)`, `kalimba`–`kalimba5`, `xylophone_*`, `glockenspiel`, `slitdrum`;
  Percussion `conga`, `bongo`, `shaker_small/_large`, `cabasa`, `agogo`, `clave`, `guiro`, `tambourine`, `cajon`.
- VSCO 2 CE (github.com/sgossner/VSCO-2-CE, CC0): Trompete staccato (66, 2 Stärken, Round-Robins), sus, gedämpft;
  F-Horn, Posaune; Violin/Viola/Cello-Sections mit spiccato, pizz, susvib, trem; Congas; Marimba.
- Karoryfer Bear Sax (Bariton, Growls, Subtone) und Weresax (Alt), CC0, jsDelivr ok (github.com/sfzinstruments/karoryfer.bear-sax, …weresax).
- MTG Solo Saxophones (CC-BY 4.0, Namensnennung): Sopran–Bariton, p/f, Atem- und Klappengeräusche.
- Sax-Phrasen in A-Moll / 124 BPM mit freier Lizenz: nicht gefunden (Freesound CC0 nur Einzelstücke, Login nötig;
  Looperman verbietet Weitergabe). → Phrasen aus echten Einzeltönen spielen.
- Vocals: ccMixter-Acapellas CC-BY 3.0 (Soul/Gospel, 103–128 BPM; Lizenz je Datei prüfen), Ausschnitte schneiden und
  selbst hosten, Namensnennung. Philharmonia / Iowa: nicht öffentlich weiterhosten bzw. AIFF umwandeln.

## Runde 2 (freigegeben 2026-11-07; Vocals vorerst nicht, Referenz = Trompete in „Escravos De Jo“)
Grundsatz: Stems in Strudels Mustersprache wie in 008 (nicht mehr mein 16tel-Raster), Motive aus den Quellen,
Groove per Swing 56 %, `late`, Akzente/Ghosts, Takt 2 = Antwort, Takt 4/8 = Fill, Pausen; echte Samples.
- Bläser: Bläsersatz (GM) bleibt; neu VSCO-2-Trompete staccato als Satz (2–3 Stimmen) und Bear-Sax-Growl-Stabs;
  Stab-Rhythmen nach Attack (Hauptschläge frei, kurz/lang, Takt 4 / 8 anders).
- Lead: Panflöte bleibt; neu Alt-Sax (Weresax), Tenor (VCSL `sax_stacc`/`sax_vib`), Trompete (VSCO 2) mit
  Motiv-Bibliothek (`wchooseCycles`), Selbstantwort (`off`), festen Zufalls-Riffs (`ribbon`, gute Seeds als Presets), Pausen (`mask`).
- Vocal: echte Stimmen nur über ccMixter-Ausschnitte (CC-BY, selbst hosten, Namensnennung) — größerer Schritt, erst nach Freigabe.
- Mallets: Balafon, Kalimba, Vibes (VCSL), Marimba aus VSCO 2 (VCSL-Marimba zu leise); Polymetrik + Anschlag per `perlin` wie 008.
- Orgel: als eigene Spalte gestrichen (Keys decken das ab); Riff/Antwort-Idee ggf. später.
- Pad: GM-Strings bleiben als Referenz; neu VSCO-2-Sections (susvib liegend, spiccato/pizz rhythmisch).

### Stand Runde 2 (2026-11-07) — gebaut, in Node geprüft, im Browser NICHT gehört
- Motor 2: `tools/stem-lab/engine2.strudel-part` (Boards mit `makeCols(h)`; Spalten = Strudel-Muster, Swing wie Drums
  per `swingBy`, Kanalzug je Event; `h.chord(lo, n)` = Akkord der Keys-Voicing mit Push, `h.root(oct)` = Grundton).
  `sync.mjs` wählt Motor 1 oder 2 je nach Board. Runde-1-Boards liegen in `lab/<instr>/old/`, Noten in `feedback.md`.
- ☑ `lab/horns/horns-lab-2.strudel`: GM-Bläsersatz (behalten), 3 echte Trompeten (VSCO 2), Trompete + Bariton
  (Bear Sax), Bariton-Growl; Stab-Rhythmen nach Attack (Hauptschläge frei, kurz/lang, Ruf + Antwort), 2-Takt-Loops konstant.
- ☑ `lab/lead/lead-lab-2.strudel`: Trompete + Flöte (VSCO 2, staccato / Vibrato), Altsax (Weresax), Panflöte (behalten);
  Ruf + Antwort (Sequenz + Verschiebung), Impro (`wchooseCycles` aus Motiv-Bibliothek, Pausen), Riff (`ribbon`), Lang.
- ☑ `lab/mallets/mallets-lab-2.strudel`: Vibraphon, Balafon, Kalimba (VCSL), Marimba (VSCO 2, laut); 5er-/7er-Loops
  wie 008 (Polymetrik, kleine Lücken / Durchgangstöne pro Takt), Ruf + Echo (`off`), Riff (`ribbon`).
- ☑ `lab/pad/strings-lab-2.strudel`: GM-Strings (behalten), Section (Violinen/Bratschen/Celli mit Vibrato), Pizzicato,
  Spiccato (VSCO 2); liegend, Offbeat-Schwelle, Synkope, 7er-Loop.
- Gemessen: alle neuen Quellen liefern CORS-Header; Tonhöhe: VSCO-2- und VCSL-Dateien klingen eine Oktave über ihrem
  Namen (Trompete, Flöte, Violinen, Marimba, Vibraphon, Kalimba gemessen; Balafon angenommen) → Karten verschoben bzw.
  eine Oktave tiefer gespielt. Pegel aus Datei-RMS/-Spitzen geschätzt, nicht im Mix gemessen.
- ☐ Offen: im Browser anhören (Laden, Pegel, Stimmung der Samples), dann Noten je Lab in `feedback.md`.

## Neuer Modus (2026-11-07, Nutzer: „Modus ändern“) — 1 + 2 + 4
1. Von dem ausgehen, was schon groovt (010: Marimba-Antwort, Pluck-Arp; 008: Answer, Sequence, Pings).
2. Kleine Schritte: ein Lab, wenige Kandidaten, hören, ja / nein.
4. Recherche nur, wenn sie konkretes Material liefert (Notenpositionen, Einstellungen, Quellen).
Gebraucht laut Nutzer: 2–3 melodisch verspielte Stems, ein harmonisches Fundament, andere Effekte (nachlesen, was ein
House-Track braucht).
- ☑ `lab/playful/playful-lab-1.strudel`: Marimba-Antwort (010), Sequenz (008), Pluck-Arp (010), Pings (008) nach 009
  übertragen (124 BPM, A dorisch, Grundton folgt der Harmonie); Reihe 3 / Knopf 2 wie in ihren Tracks. Node ok, nicht gehört.
- ☑ Recherche „was ein Deep-House-Track braucht“: unten.
- ✗ Playful Lab 1 (Nutzer): nicht gut — 008/010-Stems waren nur lose Beispiele für „weniger klinisch“, die sind Techno;
  klassischer House braucht anderes (gesampeltes Material). Ich kann nicht hören → ich kuratiere, Nutzer wählt nach Gehör.

## Recherche: was ein Deep-House-Track hat (Attack Magazine u. a., 2026-11-07)
- Stabs (Kerri, Attack): m7/m9 ohne Grundton, 3. Umkehrung, Downbeats meiden, Offbeat-16tel, letzter Stab nimmt den
  nächsten Akkord vorweg; Bass spielt zwischen die Stabs. „Checkmate“: kurzes 1/8-Delay mit wenig Feedback auf dem
  E-Piano macht den Groove (die Wiederholungen antworten). „Mommy What's a Record“: Sub-Pedalton unter dem Pad.
  (attackmagazine.com/technique/passing-notes/kerri-chandler-chords/ und …-part2/)
- Fundament: in Kerris gehaltenen Varianten Strings / Saw-Pads unter den Stabs, darunter aktiver Bass; NI-Tutorial:
  Pad mit LPF 400 Hz, ~6–8 dB unter dem Bass; Mr Fingers „Can You Feel It“: „an organ played like strings“ (Juno-60);
  analoge Strings: Puls mit PWM + Saw eine Oktave höher (Attack analogue-style string synthesis).
- Verspielt (keine Lead-Melodie): kleine pentatonische Melodien zwischen den Stabs, Oktav-Muster auf den hohen Tönen
  (Attack „Levelling up your chord stabs“); Dub-Stab: Grundton, große Sexte, 1/4-Delay (NI); Strings-Hook nur in den
  Breaks, Synth-Solo (Joe Smooth „Promised Land“, Attack Deconstructed); Kerri „Bar A Thym“: 8-taktige Lead steigt/fällt.
- FX / Übergänge: Tom-Fill + Crash am Ende jedes 8-Takt-Abschnitts, absteigende Filterfahrt mit LFO in den Breakdown,
  Kick weglassen (Promised Land); Reverse-Crash endet genau am Taktende (Plate 30 %, 1 s); Dub-Siren (Square, Saw-LFO auf
  Tonhöhe, langes Delay); Master-HPF hochziehen, am Drop aus; Riser sparsam (alle 16 Takte), Impact −14 dB; Vinyl-
  Knistern als leiser Layer (HPF 150 Hz). (attackmagazine.com …/deconstructed/joe-smooth-promised-land/,
  …/essential-transition-fx-technique-masterclass/, …/filter-fills/, NI how-to-make-a-deep-house-track)
- Drums (Jojo, zum Abgleich): Ghost-/Offbeat-Kick am Abschnittsende, Clap ein paar ms früh, Toms auf 16tel 3/9/11,
  zwei Tamburine hart L/R (Beat Dissected: Dusted / Rolling / Soulful Deep House, Jersey Garage, 21st Century Chicago).

## Nächster Schritt (2026-11-07): Vorschläge Spalten 2–7, erst Strudel-Code lesen
- Geprüft (superdough 1.3.0 in tools/): Strudel hat `pulse` mit `pw`/`pwrate`/`pwsweep` (echtes PWM → analoge Strings nach
  Attack), `supersaw` mit `unison`/`detune`/`spread`, Filterhüllkurve `lpenv`/`lpattack`/`lpdecay`, `lfo`, `tremolo`,
  `phaser`, Sidechain `duckorbit`/`duckdepth`/`duckattack` (Pumpen von der Kick). `chorus` steht in den Controls, wird
  in superdough 1.3.0 aber nicht verarbeitet.
- ☑ Recherche echter Strudel-House-Code (2026-11-07). Wenig echter House-Code online (viele GitHub-Treffer KI-generiert,
  verworfen). Brauchbar (Funktionsnamen im Strudel-Quellcode geprüft, nichts angehört):
  - eefano „Gipsy Woman“-Cover (github.com/eefano/strudel-songs-collection, gipsywoman.js): House-Orgel-Stab
    (`gm_percussive_organ`) + Piano eine Oktave tiefer, abschnittsweise per `mask(…/32)`; Sax-Licks mit `penv`-Bends;
    „Pump Up The Jam“: Snare-Roll mit Gain-Rampe als Fill, Teile kommen per `pick`/`restart` dazu.
  - Strudel-Doku „Voicings“: eigenes Voicing-Wörterbuch `addVoicings('house', …)`, `anchor` (Zielton der Oberstimme →
    Stimmführung), `mode` below/above/duck/root; Jazz-Blues-Beispiel: Melodie, Stabs, Bass aus EINER Akkordfolge.
  - Switch Angel `strudel-scripts/prebake.strudel`: Akkordformen als Stufen („Deep House Voicing“ -7,0,2,9 …),
    Helfer `strum` (gerollte Akkorde), `humanize`, `roll` (Snare-Build), `flood` (Hall saugt auf), `dly` (Delay-Throw),
    `oneshot` (Riser genau aufs nächste Raster); Pad-Samples `github:switchangel/pad` mit `scrub` (Tonband-Sprünge).
  - Doku-Recipes: Samples zerschneiden `fit().chop(16)`, `slice(8, …)`, `splice` (mit Tempo-Anpassung), Rhodes-Loop
    `chop(4).rev().loopAt(2)`; Chorus per `add(note("0,.1"))`; `echo(times, time, fb)`.
  - Sidechain `duckorbit`/`duckdepth`/`duckattack` (Praxis: kahlys/livecodingmusic „awake“, 124 BPM).
  - lmorv „house-experiment-02“: Pluck abwechselnd Saw / Jazzgitarre (GM), nur jede 4. Achtel, langes Delay, `ply`-Zufall.
  - Lizenz: fremde Repos meist ohne LICENSE → Ideen übernehmen, Code nicht 1:1 kopieren.
- ☑ Hörliste Spalte 4: hoerliste.md.
- ☑ Recherche SuperCollider / DAW-Rezepte (2026-11-07), Werte von den Seiten zitiert:
  - Strings: SOS „String Machines“: Puls, PWM per Dreieck-LFO zwischen 50 % und ~5 %, LPF halb zu, keine Filter-
    modulation, Trapez-Hüllkurve, VCO2 eine Oktave tiefer. SOS „Synth Secrets 47“ (JX10): zwei Sägezähne ~4 Cent
    verstimmt, LPF 47/99, Res 0, langsame Attack, Chorus. Attack Juno-106-Pad: Saw + halbes Rechteck + Sub, PWM, LPF
    offen bis es „fizzt“, A0 / D max / S halb, Plate, EQ unter 1 kHz runter.
  - Rhodes (sccode 1-522, Nathan Ho): FM, Op2 = 15× Frequenz (Zinke), Index 2π·0.109, Decay 1 s; Tremolo 4.8 Hz;
    Anschlag Pgauss(0.8, 0.1). sccode „SC Jazz“: Akkorde auf der Achtel-Offbeat, legato ½, Strum bis 0.02 Schläge.
    Attack FM-E-Piano: Ratio 18, Stärke 20–50, härter = perkussiver.
  - Brass-Stab: zwei verstimmte Saws, Amp-Attack ~15 ms, Filter-Attack ~100 ms, Decay 200–400 ms [teils ungeprüft].
    M1-Orgel-Zugriegel 16' 8, 5⅓' 6–7, 2⅔' 2–3 + Perkussion 3. Harmonische [ungeprüft, nur Suchzusammenfassung].
  - FX: Dub-Siren (Attack, Zebra2): schmaler Puls, Saw-LFO auf Tonhöhe, Neustart pro Note, Drive, Delay; Vinyl
    (sccode 1-4Sj): Dust2 8/s gefiltert 6–8 kHz + dichte Dust 100–500/s leise + Brown-Noise LPF 1200 Hz.
  - Groove: MPC 16B 54 %, 16C 58 %, 16D 62 % (Attack „DAW drum machine swing“); Attack „90s House“: Swing 55–60 %.
  - Harmonie: Mr Fingers „Can You Feel It“ (Hooktheory): A-Moll, Am(add9) – F7 – G(add9).
  - Nicht gefunden: freie MIDI-Bläser-Riffs / String-Hooks, Deep-House-Code in Tidal / Pbind.

## Vorschläge Spalten 2–7 (2026-11-07, wartet auf Auswahl)
- 2 Fundament (Strings/Pad, leise, gehalten, LPF): A String-Machine (SOS: Puls-PWM 50→5 %, Oktave tiefer dazu),
  B JX10-Strings (SOS: zwei Saws 4 Cent, `supersaw`), C „Orgel wie Strings“ (Mr Fingers), D echte VSCO-Section (Vergleich).
- 3 Rhodes-Antworten zwischen den Keys-Stabs: Töne, die in beide Akkorde passen (A C E), 1/8-Delay mit wenig Feedback
  (Kerri „Checkmate“); A FM-Rhodes nach sccode 1-522, B das Rhodes Mark I des Tracks; Anschlag Pgauss-artig, leichtes Strum.
- 4 Gesampelte Phrase: Hörliste (läuft), Nutzer wählt nach Gehör, dann `splice`/`chop` auf Tempo und Tonart.
- 5 Dub-Stab: Grundton + große Sexte, 1/4-Delay (NI); A Brass-Stab-Synth (SOS-Hüllkurven), B M1-Orgel-Stab
  (Gipsy-Woman-Stil), C echter Trompeten-Stab (VSCO 2).
- 6 FX / Übergänge: Fill + Crash am 8-Takt-Ende (Promised Land), Filter-Downer in den Break, Dub-Siren (gehalten),
  Reverse-Crash bis Taktende, Snare-Rampe (eefano).
- 7 Textur: Vinyl-Knistern nach sccode 1-4Sj (aus Rauschen gebaut).
- Global (optional, Nutzer fragen): Master-Hochpass bis zum Drop (Attack „Filter fills“).
- ☑ Hörliste Spalte 4: tracks/009-house/hoerliste.md (Nutzer kreuzt Favoriten an).

## Nacht 2026-11-07/08 (Nutzer schläft: „mach weiter, präsentier morgen früh, räum das Lab auf“)
- ☑ Aufgeräumt: alle 009-Stem-Labs der Runden 1–2 + playful → `lab/archive/009-stems/` (README + feedback je Ordner);
  neue Ordner `lab/strings/`, `lab/stabs/` (CLAUDE.md-Layout ergänzt).
- ☑ `lab/harmonie/old/fundament-lab-1.strudel` (Spalte 2): String-Machine (PWM), JX-10-Strings, Orgel-Strings, echte
  Section; liegend / atmen / Pedal. Spalten 1–3 offline auf −27 LUFS gemessen (6 dB unter den Keys).
- ☑ `lab/melodie/old/answers-lab-1.strudel` (Spalten 3 + 5): FM-Rhodes und Rhodes Mark I als Antworten (A C E in den
  Keys-Lücken, 1/8-Delay), Dub-Stab (Quarten, Grundton + Sexte, 1/4-Delay) als Brass-Synth / M1-Orgel / Trompeten.
  Synth-Spalten offline auf ≈ −24 LUFS.
