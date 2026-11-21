// The "About this page" text of every player page, by page key (pages.mjs pageKey): Live, Labs / Samples,
// Labs / Stems, the planned Labs pages and Visualization. DOM-free: a section is { heading, text } as help.mjs shows it.
const LIVE = [
  { heading: 'What it does', text: 'Plays a live track or a lab project right here. Live shows both controller '
    + 'pages and the Launchkey row with every control\'s name and value; Labs holds the Sample and Stem Designer '
    + '(Tracks and Sets are planned); Visualization draws every stem with its name and the tempo. The sidebar shows '
    + 'only what the page needs. No strudel.cc needed.' },
  { heading: 'Input', text: 'A track or project from the list (the file is read again on every load, so Play plays your '
    + 'latest edit), plus every connected MIDI controller. A control not moved yet reads 0.' },
  { heading: 'Output', text: 'Sound, the Live panel and visuals. Save take writes what the controllers did since the '
    + 'last load to tools/trajectory/perform/<track>/takes/, uncommitted. Record writes the sound to recordings/<track>/.' },
  { heading: 'How to use', text: ['Pick a track in the sidebar and press Play.', 'Play the controllers, or start '
    + 'Auto-perform (P) to try the track without hardware.', 'Live, Labs and Visualization switch the page; the sound '
    + 'keeps playing.', 'S hides the sidebar, F is fullscreen; Visual '
    + 'settings (Visualization page) hold the visual controls.', 'Theme (T switches Minimal / Retro): the look of this page and the '
    + 'panel, dark, light or as the system (Auto).'] },
  { heading: 'Takes', text: ['Every Play starts a new capture of all controller input (auto-perform included).',
    'Save take writes it as a script; it shows up in the Auto-perform list as takes/<name>.',
    'Start plays it back from a fresh load (the clock restarts at bar 0); what you play on top during a replay is '
    + 'captured too.',
    'Save take after a replay names its original and shows the replay check; node trajectory/check-replay.mjs '
    + 'lists every differing bar.',
    'Keep the player tab visible while capturing or replaying: a background tab slows the timers.',
    'A take worth keeping: move it up from perform/<track>/takes/ to perform/<track>/, give it a name and a title, '
    + 'run check-perform and commit it. Takes left in takes/ stay out of git.'] },
  { heading: 'Recording', text: ['Record (R) writes what you hear to recordings/<track>/ as a WAV; Stop rec ends it.',
    'Auto-perform with Record audio ticked records from Start to the end of the script plus 4 s.',
    'Stop or another track ends a recording. Recordings stay out of git.'] },
  { heading: 'Stem swap', text: ['Stem tracks only: click a column\'s name in the Live panel.',
    'The drawer lists the library stems of that column\'s role; filter by genre, energy and tag.',
    'Pick one: it plays from the next bar, the other columns play on. A stem that needs another mixer strip loads '
    + 'the track again with it (a short gap; the drawer says so).',
    'The track file is not changed. Revert puts the file\'s stems back; Save as writes a new track with the stems '
    + 'that play. Play reloads the file.'] }
]

const SAMPLES = [
  { heading: 'What it does', text: 'The Sample Designer: one SuperCollider sound tuned on the controllers while its '
    + 'shape is drawn under them.' },
  { heading: 'Input', text: 'A project from the list (sc/lab/samples/<name>.sample.json). Every control of the '
    + 'controllers changes the sound.' },
  { heading: 'Output', text: 'Sound and four figures of one hit, drawn when the project loads and after every move of a '
    + 'control: waveform, envelope (attack and decay), spectrum (strongest frequency, centroid) and spectrogram. '
    + 'Export writes the sound to sc/sounds/ with its WAV.' },
  { heading: 'How to use', text: ['Pick a project and press Load.', 'Move a control: the figures follow.',
    'Save writes the values into the project (also LC column 8, button 2); Save as copies it under a new name.',
    'Export turns the sound into a library sound once it is right.'] }
]

const STEMS = [
  { heading: 'What it does', text: 'The Stem Designer: stems side by side on the controller columns, played against a '
    + 'context track, to find the stem that fits.' },
  { heading: 'Input', text: 'A project from the list (sc/lab/stems/<name>.stemlab.json): its columns on '
    + 'their slots, and the context track that plays the rest.' },
  { heading: 'Output', text: 'Sound, and the project file. Column 8 is the same in both modes: button 1 picks what the fader '
    + 'sets, the level of everything (Global), of the stems you explore (Stems) or of the context sound (Context); '
    + 'each keeps its own level.' },
  { heading: 'How to use', text: ['Pick a project and press Load.', 'Move a control of a column to select it.',
    'Every free slot shows + Add: click it, pick a stem in the drawer (the Live page\'s), it goes on that slot.',
    'Above a stem\'s title: the export symbol (active only for a changed stem, see Promote) and the trash symbol '
    + '(the slot is free again).',
    'Click a knob\'s name to change what the knob does (see Knobs). A click on a stem\'s title opens the drawer to '
    + 'replace that stem.',
    'Add, trash and Apply load the project again (a short gap); Replace plays from the next bar when the stem fits '
    + 'the column\'s mixer strip. All change the project file: Save as first to keep a copy.',
    'Save writes the selected column into the project; Save as copies the project.'] },
  { heading: 'Knobs', text: 'The knob editor picks a parameter of the stem\'s sound (or Space, Echo, Pan), the two '
    + 'bounds the knob moves it between, the curve, the default position of the knob and its name. A preset fills the '
    + 'fields. Apply writes it into a draft of that stem: the library stem stays as it is. Knob 1 and 2 keep the '
    + 'names Brightness and Space while they drive brightness and space; drive something else and give them a name '
    + 'of their own.' },
  { heading: 'Promote', text: 'A stem you changed (a draft) is not in the library yet. The export symbol above its '
    + 'title writes it into the library as a new stem version and puts that version on the slot. A stem that is in '
    + 'the library already has nothing to export: the symbol is grayed out.' }
]

const PLANNED = [
  { heading: 'What it does', text: 'Planned: this designer is not built yet. The Labs menu keeps its place.' }
]

const VISUALS = [
  { heading: 'What it does', text: 'Draws every stem of the playing track with its name and the tempo.' },
  { heading: 'Input', text: 'The track that plays: start it on Live or Labs.' },
  { heading: 'How to use', text: ['Visual settings in the sidebar change the look.',
    'S hides the sidebar, F is fullscreen.'] }
]

const BY_PAGE = { live: LIVE, 'labs/samples': SAMPLES, 'labs/stems': STEMS, 'labs/tracks': PLANNED,
  'labs/sets': PLANNED, visuals: VISUALS }

export const helpFor = key => BY_PAGE[key] ?? LIVE
