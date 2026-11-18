# One Hope

Design for `perform/013-hope-for-niklas/one-hope.json`. Starting point: the approved song design
(`tracks/classical/013-hope-for-niklas/013-hope-for-niklas-design.md`, layout B, Mode 2 empty, chapters keep the
song's place). The script is generated from the `performance` section of `013-hope-for-niklas-map.json`
(`npm run producer -- <mid> --map <map> --perform`): change the moves there, not the JSON.
Status: proposal, waiting for the user (Loop 1 / Round 1). The script was written alongside it, so the first listen can
answer both.

## Meta
- Track: 013-hope-for-niklas
- Length: 57 bars = 2 min 4 s at 110 BPM (the 56-bar song once, 1 bar = 2.18 s, plus one bar of silence for the last
  hits to ring out). A classical piece with a written ending is played once, not looped.
- Mood: a classical piece in A minor that grows from a cello and a piano into a march
- Story: It opens far away (a little fog) with the cello pedal and the piano, violin and pizzicato join softly. The
  timpani, strings and brass bring the pulse and one long crescendo into Part 2, where everything plays. Part 3 is the
  march in E; the violin holds its E alone, two final hits, a tam-tam, silence.
- References: none for classical in `docs/references.md` yet. Listen for an orchestral arc: a dynamic range of about
  10 dB from the opening to the march, no drops, the shape made by entries and faders.

Script bar = song bar − 1 (Start restarts the song at cycle 0). Chapter switches at the next 2-bar line, so its
presses are written two bars early (bar 29 for Part 2 at bar 31, bar 45 for Part 3 at bar 47). Bars in the table
are 1-based; the JSON's are 0-based (table bar − 1). Levels are set half a
bar before a part's first note, never ramped under a part's first note (a note keeps the level it starts with).

## Sections
| Section | Bars | LC controls (by @ctl name) | Launchkey | Intent |
|---|---|---|---|---|
| Dawn | 1-12 | Master 0.9; Fog 0.4 -> 0 ramp 11 from bar 2; Space: Percussion, Bass, Pizzicato 0.3, Piano 0.35, Strings, Brass & Bells 0.4, Violin 0.45; Bass Level 0.7, Piano Level 0.8 at 1; Violin Level 0.45, Pizzicato Level 0.5 at 6.5; Chapter press at 2 (-> Part 1 at 3, same bars) | - | Cello and piano from afar, violin and pizzicato join at 7, the fog clears |
| Groove | 13-18 | at 12.5: Percussion Level 0.5, Strings Level 0.5, Bass Level 0.55, Piano Level 0.7 | - | Timpani, fretless and strings bring the pulse |
| Rise | 19-30 | Brass & Bells Level 0.45 at 18.5; from 25: Master 0.9 -> 1, Strings 0.5 -> 0.6, Brass & Bells 0.45 -> 0.55, ramps 6; Chapter press at 29 (-> Part 2 at 31); Violin Level 0.7 at 30.5 | - | Brass joins, one long crescendo into the cymbals of bar 30 |
| Drive | 31-46 | Percussion Level 0.55 at 31; Brass & Bells 0.55 -> 0.65 ramp 7 from 39; Chapter press at 45 (-> Part 3 at 47); Percussion Level 0.6 at 46.5 | - | Part 2, everything in, violin arpeggio on top, a swell into the A major bar 46 |
| March | 47-54 | (levels from Drive) | - | Part 3: bells, bass drum and cymbals, contrabass |
| Ending | 55-57 | Master 0 at 56.5, after the two hits | pad Tam-tam at 56 | Violin E alone, two final hits with a tam-tam, then silence |

## Risks
- CPU peak: Drive (31-46): every column plays, many sustained SSO samples ring at once (1,668 events in 16 bars). Check
  in the player on the M2 Air.
- Clipping: none measured. Mix rendered at the script's levels (`render.mjs`, event-level, no browser): Dawn bars 1-4
  −27.6 LUFS (peak 0.16), Groove 13-16 −23.7 (0.24), Rise 27-30 −21.8 (0.29), Drive 39-46 −17.7 (0.53), March 47-50
  −17.1 (0.49), bar 56 with the tam-tam −18.1 (0.57).
- Silent stretches: none unplanned. Bar 55 is the violin's E alone (as written), bar 57 is the ring-out after Master 0.
  After the script the controls keep their values: Master stays 0, so the loop back to bar 1 is not heard.

## Open questions
- Length: once through (2 min). A repeat (Part 2 twice, as a classical repeat sign) is not possible with chapters that
  keep the song's place: after a held Part 2 the song's own place is bar 7 and Part 3's is bar 53. It needs chapters
  that restart at their first bar (the alternative in the song design). Wanted?
- Opening: Fog 0.4 clearing over 11 bars, or start clear?
- Dynamic range: the opening is about 10 dB quieter than the march. Too quiet for the room?
- Tam-tam on the final hits: keep, or the hits alone as written?
- Chapter follows the song (Part 1, Part 2, Part 3) and changes nothing you hear; it only names the movement on the LC
  view. Keep, or leave Chapter on Song?
- Section names are working titles.
