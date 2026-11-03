# Casio GP-310 mit Strudel (MIDI)

Stand: 2026-10-31

## Kurzantwort

Ein USB-Kabel zwischen Mac und Klavier reicht für beide Richtungen: Das GP-310 schickt deine Tasten an Strudel und spielt umgekehrt Noten, die Strudel ihm schickt.

- **Als Eingabe** (Klavier → Strudel): sehr sinnvoll. Mit `midikeys()` spielst du Strudel-Sounds über die Klaviatur, mit Pedal und echter Hammermechanik.
- **Als Ausgabe** (Strudel → Klavier): sinnvoll für Klavierstimmen. Strudel schreibt die Noten, der Flügelklang des GP-310 klingt aber viel besser als jeder Browser-Piano-Sample. Das Klavier empfängt auf 16 Kanälen gleichzeitig, also kannst du mehrere Stimmen mit verschiedenen Klängen schicken.
- **Der Haken bei der Ausgabe**: Der Klavierklang kommt aus den Lautsprechern des Klaviers, nicht aus dem Mac. Effekte wie `.room()` oder `.lpf()` wirken darauf nicht. Für einen gemeinsamen Mix brauchst du ein zweites Kabel (Abschnitt Audio).

## Kabel und Anschlüsse

Für MIDI brauchst du nur ein Kabel: **USB-C auf USB-B**. Das M2 Air hat nur USB-C, das Klavier hat hinten eine eckige USB-B-Buchse (wie beim Drucker).

| Zweck | Kabel | Von → nach | Nötig? |
| --- | --- | --- | --- |
| MIDI in beide Richtungen | USB-C auf USB-B, USB 2.0, 2–3 m | Mac → USB-B-Buchse am GP-310 | Ja |
| Klavierklang in Mischpult/Interface | 2× Klinke 6,3 mm mono | LINE OUT L/MONO und R → zwei Eingänge | Nur für gemeinsamen Mix |
| Mac-Ton ins selbe Mischpult | Miniklinke 3,5 mm stereo auf 2× Klinke 6,3 mm mono | Kopfhörerausgang Mac → zwei Eingänge | Nur für gemeinsamen Mix |

- Kein Adapter-Gefrickel nötig: Ein USB-C-auf-USB-B-Kabel kostet etwa 10 €. Alternativ geht das vorhandene USB-A-auf-B-Kabel mit einem USB-C-Adapter.
- Die zweite USB-Buchse (Typ A) ist für USB-Sticks, nicht für den Mac.
- Das GP-310 hat laut Herstellerangaben kein Bluetooth-Audio; MIDI läuft also nur über USB.
- Klassische 5-Pol-MIDI-Kabel brauchst du nicht.

Die Buchsenangaben stammen aus Hersteller- und Händlerseiten; ein Blick auf die Rückseite des Klaviers bestätigt sie in einer Minute.

## Setup Schritt für Schritt

1. Klavier einschalten, dann das USB-Kabel an Mac und Klavier stecken. Einen Treiber brauchst du nicht; macOS erkennt USB-MIDI-Geräte selbst.
2. Prüfen, ob der Mac das Klavier sieht: Programm **Audio-MIDI-Setup** öffnen, Menü *Fenster → MIDI-Studio einblenden*. Dort sollte ein Casio-Symbol erscheinen.
3. Strudel in **Chrome** (oder Edge) öffnen. Safari kann kein Web MIDI. Beim ersten Mal fragt der Browser, ob die Seite MIDI-Geräte nutzen darf: erlauben.
4. `snippets/midi-test.strudel` laufen lassen. Die Box unten rechts listet alle MIDI-Eingänge. Den Namen des Klaviers genau so abschreiben (oft etwas wie `CASIO USB-MIDI`).
5. Eine Taste drücken: Die Box zeigt dann eine Nachricht von Kanal 1 (Typ 9 = Note an). Damit steht die Verbindung.

In den Beispielen unten steht `'CASIO USB-MIDI'` als Platzhalter. Setz dort den Namen aus Schritt 4 ein, in einfachen Anführungszeichen.

## Klavier als Eingabe: Tasten spielen Strudel-Sounds

Für Noten gibt es `midikeys()`; `midin()` liest nur Regler (CC), so wie beim LC XL 3. Beide Geräte kannst du gleichzeitig nutzen.

```js
const kb = await midikeys('CASIO USB-MIDI')

// every key you press plays a filtered saw through Strudel's own effects
kb().s('sawtooth').lpf(1200).room(0.4).delay(0.25)
```

Was du wissen musst:

- **Feste Notenlänge.** Strudel kennt nicht, wie lange du eine Taste hältst; jede Note bekommt eine feste Dauer. Mit `kb("0.5 1")` änderst du diese Länge im Muster. Lange gehaltene Flächen und das Haltepedal wirken also nicht wie am Klavier.
- **Doppelter Klang.** Das Klavier klingt beim Spielen selbst mit. Dreh am Klavier die Lautstärke ganz runter oder spiel mit Kopfhörern am Mac.
- **Kanal.** Die Klaviatur sendet auf Kanal 1. Nutzt du Layer oder Split am Klavier, kommen die zweite Stimme auf Kanal 2 und der linke Teil auf Kanal 3. So kannst du die Hände trennen:

