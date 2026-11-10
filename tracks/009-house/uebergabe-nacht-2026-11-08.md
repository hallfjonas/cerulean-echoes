# Übergabe: Nachtschicht 2026-11-08 (Nutzer war weg, nichts gehört)

Auftrag: `prompt-naechster-agent.md` (Punkte 1–5). Sprache mit dem Nutzer Deutsch, Code-Kommentare Englisch.

## Stand
1. ☑ **Vibraphon „Ruf-Echo“ (009, Jonas 3): F♯ → F in den aeolischen Folgen.** `vibModeFix` in
   `009-house-dual.strudel` (vor `vibPhrases`): F♯-Noten der Phrase werden F, wenn `modeAt(bar) === 'aeolian'`.
   Geprüft in Node: Vamp und „Am9 D9“ → g f♯ e d …, Folgen 3 und 6 → g f e d …. Single, Layout (unverändert, keine
   @ctl-Änderung), .syx neu erzeugt; `npm run set` gebaut. check-set: bei 009 genau dieselben Abweichungen wie vor der
   Änderung (per temporärem Zurücksetzen verglichen): „all 0.5/1“ nur Ereignisse bei t = 0; „ride A/B“ Abweichungen in
   Takt 0–1 (nicht nur im allerersten Moment, wie feedback.md sagt, aber unverändert alt).
2. ☑ **`lab/melodie/melodie-3.strudel`** (Engine 3) — echte Bläser-Phrasen. Spalte 1 Vibraphon (melodie-2, unverändert),
   2 Trompete A, 3 Trompete B, 4 Trompete C, 5 Tenorsax, 6 Flöte. 20 Phrasen in `samples/horn-phrases/` (Tabelle,
   Quellen, Credits: README dort). Methode: lange Freesound-Improvisationen (emirdemirel-Serie, Trompete Hikmet
   Altunbaşlıer, Sax Toprak Barut; Flöte juskiddink 65509; alle CC BY 4.0) → Tonhöhe (YIN), an Pausen bzw. am Ende
   langer Töne geschnitten, nur ruhige behalten (≤ 3,2 Töne/s, ein Ton ≥ 0,5 s, keine Tonleiter-Läufe, keine Töne
   außerhalb A-dorisch/aeolisch), per Varispeed nach A (−3 … +2 Halbtöne), auf −20 dBFS angeglichen. Skripte:
   `tools/phrase-cut/`. Gegenprobe: alle 20 Dateien liegen in A (Analyse der fertigen Dateien).
   Spielweise: Einsatz auf der 1 alle 16 / 8 / 4 Takte (Reihe 3, Start 8), Phrase spielt bis zum Ende, Taste 1 =
   nächste Phrase (immer dieselbe Phrase wiederholt), Taste 2 Echo-Wurf. Phrasen mit F♯ spielen nur in Folgen mit F♯,
   mit F nur in den Moll-Folgen; sonst die nächste passende der Spalte.
   Geprüft: Transpiler ok; Node: Einsätze, „Wie oft“ und das F♯/F-Ausweichen richtig; Rechenzeit 3,2 ms/Tick (p95
   5,4 ms); Pegel offline: jede Phrase ≈ −23,5 LUFS bei Fader 1 (±1 dB) = etwa Vibraphon im Track; Chromium: Dateien
   dekodieren (lokal; nach dem Push von GitHub, siehe unten). Layout-PDF ohne Überlauf.
3. ☑ **`lab/einwurf/einwurf-1.strudel` technisch geprüft:** Transpiler ok; Rechenzeit 3,0 ms/Tick (p95 4,6 ms); alle 26
   Samples (Freesound, VCSL, VSCO) laden und dekodieren in Headless-Chrome. **Auffällig: viel zu laut** — bei Fader 1
   −13,7 … −19,3 LUFS (Kick in 009 ≈ −14), Jubel / Posaune / Cuíca mit Spitzen > 1 (Übersteuerung). Angeglichen
   per Spalten-Gain (`GAIN` in makeCols) auf ≈ −19 LUFS, Spitzen ≤ 0,9; Jubel bleibt bei −22 (sehr spitzes Signal).
   Inhalt sonst unverändert.
4. ☑ Morgen-Übersicht in `stems-ideen.md` (oben) und hier.
5. ☑ Commit + Push auf `johannes` (bbe18e2); alle 20 Phrasen laden und dekodieren von raw.githubusercontent.com in Headless-Chrome.

## Entscheidungen (ohne Rückfrage, naheliegend)
- Flöte als 6. Spalte dazu: echte, ruhige Aufnahme, schon in A-Moll; VCSL-Flöte (Multisample) war verworfen, die
  Flöten-Triller (echt) gefielen → als Vergleich.
- Sax: aus 6 Sax-Aufnahmen der Serie bestanden nur 3 Stellen den Ruhe-Filter (der Spieler spielt dicht) → nur 3.
- Quellen-Previews (128 kb/s MP3) statt Originale (Login nötig). Leise Aufnahmen wurden bis +14 dB angehoben →
  evtl. hörbares Rauschen (tpm-424905-0737/-0838, tpx-430268-0470).
- Phrasen-Beschriftung = die ersten Töne (wie bei den Akkordfolgen „die Akkorde selbst“).
- Pegel der Bläser = Vibraphon im Track (dort +40 % gegenüber Labor), also im Labor etwas lauter als Spalte 1.

## Nicht prüfbar ohne Gehör
- Klingen die Phrasen warm/lebendig oder nach „Übungsaufnahme“? Passen sie rhythmisch, obwohl sie frei (ohne Takt)
  gespielt sind? Wirkt die Varispeed-Transposition (bis −3 Halbtöne = 19 % langsamer) natürlich?
- Tonhöhen-Analyse kann bei Trompete Oktavfehler haben (Melodie-Spalte in der README); die Tonart-Tags F♯/F sind
  vorsichtig gesetzt.
