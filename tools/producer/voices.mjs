// Voice library: how a column sounds. The EDM voices come from the approved pilot (012), the Classical ones play the
// Sonatina Symphonic Orchestra samples (SSO, see SAMPLE_SETS). A voice turns the column's pattern list (built by
// make-track.mjs from the MIDI part and the map) into a stem. Each voice gives:
//   kind      'note' (pitched part), 'drum' (GM drums), 'hit' (a pitched part played as drum hits: each chord one hit
//             on its lowest note, chords of `accent` notes or more full, smaller ones as ghost notes) or 'extra' (a
//             Mode 2 column without a MIDI part)
//   about     the section comment, what  the fader text (make-track adds where the part plays)
//   ctl       knob rows and button 2 as '@ctl' texts (k1, k2, k3, b2: 'Name | what it does.'); voices that share a
//             column (program changes, grouped parts) must have the same ctl
//   lowEnd    true: the stem goes out with Break (it wraps itself in beatOnly)
//   ties      true: notes tied over the bar line ring on (their clip is raised); else they are cut at the bar line
//   samples   the SAMPLE_SETS the voice plays (loaded by the track)
//   code(c)   the stem's code; c = { id, ID, stem, col, var, pats, noisePats, harmonyNotes, patsOf() }: col and var
//             name the column's controls and pattern latch; patsOf() writes the bar constants, the song object
//             (section → bars) and the pattern list named by c.pats
//   token     drum voices: GM drum name (midi-read.mjs) → sample name (909: in the RolandTR909 bank)
//   rollHits  drum voices: a bar with more hits than this gets `roll` (each hit cut, 6 dB down: tails sum up)
//   noise     the riser also builds a white-noise copy of its patterns (c.noisePats)
//   figure    extras: the figure of one bar where the extra plays; harmony: true plays the map's chords instead,
//             patterns: the extra's own pattern names
// Columns without a MIDI part (Mode 2 extras) play `figure` in every bar of the sections they play in, but stop bars.

