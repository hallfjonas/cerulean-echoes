# Genres

One definition per genre. The folder under `tracks/` is the genre's name (`tracks/<genre>/NNN-<name>/`). A track belongs to
the genre whose "must have" list it meets and whose "must not have" list it avoids. Humans and agents use the same test.

Status: **draft for agreement**. A definition is agreed when the people who play and listen to this music have read it in
this PR and accepted it. Until then, the numbers are the ones the existing tracks already use.

## How to read a definition

- **Definition**: one sentence, what the genre is.
- **Tempo**: beats per minute (BPM) the genre plays at. "Bar" means one 4/4 measure.
- **Must have**: features a track in this genre has.
- **Must not have**: features that move a track out of this genre, with the genre it belongs to instead.
- **Tracks here**: the repo tracks in this genre.
- **Listen**: references in [listening-list.md](listening-list.md).

## Ambient

- **Definition**: slow, soft music of pads and drones, with little or no steady beat. Mood: calm, dreamy, spacious.
- **Tempo**: about 60–80 BPM, or no fixed pulse.
- **Must have**: pads or drones that hold for many bars; slow changes of colour; soft, sparse percussion, if any.
- **Must not have**: a kick on every beat (four-on-the-floor). That is ambient house.
- **Tracks here**: [007-ambient-soundscape](../../tracks/ambient/007-ambient-soundscape/) (D, about 70 BPM, three moods).
- **Listen**: see the Ambient section of [listening-list.md](listening-list.md).

## Ambient House

- **Definition**: house-tempo dance music with the warm, open sound of ambient: melodic, airy, organic percussion.
- **Tempo**: about 115–125 BPM.
- **Must have**: a four-on-the-floor kick (a kick on every beat); warm pads or keys that carry the melody; organic
  percussion (shakers, hats, rims, not hard claps); room for air, so not dense in every bar.
- **Must not have**: a groove driven by a bass line and piano chords (that is house); a dark, hypnotic loop (that is techno).
- **Tracks here**: [010-ambient-house](../../tracks/ambient-house/010-ambient-house/) (D minor, 120 BPM).
- **Listen**: Harmon, Kiasmos, David August (Ambient House section).

## House

- **Definition**: dance music with a steady four-on-the-floor kick, a groovy bass line and piano chords, dry and bright
  in sound. Mood: happy, jazzy, playful.
- **Tempo**: about 118–128 BPM.
- **Must have**: four-on-the-floor kick; bass line with groove; house piano chords (also 8-bar progressions); a lighter,
  playful melody on flute-like or bright sounds; a dry sound (little reverb on the drums).
- **Must not have**: long pads and no bass groove (ambient house); a dark, minimal loop at 130+ BPM (techno).
- **Tracks here**: [009-house](../../tracks/house/009-house/) (A minor, 124 BPM).
- **Listen**: Sarah Wild, Fusion 2025 (the main reference for 009, with its tracklist).

## Techno

- **Definition**: fast, hypnotic dance music built on a driving kick and a repeating loop, with dark, minimal sound.
- **Tempo**: about 130–145 BPM.
- **Must have**: driving kick on every beat; a loop that repeats and changes slowly; dark percussion and synth textures;
  few melodic notes, the loop carries the track.
- **Must not have**: a groove that rolls and swings with warm keys (groove techno); bright piano chords and a playful
  melody (house); soft pads with no hard kick (ambient).
- **Listen**: Yanamaste, Marie Montexier (Techno section).

## Groove Techno

- **Definition**: techno whose main draw is the groove: a rolling, syncopated bass and percussion pattern that makes the
  body move, with warm harmonic colour (keys, mallets) over dark drums. Mood: driving, warm, funky.
- **Tempo**: about 130–140 BPM (to agree; 008 is 140).
- **Must have**: a four-on-the-floor kick; a syncopated groove layer (offbeat hats, shakers, rim or percussion with a
  swing feel); a rolling bass line or looping bass pattern that carries the groove; warm keys or mallets (Rhodes, piano,
  organ, vibes) used sparingly, mixed into a dark drum sound; slow change over the loop, with the groove as the hook.
- **Must not have**: no harmonic colour at all and only a bare, minimal loop (techno); a playful house piano or a light
  flute-like melody over a bass groove (house); no hard kick (ambient house, ambient).
