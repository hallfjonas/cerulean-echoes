# Casio GP-310 with Strudel (MIDI)

As of: 2026-10-31

## Short answer

One USB cable between Mac and piano covers both directions: the GP-310 sends your keys to Strudel and, the other way round, plays notes that Strudel sends it.

- **As input** (piano → Strudel): very useful. With `midikeys()` you play Strudel sounds from the keyboard, with pedal and real hammer action.
- **As output** (Strudel → piano): useful for piano parts. Strudel writes the notes, but the GP-310's grand piano sound is far better than any browser piano sample. The piano receives on 16 channels at once, so you can send several parts with different sounds.
- **The catch with output**: the piano sound comes from the piano's speakers, not from the Mac. Effects like `.room()` or `.lpf()` do not touch it. For a shared mix you need a second cable (section Audio).

## Cables and ports

For MIDI you need only one cable: **USB-C to USB-B**. The M2 Air has only USB-C; the piano has a square USB-B socket on the back (like a printer).

| Purpose | Cable | From → to | Needed? |
| --- | --- | --- | --- |
| MIDI in both directions | USB-C to USB-B, USB 2.0, 2–3 m | Mac → USB-B socket on the GP-310 | Yes |
| Piano sound into mixer/interface | 2× 6.3 mm jack, mono | LINE OUT L/MONO and R → two inputs | Only for a shared mix |
| Mac sound into the same mixer | 3.5 mm mini jack stereo to 2× 6.3 mm jack mono | Mac headphone out → two inputs | Only for a shared mix |

- No adapter fiddling needed: a USB-C to USB-B cable costs about 10 €. Or use the existing USB-A to B cable with a USB-C adapter.
- The second USB socket (type A) is for USB sticks, not for the Mac.
- According to the maker the GP-310 has no Bluetooth audio; MIDI runs over USB only.
- You do not need classic 5-pin MIDI cables.

The socket details come from maker and dealer pages; a look at the back of the piano confirms them in a minute.

## Setup step by step

1. Switch the piano on, then plug the USB cable into Mac and piano. No driver needed; macOS detects USB MIDI devices itself.
2. Check that the Mac sees the piano: open **Audio MIDI Setup**, menu *Window → Show MIDI Studio*. A Casio icon should appear there.
3. Open Strudel in **Chrome** (or Edge). Safari has no Web MIDI. The first time, the browser asks whether the page may use MIDI devices: allow it.
4. Run `snippets/midi-test.strudel`. The box at the bottom right lists all MIDI inputs. Copy the piano's name exactly (often something like `CASIO USB-MIDI`).
5. Press a key: the box then shows a message from channel 1 (type 9 = note on). The connection works.

The examples below use `'CASIO USB-MIDI'` as a placeholder. Put the name from step 4 there, in single quotes.

## Piano as input: keys play Strudel sounds

For notes there is `midikeys()`; `midin()` only reads controls (CC), as with the LC XL 3. You can use both devices at the same time.

```js
const kb = await midikeys('CASIO USB-MIDI')

// every key you press plays a filtered saw through Strudel's own effects
kb().s('sawtooth').lpf(1200).room(0.4).delay(0.25)
```

What you need to know:

- **Fixed note length.** Strudel does not know how long you hold a key; every note gets a fixed length. `kb("0.5 1")` changes that length in the pattern. Long held pads and the sustain pedal therefore do not work as on the piano.
- **Double sound.** The piano itself sounds while you play. Turn the piano's volume all the way down or play with headphones on the Mac.
- **Channel.** The keyboard sends on channel 1. If you use Layer or Split on the piano, the second voice comes on channel 2 and the left part on channel 3. That lets you separate the hands:

```js
const kb = await midikeys('CASIO USB-MIDI')

stack(
  kb().filterValues(v => v.midichan == 1).s('triangle'),          // upper part
  kb().filterValues(v => v.midichan == 3).s('sawtooth').lpf(400)  // left side of the split
)
```

In a track with an LC XL 3, just put `midikeys` next to your `midin`; the stems stay unchanged.

## Piano as output: Strudel plays the grand piano sound

Yes, that is worth it for piano parts: `.midi()` sends the notes to the GP-310, and you hear the real grand sound instead of a browser sample.

```js
// arpeggio played by the piano's own grand sound
note("<c3 e3 g3 b3>*4").gain(0.7).midi('CASIO USB-MIDI')
```

- **Level.** `.gain()` becomes the key velocity. A grand sounds softer at low velocity, not just quieter.
- **16 channels.** The GP-310 receives on all 16 channels separately, each channel with its own sound. `.midichan(2)` sends a part to channel 2.
- **Choosing the sound.** `.progNum(n)` switches a channel's sound. Which number is which sound (and whether a bank select is needed first) is in the Tone List in the piano's manual. Best sent once at the start, not with every note.
- **Sustain pedal.** `.control([64, 1])` presses the pedal, `.control([64, 0])` releases it.
- **Timing.** Strudel delays MIDI by 34 ms to match the browser sound. If the piano sounds too early or too late, change the value: `.midi('CASIO USB-MIDI', { latencyMs: 50 })`.

Limits:

- Strudel effects (`.room()`, `.lpf()`, `.delay()`) do not touch the piano sound; the piano has only its own effects.
- The keys do not move; the GP-310 is not a player piano.
- **Avoid feedback:** do not send `kb()` straight back to the piano with `.midi()`. Otherwise every note sounds twice. If that is exactly what you want (keys → Strudel pattern → piano), switch *Local Control* off on the piano; then the keys play only through Strudel.

## Combining audio

As soon as the piano plays along, two sound sources come from two devices. At home that is enough: Mac speakers plus piano speakers. For a gig or a recording you bring both together:

- **Small mixer** (4 channels are enough): LINE OUT L/R from the piano onto two channels, Mac headphone out onto two more. Set the balance on the mixer; its output goes to the PA.
- **Audio interface with 2 inputs**: piano LINE OUT into the interface, Strudel plays out through the same interface. Advantage: you can record both on the Mac.

When the LINE OUT sockets are in use, many Casio models switch off the piano's speakers; check this on the first test. You then set the piano's level with the piano's volume control, not on the LC XL 3.

## Troubleshooting

| Problem | Cause | Fix |
| --- | --- | --- |
| Piano missing from the device list | Charge-only cable, browser without Web MIDI | Use a USB data cable, use Chrome, check the MIDI permission in the site settings |
| `midikeys` does not react | Wrong device name | Copy the name from `midi-test.strudel` exactly |
| No MIDI data for a short time | Piano shows "Please Wait …" | Wait; during this time it neither sends nor receives |
| Every note sounds twice | Piano sounds itself, or echo via `.midi()` | Turn the piano down or switch Local Control off |
| Piano lags behind the beat | MIDI latency is off | Adjust `latencyMs` in `.midi()` |
| Wrong sound on a channel | Old program still active | Send `.progNum()` once more |

## Sources

- [Strudel: MIDI, OSC and MQTT](https://strudel.cc/learn/input-output/) — `midikeys`, `midin`, `.midi()`, `progNum`, `latencyMs`
- [Casio GP-310 MIDI Implementation (PDF)](https://casioau.com/cdn/shop/files/GP-310__Midi_Implementation.pdf) — send and receive channels, program change, sustain pedal