export const VOICES = {
  'kick-909': {
    kind: 'drum', lowEnd: true, about: '909 kick', what: '909 kick as written',
    token: { kick: 'bd', kick2: 'bd', snare: 'sd', snare2: 'sd', clap: 'cp', stick: 'rim', hhclosed: 'hh',
      hhpedal: 'hh', hhopen: 'oh', crash: 'cr', crash2: 'cr', ride: 'rd', ride2: 'rd', tomlo: 'lt', tomlo2: 'lt',
      tommid: 'mt', tommid2: 'mt', tomhi: 'ht', tomhi2: 'ht' }, rollHits: 16, roll: '.clip(1).gain(0.5)',
    ctl: { k1: 'Brightness | dull ↔ bright.', k2: 'Space | dry ↔ room.', k3: 'Punch | 0 = the plain 909 ↔ driven and hard.',
      b2: 'Drop out | kick pauses while held.' },
    code: c => `const ${c.id}Punch = ${c.col}.char
${c.patsOf()}

const ${c.stem} = beatOnly(gate(${c.col}.btn2.fmap(v => v <= 0.5), strip(dryBus(
  pick(${c.var}, ${c.pats}).bank('RolandTR909').shape(${c.id}Punch.mul(0.5)).velocity(${c.id}Punch.fmap(p => 1 - 0.4 * p)),
  1, ${c.col}.space), {
  lpf: expRange(${c.col}.bright, 2500, 14000),
  level: ${c.col}.level.range(0, 0.7),
})))`,
  },
  'saw-sub': {
    kind: 'note', lowEnd: true, about: 'a sawtooth through a low-pass, the "Synth Bass 1" growl', what: 'growling sub',
    ctl: { k1: 'Brightness | dull growl ↔ buzzing.', k2: 'Space | dry ↔ room.', k3: 'Length | as written ↔ long, legato.',
      b2: 'Octave | one octave up while held.' },
    code: c => `${c.patsOf()}

const ${c.stem} = beatOnly(strip(dryBus(pick(${c.var}, ${c.pats}).add(note(octaveUp(${c.col}.btn2)))
  .s('sawtooth').gain(0.76).attack(0.004).sustain(1).release(0.05).lpq(2)
  .clip(${c.col}.char.fmap(c => 1 + c)), 1, ${c.col}.space), {
  lpf: expRange(${c.col}.bright, 300, 2000),
  level: ${c.col}.level.range(0, 1),
}))`,
  },
  'reese-bass': {
    kind: 'note', lowEnd: true, about: 'a reese: two detuned saws, low-passed', what: 'reese bass',
    ctl: { k1: 'Brightness | dark ↔ buzzing.', k2: 'Space | dry ↔ room.', k3: 'Length | as written ↔ long, legato.',
      b2: 'Octave | one octave up while held.' },
    code: c => `${c.patsOf()}

const ${c.stem} = beatOnly(strip(dryBus(pick(${c.var}, ${c.pats}).add(note(octaveUp(${c.col}.btn2)))
  .s('sawtooth').superimpose(x => x.add(note(0.15)).pan(0.35), x => x.add(note(-0.15)).pan(0.65))
  .gain(0.33).attack(0.004).decay(0.3).sustain(0.7).release(0.06).lpq(3)
  .clip(${c.col}.char.fmap(c => 1 + c)), 1, ${c.col}.space), {
  lpf: expRange(${c.col}.bright, 400, 3000),
  level: ${c.col}.level.range(0, 1),
}))`,
  },
  'supersaw-chords': {
    kind: 'note', about: 'supersaw chords', what: 'supersaw chords',
    ctl: { k1: 'Brightness | dull ↔ bright.', k2: 'Space | dry ↔ echo + room.', k3: 'Length | as written ↔ every hit rings on.',
      b2: 'Lift | wider and brighter while held.' },
    code: c => `const ${c.id}Lift = held(${c.col}.btn2)
${c.patsOf()}

const ${c.stem} = strip(bus(pick(${c.var}, ${c.pats})
  .s('supersaw').gain(0.37).attack(0.005).decay(0.2).sustain(0.75).release(0.12)
  .detune(${c.id}Lift.fmap(l => l ? 0.4 : 0.18)).spread(${c.id}Lift.fmap(l => l ? 1 : 0.6))
  .clip(${c.col}.char.fmap(c => 1 + 3 * c)), 2, ${c.col}.space, 0.2), {
  lpf: expRange(${c.col}.bright, 1500, 9000).mul(${c.id}Lift.fmap(l => l ? 2 : 1)),
  level: ${c.col}.level.range(0, 1),
})`,
  },
  'saw-lead': {
    kind: 'note', about: 'two detuned saws through a low-pass', what: 'saw lead',
    ctl: { k1: 'Brightness | soft ↔ biting.', k2: 'Space | dry ↔ echo + room.', k3: 'Glide | plain ↔ each note slides in from below.',
      b2: 'Echo throw | long echo while held.' },
    code: c => `${c.patsOf()}

const ${c.stem} = strip(throwEcho(bus(pick(${c.var}, ${c.pats})
  .s('sawtooth').superimpose(x => x.add(note(0.1)).pan(0.6)).pan(0.4)
  .gain(0.45).attack(0.005).decay(0.2).sustain(0.6).release(0.1)
  .penv(${c.col}.char.fmap(g => -3 * g)).pdecay(0.09), 2, ${c.col}.space, 0.25), ${c.col}.btn2), {
  lpf: expRange(${c.col}.bright, 1800, 9000),
  level: ${c.col}.level.range(0, 1),
})`,
  },
  'saw-pluck': {
    kind: 'note', about: 'a sawtooth pluck with a fast filter envelope', what: 'saw pluck',
    ctl: { k1: 'Brightness | soft pluck ↔ sharp.', k2: 'Space | dry ↔ echo + room.', k3: 'Length | short pluck ↔ long.',
      b2: 'Octave | one octave up while held.' },
    code: c => `${c.patsOf()}

const ${c.stem} = strip(bus(pick(${c.var}, ${c.pats}).add(note(octaveUp(${c.col}.btn2)))
  .s('sawtooth').gain(1).attack(0.002).decay(${c.col}.char.fmap(c => 0.12 + 0.4 * c)).sustain(0).release(0.05)
  .lpenv(3).lpattack(0.002).lpdecay(0.1).lpsustain(0).pan(0.55), 2, ${c.col}.space, 0.3), {
  lpf: expRange(${c.col}.bright, 900, 6000),
  level: ${c.col}.level.range(0, 1),
})`,
  },
  'saw-riser': {
    kind: 'note', noise: true, about: 'a run on a sawtooth whose filter opens over 4 bars; a white noise sweep with Noise',
    what: 'saw run',
    ctl: { k1: 'Brightness | dull ↔ bright.', k2: 'Space | dry ↔ echo + room.', k3: 'Noise | notes only ↔ + a white noise sweep.',
      b2: 'Rise | a noise sweep rises over 2 bars while held.' },
    code: c => `const ${c.id}Rise = heldRamp(${c.col}.btn2, 2)
${c.patsOf()}
// The filter opens 3 octaves over every 4 bars
const ${c.id}Open = saw.slow(4).fmap(x => Math.pow(8, x))
const ${c.id}Noise = gate(above(${c.col}.char, 0), pick(${c.var}, ${c.noisePats})
  .attack(0.01).sustain(0.8).release(0.05).bpf(saw.slow(4).fmap(x => 400 * Math.pow(20, x))).bpq(2)
  .gain(${c.col}.char.fmap(c => w => 0.25 * c * (0.3 + 0.7 * w)).appLeft(saw.slow(4))).pan(rand.range(0.3, 0.7)))
const ${c.id}Sweep = gate(held(${c.col}.btn2), s("white*16")
  .attack(0.03).sustain(0.8).release(0.15)
  .bpf(${c.id}Rise.fmap(r => 300 * Math.pow(20, r))).bpq(4)
  .gain(${c.id}Rise.mul(0.35)).pan(sine.fast(2)))

const ${c.stem} = strip(bus(stack(
  pick(${c.var}, ${c.pats}).s('sawtooth').gain(0.3).attack(0.003).sustain(0.8).release(0.05),
  ${c.id}Noise,
  ${c.id}Sweep,
), 2, ${c.col}.space, 0.25), {
  lpf: expRange(${c.col}.bright, 500, 3000).mul(${c.id}Open),
  level: ${c.col}.level.range(0, 1),
})`,
  },
  'clap-909': {
    kind: 'extra', about: '909 clap on 2 and 4', what: 'clap on 2 and 4', figure: 'drum("~ cp ~ cp").gain(0.7)',
    ctl: { k1: 'Brightness | dull ↔ bright.', k2: 'Space | dry ↔ room.', k3: 'Complexity | plain ↔ + quiet claps in between.',
      b2: 'Roll | snare roll, growing over the bar, while held.' },
    whatSuffix: ' Also Tension\'s roll.',
    code: c => `const ${c.id}Ghost = ${c.col}.char
${c.patsOf()}

const ${c.stem} = strip(bus(stack(
  pick(${c.var}, ${c.pats}),
  gate(above(${c.id}Ghost, 0), drum("~ ~ ~ [~ cp] ~ ~ ~ [~ cp]").gain(ramp(${c.id}Ghost, 0, 1).mul(0.3))),
  gate(held(${c.col}.btn2), drum("sd*16").gain(saw.range(0.1, 0.5))),
  // Tension roll: 8ths → 16ths, louder as Tension rises
  gate(above(tensionRoll, 0), drum("sd*16").degradeBy(tensionRoll.fmap(t => 0.75 * (1 - t)))
    .gain(tensionRoll.fmap(t => 0.06 + 0.29 * t)))
).hpf(300).pan(0.47), 1, ${c.col}.space, 0.2), {
  lpf: expRange(${c.col}.bright, 3500, 14000),
  high: true,
  level: ${c.col}.level.range(0, 0.95),
})`,
  },
  'hats-909': {
    kind: 'extra', about: 'a short 909 open hat on the off-beats', what: 'off-beat open hat',
    figure: 'drum("[~ oh]*4").decay(0.12).sustain(0).gain(0.4)',
    ctl: { k1: 'Brightness | dull ↔ bright.', k2: 'Space | dry ↔ room.', k3: 'Complexity | off-beat only ↔ + quiet closed 16ths.',
      b2: 'Open | long open hats on every 8th while held.' },
    code: c => `${c.patsOf()}

const ${c.stem} = strip(bus(stack(
  gate(held(${c.col}.btn2).fmap(h => !h), pick(${c.var}, ${c.pats})),
  gate(above(${c.col}.char, 0), drum("hh*16").gain("[0.2 0.1 0.14 0.1]*4").mul(gain(${c.col}.char))),
  gate(held(${c.col}.btn2), drum("oh*8").gain(0.3))
).mul(gain(1.2)).pan(0.56), 1, ${c.col}.space, 0.2), {
  lpf: expRange(${c.col}.bright, 3000, 16000),
  high: true,
  level: ${c.col}.level.range(0, 1.2),
})`,
  },
  'supersaw-pad': {
    kind: 'extra', harmony: true, about: 'a soft supersaw on the song\'s chords, one per bar, slow attack',
    what: 'supersaw pad on the chords',
    ctl: { k1: 'Brightness | dull ↔ bright.', k2: 'Space | dry ↔ echo + room.', k3: 'Swell | still ↔ breathing in and out every 2 bars.',
      b2: 'Octave | one octave up while held.' },
    patterns: ['Held', 'Pulse'],
    code: c => `const ${c.ID}_CHORD = everyBar(${c.harmonyNotes})
const ${c.ID}_PATS = [
  ${c.ID}_CHORD.attack(0.6).sustain(0.8).release(1.5),
  ${c.ID}_CHORD.struct("x*8").attack(0.01).decay(0.15).sustain(0.3).release(0.1),
]

const ${c.stem} = strip(bus(pick(${c.var}, ${c.ID}_PATS).add(note(octaveUp(${c.col}.btn2)))
  .s('supersaw').unison(3).gain(0.2).pan(0.5)
  .mul(gain(${c.col}.char.fmap(c => w => 1 - 0.75 * c * w).appLeft(sine.slow(2)))), 2, ${c.col}.space, 0.15), {
  lpf: expRange(${c.col}.bright, 600, 6000),
  level: ${c.col}.level.range(0, 1),
})`,
  },
  'noise-pump': {
    kind: 'extra', about: 'pink noise that swells in after every kick (a sidechain pump without a compressor)',
    what: 'pink noise pumping with the kick',
    figure: 's("[~ pink@3]*4").attack(0.14).sustain(0.7).release(0.03).hpf(900).gain(2.2)',
    ctl: { k1: 'Brightness | dull ↔ bright.', k2: 'Space | dry ↔ room.', k3: 'Motion | still ↔ the filter breathes, the noise wanders.',
      b2: 'Open | the noise opens bright while held.' },
    code: c => `const ${c.id}Move = ${c.col}.char
${c.patsOf()}

const ${c.stem} = strip(bus(pick(${c.var}, ${c.pats})
  .pan(${c.id}Move.fmap(m => p => 0.5 + m * (p - 0.5)).appLeft(sine.slow(3))), 1, ${c.col}.space, 0.15), {
  lpf: expRange(${c.col}.bright, 1500, 12000).mul(held(${c.col}.btn2).fmap(o => o ? 4 : 1))
    .fmap(f => m => w => f * (1 - 0.7 * m * w)).appLeft(${c.id}Move).appLeft(sine.slow(2)),
  level: ${c.col}.level.range(0, 1),
})`,
  },
}