- **Tracks here**: [008-groove-techno](../../tracks/techno/008-groove-techno/) (F, 140 BPM; piano, Rhodes, organs, mallets
  on its keys; dark one-shots on the pads).
- **Listen**: add references here when agreed (the Groove Techno section of [listening-list.md](listening-list.md) is
  still empty).

## EDM

- **Definition**: festival electronic dance music: big builds, a drop, bright lead sounds and a high, uplifting energy.
- **Tempo**: about 120–130 BPM (to agree; 012 is 120).
- **Must have**: a build (rising tension, sweeps, fills) that resolves in a drop; a loud, bright lead; a four-on-the-floor
  or sidechain-style pumping rhythm; a played melody from a Guitar Pro source, as written.
- **Must not have**: a slow, soft feel without a drop (ambient house); no lead and no build (house or techno).
- **Tracks here**: [012-edm-snippet](../../tracks/edm/012-edm-snippet/) (G♯ minor, 120 BPM, 24 bars).

## Classical

- **Definition**: a notated, composed piece played as written, with acoustic-sounding voices and no electronic dance beat.
- **Tempo**: as written in the score (the track follows the tempo map of the Guitar Pro file).
- **Must have**: a composed score as source (Guitar Pro MIDI); melodic lines and harmony that follow the score; no
  four-on-the-floor kick.
- **Must not have**: a dance groove or an electronic beat driving the piece (any dance genre).
- **Tracks here**: [013-hope-for-niklas](../../tracks/classical/013-hope-for-niklas/) (A minor, 110 BPM, 56 bars).

## Rock

- **Definition**: band music with guitars, bass and drums: overdriven guitars, a steady beat, a clear song form.
- **Tempo**: about 100–115 BPM for slow rock (015 changes from 100 to 115 BPM at bar 100).
- **Must have**: distorted or overdriven guitar; a bass line in half notes or riffs; a live-band drum kit (kick, snare,
  hats, crash, toms); a song form with verse, chorus and a final section.
- **Must not have**: a four-on-the-floor kick as the main pulse (house, techno, EDM); no guitar or bass voice.
- **Tracks here**: [015-slow-rock](../../tracks/rock/015-slow-rock/) (D minor, 100 → 115 BPM; the Guitar Pro file is in the
  folder, the track is not built yet).

## Not genres

- `sets/`: combined sets that play several tracks in one piece (011 plays 007 → 010 → 009 → 008). A set takes the genre
  of its tracks; it has no genre of its own.
- `historic/`: older tracks 000–006 and `johannes-tracks`. They are not assigned to a genre here. Add a definition when the
  genre is agreed.

## Choosing between neighbours

Check in this order and stop at the first match:

1. Classical: the source is a composed score and there is no dance beat.
2. Rock: guitars and a live drum kit drive the piece, no four-on-the-floor kick.
3. Groove techno: driving kick, a rolling syncopated groove, warm keys or mallets over dark drums, 130–140 BPM.
4. Techno: a driving kick, a repeating dark loop, 130 BPM or more, with no warm harmonic colour.
5. EDM: a build that resolves in a drop, with bright leads.
6. House: four-on-the-floor kick, bass groove, piano chords, 118–128 BPM.
7. Ambient house: four-on-the-floor kick, warm pads and air, 115–125 BPM, sparse melody.
8. Ambient: no steady kick, slow pulse or none, pads and drones.

If a track fits two genres, name the one that matches the first rule above and say what it borrows from the other in its
`feedback.md`.

## To agree (open questions for the readers of this PR)

- Tempo ranges: are 118–128 for house and 115–125 for ambient house the right bands, or should they overlap less?
- EDM tempo: 120–130, or 128–140?
- Groove techno tempo: 130–140, or wider up to 145 (techno's range)?
- Does groove techno need a listening reference of its own? The Groove Techno section of the listening list is empty.
- Does rock need a separate "heavy" or "ballad" label, or is slow rock enough?
- Is "ambient house" one word or two in the folder names (`ambient-house` stays unless agreed otherwise)?

## Changing a definition

A change to a definition goes through a PR to this file. Tracks are not moved between genres in the same PR; a move is a
separate PR with the track's new folder.