```js
const kb = await midikeys('CASIO USB-MIDI')

stack(
  kb().filterValues(v => v.midichan == 1).s('triangle'),          // upper part
  kb().filterValues(v => v.midichan == 3).s('sawtooth').lpf(400)  // left side of the split
)
```

In einem Track mit LC XL 3 legst du `midikeys` einfach neben dein `midin`; die Stems bleiben unverändert.

## Klavier als Ausgabe: Strudel spielt den Flügelklang

Ja, das lohnt sich für Klavierparts: `.midi()` schickt die Noten ans GP-310, und du hörst den echten Flügel-Sound statt eines Browser-Samples.

```js
// arpeggio played by the piano's own grand sound
note("<c3 e3 g3 b3>*4").gain(0.7).midi('CASIO USB-MIDI')
```

- **Lautstärke.** `.gain()` wird zur Anschlagstärke (Velocity). Ein Flügel klingt bei leisem Anschlag weicher, nicht nur leiser.
- **16 Kanäle.** Das GP-310 empfängt auf allen 16 Kanälen getrennt, jeder Kanal mit eigenem Klang. Mit `.midichan(2)` schickst du eine Stimme auf Kanal 2.
- **Klang wählen.** `.progNum(n)` schaltet den Klang eines Kanals um. Welche Nummer welcher Klang ist (und ob zuerst ein Bank-Select nötig ist), steht in der Tone List im Handbuch des Klaviers. Am besten einmal am Anfang senden, nicht bei jeder Note.
- **Haltepedal.** `.control([64, 1])` drückt das Pedal, `.control([64, 0])` lässt es los.
- **Timing.** Strudel verzögert MIDI um 34 ms, damit es zum Browser-Ton passt. Klingt das Klavier zu früh oder zu spät, ändere den Wert: `.midi('CASIO USB-MIDI', { latencyMs: 50 })`.

Einschränkungen:

- Strudel-Effekte (`.room()`, `.lpf()`, `.delay()`) wirken nicht auf den Klavierklang; das Klavier hat nur seine eigenen Effekte.
- Die Tasten bewegen sich nicht mit, das GP-310 ist kein Selbstspielklavier.
- **Rückkopplung vermeiden:** Schick nicht `kb()` direkt wieder per `.midi()` ans Klavier. Sonst klingt jede Note doppelt. Wenn du genau das willst (Tasten → Strudel-Muster → Klavier), stell am Klavier *Local Control* aus; dann spielen die Tasten nur noch über Strudel.

## Audio zusammenführen

Sobald das Klavier mitspielt, kommen zwei Klangquellen aus zwei Geräten. Zuhause reicht das: Mac-Lautsprecher plus Klavierlautsprecher. Für einen Auftritt oder eine Aufnahme führst du beide zusammen:

- **Kleines Mischpult** (4 Kanäle genügen): LINE OUT L/R vom Klavier auf zwei Kanäle, Kopfhörerausgang vom Mac auf zwei weitere. Am Pult regelst du das Verhältnis, der Ausgang geht zur Anlage.
- **Audio-Interface mit 2 Eingängen**: Klavier-LINE-OUT ins Interface, Strudel läuft über dasselbe Interface raus. Vorteil: Du kannst beides am Mac aufnehmen.

Sind die LINE-OUT-Buchsen belegt, schalten sich die Lautsprecher des Klaviers bei vielen Casio-Modellen ab; prüf das beim ersten Test. Den Pegel des Klaviers stellst du dann am Lautstärkeregler des Klaviers ein, nicht am LC XL 3.

## Fehlersuche

| Problem | Ursache | Lösung |
| --- | --- | --- |
| Klavier fehlt in der Geräteliste | Kabel nur zum Laden, Browser ohne Web MIDI | Datenfähiges USB-Kabel nehmen, Chrome nutzen, MIDI-Erlaubnis in den Seiteneinstellungen prüfen |
| `midikeys` reagiert nicht | Falscher Gerätename | Namen aus `midi-test.strudel` exakt kopieren |
| Keine MIDI-Daten für kurze Zeit | Klavier zeigt „Please Wait …“ | Warten; in dieser Zeit sendet und empfängt es nichts |
| Jede Note klingt doppelt | Klavier klingt selbst mit oder Echo per `.midi()` | Klavier leiser drehen oder Local Control aus |
| Klavier hängt hinter dem Beat | MIDI-Latenz passt nicht | `latencyMs` in `.midi()` anpassen |
| Falscher Klang auf einem Kanal | Altes Programm noch aktiv | `.progNum()` einmal neu senden |

## Quellen

- [Strudel: MIDI, OSC and MQTT](https://strudel.cc/learn/input-output/) — `midikeys`, `midin`, `.midi()`, `progNum`, `latencyMs`
- [Casio GP-310 MIDI Implementation (PDF)](https://casioau.com/cdn/shop/files/GP-310__Midi_Implementation.pdf) — Sende- und Empfangskanäle, Program Change, Haltepedal