// ---------- Classical: the orchestra (SSO samples), every voice on the hall bus (orbit 2) ----------

// Sample sets: [folder, file prefix, notes, file suffix] per group (one-shots: notes empty, the file is prefix +
// suffix). Names shared with 009 load the same files there.
export const SSO_URL = 'https://raw.githubusercontent.com/peastman/sso/master/Sonatina%20Symphonic%20Orchestra/Samples/'
const VA_NOTES = ['c3', 'd#3', 'f#3', 'a3', 'c4', 'd#4', 'f#4', 'a4', 'c5']
export const SAMPLE_SETS = {
  sso_vn_sus: [['1st%20Violins', '1st-violins-sus-',
    ['g3', 'a#3', 'c#4', 'e4', 'g4', 'a#4', 'c#5', 'e5', 'g5', 'a#5', 'c#6'], '.wav']],
  sso_va_sus: [['Violas', 'violas-sus-', VA_NOTES, '.wav']],
  sso_vc_sus: [['Celli', 'celli-sus-', ['d#2', 'f#2', 'a2', 'c3', 'd#3', 'f#3', 'a3', 'c4', 'd#4', 'f#4', 'a4'],
    '.wav']],
  sso_cb_sus: [['Basses', 'basses-sus-', ['c1', 'd#1', 'f#1', 'a1', 'c2', 'd#2', 'f#2', 'a2', 'c3', 'd#3', 'f#3', 'a3'],
    '.wav']],
  sso_vn: [['1st%20Violins', '1st-violins-stc-rr1-',
    ['g3', 'c#4', 'e4', 'g4', 'a#4', 'c#5', 'e5', 'g5', 'a#5', 'c#6', 'e6', 'g6'], '.wav']],
  sso_va: [['Violas', 'violas-stc-rr1-', VA_NOTES, '.wav']],
  sso_vc: [['Celli', 'celli-stc-rr1-', ['c2', 'd#2', 'f#2', 'a2', 'c3', 'd#3', 'f#3', 'a3', 'c4'], '.wav']],
  sso_vn_piz: [['1st%20Violins', '1st-violins-piz-rr1-',
    ['g3', 'a#3', 'c#4', 'e4', 'g4', 'a#4', 'c#5', 'e5', 'a#5', 'c#6'], '.wav']],
  sso_vc_piz: [['Celli', 'celli-piz-rr1-', ['c2', 'd#2', 'f#2', 'a2', 'c3', 'd#3', 'f#3', 'a3', 'c4'], '.wav']],
  sso_hn_sus: [['Horns', 'horns-sus-mp-', ['e2', 'g2', 'a#2', 'c#3', 'e3', 'g3', 'a#3', 'c#4', 'e4', 'g4', 'a#4'],
    '-PB-loop.wav']],
  sso_tb_sus: [['Trombones', 'trombones-sus-', ['e2', 'g2', 'a#2', 'c#3', 'e3', 'g3', 'a#3', 'c#4', 'e4'], '.wav']],
  sso_tp_sus: [['Trumpets', 'trumpets-sus-', ['e3', 'g3', 'a#3', 'c#4', 'e4', 'g4', 'a#4', 'c#5', 'e5', 'g5'], '.wav']],
  sso_hn: [['Horns', 'horns-stc-rr1-', ['e2', 'g2', 'a#2', 'c#3', 'e3', 'g3', 'a#3', 'c#4', 'e4', 'g4', 'a#4'],
    '.wav']],
  sso_tb: [['Trombones', 'trombones-stc-rr1-', ['e2', 'g2', 'a#2', 'c#3', 'e3', 'g3', 'a#3', 'c#4', 'e4'], '.wav']],
  sso_piano: [['Grand%20Piano', 'MF%20', ['A1', 'C2', 'E2', 'G2', 'A2', 'C3', 'E3', 'G3', 'A3', 'C4'], '.flac'],
    ['Grand%20Piano', 'Mf%20', ['E4', 'G4', 'A4', 'C#5', 'E5', 'G5'], '.flac']],
  sso_chimes: [['Percussion', 'chimes-', ['c3', 'd#3', 'f#3', 'a3', 'c4', 'd#4', 'f#4', 'a4', 'c5', 'd#5', 'f#5'],
    '.wav']],
  sso_timp: [['Percussion', 'timpani-f-rh-', ['c1', 'd#1', 'f#1', 'a1', 'c2'], '.wav']],
  sso_timp_roll: [['Percussion', 'timpani-roll-crsc-', ['c1', 'd#1', 'f#1', 'a1', 'c2'], '.wav']],
  sso_bd: [['Percussion', 'bass_drum-f', [], '.wav']],
  sso_piatti: [['Percussion', 'piatti', [], '.wav']],
  sso_tamtam: [['Percussion', 'tamtam-a', [], '.wav']],
  sso_cym_roll: [['Percussion', 'cymbal_roll-a-mf', [], '.wav']],
  sso_snare_roll: [['Percussion', 'snare-roll', [], '.wav']],
  sso_triangle: [['Percussion', 'triangle-opn-rr1', [], '.flac']],
}

const ORCH_CTL = { k1: 'Brightness | dark ↔ bright.', k2: 'Space | dry ↔ concert hall.',
  k3: 'Length | as written ↔ long, legato.', b2: 'Lift | brighter and louder while held.' }
const PERC_CTL = { k1: 'Brightness | dull ↔ bright.', k2: 'Space | dry ↔ concert hall.',
  k3: 'Damp | let ring ↔ short, damped.', b2: 'Drop out | pauses while held.' }
// Sections by register: [top MIDI note (exclusive), sound, gain factor]
const STRINGS_SUS = '[[55, \'sso_vc_sus\', 1.1], [67, \'sso_va_sus\', 1], [Infinity, \'sso_vn_sus\', 0.9]]'
const STRINGS_STC = '[[55, \'sso_vc\', 1], [67, \'sso_va\', 1], [Infinity, \'sso_vn\', 0.9]]'
const BRASS_SUS = '[[52, \'sso_tb_sus\', 0.9], [64, \'sso_hn_sus\', 1.2], [Infinity, \'sso_tp_sus\', 0.7]]'
const BRASS_STC = '[[55, \'sso_tb\', 1], [Infinity, \'sso_hn\', 1]]'
const PIZZ = '[[55, \'sso_vc_piz\', 1], [Infinity, \'sso_vn_piz\', 1]]'

// A sampled orchestra voice: source(pat, ID) = how the notes become sounds (after .gain), sections = register lists the
// source reads as ID_NAME, lpf = brightness range
function orchestral({ source, sections = {}, gain, attack, release, lpf: [lo, hi], lowEnd = false }) {
  return c => `const ${c.id}Lift = held(${c.col}.btn2)
${Object.entries(sections).map(([name, list]) => `const ${c.ID}_${name} = ${list}\n`).join('')}${c.patsOf()}

const ${c.stem} = ${lowEnd ? 'beatOnly(' : ''}strip(bus(lengthen(
  ${source(`pick(${c.var}, ${c.pats}).gain(${gain})`, c.ID)}.attack(${attack}).release(${release}),
  ${c.col}.char).mul(gain(${c.id}Lift.fmap(l => l ? 1.3 : 1))), 2, ${c.col}.space), {
  lpf: expRange(${c.col}.bright, ${lo}, ${hi}).mul(${c.id}Lift.fmap(l => l ? 2 : 1)),
  level: ${c.col}.level.range(0, 1),
})${lowEnd ? ')' : ''}`
}
const one = sound => pat => `${pat}.s('${sound}')`
const bySections = (pat, ID) => `byRegister(${pat}, ${ID}_SECTIONS)`

// Percussion: drums or hits on the hall bus, Damp shortens the ring, button 2 pauses
function percussion({ gain, lpf: [lo, hi], sound }) {
  return c => `${c.patsOf()}

const ${c.stem} = beatOnly(gate(${c.col}.btn2.fmap(v => v <= 0.5), strip(dryBus(
  damp(pick(${c.var}, ${c.pats})${sound ? `.s('${sound}')` : ''}.gain(${gain}), ${c.col}.char), 2, ${c.col}.space), {
  lpf: expRange(${c.col}.bright, ${lo}, ${hi}),
  level: ${c.col}.level.range(0, 1),
})))`
}

function classicalVoices() {
  const note = (about, what, samples, settings, extra = {}) => ({ kind: 'note', ties: true, about, what, samples,
    ctl: ORCH_CTL, lowEnd: settings.lowEnd, code: orchestral(settings), ...extra })
  return {
    'orch-piano': note('a concert grand (SSO Grand Piano, mezzo-forte)', 'grand piano', ['sso_piano'],
      { source: one('sso_piano'), gain: 0.35, attack: 0.002, release: 0.6, lpf: [1500, 14000] }),
    'orch-cello': note('the cello section, sustained (SSO Celli)', 'cellos', ['sso_vc_sus'],
      { source: one('sso_vc_sus'), gain: 0.6, attack: 0.08, release: 0.5, lpf: [800, 9000], lowEnd: true }),
    'orch-contrabass': note('the double basses, sustained (SSO Basses)', 'double basses', ['sso_cb_sus'],
      { source: one('sso_cb_sus'), gain: 0.7, attack: 0.06, release: 0.4, lpf: [500, 6000], lowEnd: true }),
    'orch-violin': note('the first violins, sustained (SSO 1st Violins)', 'violins', ['sso_vn_sus'],
      { source: one('sso_vn_sus'), gain: 0.8, attack: 0.03, release: 0.3, lpf: [1500, 14000] }),
    'orch-strings': note('the string section, sustained: cellos, violas and violins by register', 'strings',
      ['sso_vc_sus', 'sso_va_sus', 'sso_vn_sus'],
      { source: bySections, sections: { SECTIONS: STRINGS_SUS }, gain: 0.3, attack: 0.12, release: 0.8, lpf: [1200, 12000] }),
    'orch-pizz': note('pizzicato strings: cellos below G3, violins above', 'pizzicato', ['sso_vc_piz', 'sso_vn_piz'],
      { source: bySections, sections: { SECTIONS: PIZZ }, gain: 0.55, attack: 0.001, release: 0.2, lpf: [1500, 14000] }),
    'orch-brass': note('the brass section, sustained: trombones, horns and trumpets by register', 'brass',
      ['sso_tb_sus', 'sso_hn_sus', 'sso_tp_sus'],
      { source: bySections, sections: { SECTIONS: BRASS_SUS }, gain: 0.22, attack: 0.05, release: 0.5, lpf: [1000, 10000] }),
    'orch-chimes': note('tubular bells (SSO chimes)', 'tubular bells', ['sso_chimes'],
      { source: one('sso_chimes'), gain: 0.35, attack: 0.001, release: 1.5, lpf: [2000, 16000] }),
    'orch-hit': note('an orchestra hit: strings and brass short (staccato) on the chord', 'orchestra hit',
      ['sso_vc', 'sso_va', 'sso_vn', 'sso_tb', 'sso_hn'],
      { source: (pat, ID) => `${pat}\n    .layer(x => byRegister(x, ${ID}_STRINGS), x => byRegister(x, ${ID}_BRASS))`,
        sections: { STRINGS: STRINGS_STC, BRASS: BRASS_STC }, gain: 0.35, attack: 0.001, release: 0.3, lpf: [1500, 14000] }),
    'fretless-synth': note('a fretless bass: a soft triangle that slides into each note from below', 'fretless bass',
      [], { source: pat => `${pat}.s('triangle').penv(-1).pdecay(0.08)`, gain: 0.9, attack: 0.02, release: 0.15,
        lpf: [300, 2500], lowEnd: true }),
    'orch-timpani': {
      kind: 'hit', accent: 4, ghost: 0.45, lowEnd: true, ctl: PERC_CTL, samples: ['sso_timp'],
      about: 'timpani on the lowest note of each chord; full chords loud, small ones soft', what: 'timpani',
      code: percussion({ gain: 0.8, lpf: [800, 12000], sound: 'sso_timp' }),
    },
    'orch-perc': {
      kind: 'drum', lowEnd: true, ctl: PERC_CTL, samples: ['sso_bd', 'sso_piatti'],
      about: 'orchestral percussion: concert bass drum and clash cymbals (piatti)', what: 'bass drum and cymbals',
      token: { kick: 'sso_bd', kick2: 'sso_bd', crash: 'sso_piatti', crash2: 'sso_piatti', china: 'sso_piatti',
        splash: 'sso_piatti' }, rollHits: 8, roll: '.clip(1).gain(0.5)',
      code: percussion({ gain: 0.8, lpf: [1500, 16000] }),
    },
  }
}

Object.assign(VOICES, classicalVoices())

// Default voice of a part without a map: by genre, GM program family and how the part plays
export function defaultVoice({ genre = 'edm', ...part }) {
  return genre === 'classical' ? classicalVoice(part) : edmVoice(part)
}

function classicalVoice({ isDrums, program, polyphonic, medianPitch }) {
  if (isDrums) return 'orch-perc'
  const family = Math.floor(program / 8)
  const byProgram = { 40: 'orch-violin', 41: 'orch-violin', 42: 'orch-cello', 43: 'orch-contrabass',
    45: 'orch-pizz', 55: 'orch-hit', 35: 'fretless-synth' }
  if (byProgram[program]) return byProgram[program]
  const byFamily = { 0: 'orch-piano', 1: 'orch-chimes', 2: 'orch-piano', 7: 'orch-brass', 8: 'orch-brass',
    14: 'orch-timpani' }
  if (byFamily[family]) return byFamily[family]
  if (family === 4) return medianPitch < 40 ? 'orch-contrabass' : 'fretless-synth'
  if (polyphonic) return 'orch-strings'
  return medianPitch < 55 ? 'orch-cello' : 'orch-violin'
}

function edmVoice({ isDrums, program, polyphonic, medianPitch, shortNotes }) {
  if (isDrums) return 'kick-909'
  const family = Math.floor(program / 8)
  if (family === 15 || family === 12) return 'saw-riser'
  if (family === 14 || family === 1) return 'saw-pluck'
  if (family === 4 || medianPitch < 48) return medianPitch < 40 && !polyphonic ? 'saw-sub' : 'reese-bass'
  if (polyphonic || family === 11 || family === 6 || family === 5) return 'supersaw-chords'
  return shortNotes ? 'saw-pluck' : 'saw-lead'
}
