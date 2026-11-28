// The "About this page" text of every player page, by page key (pages.mjs pageKey): Live, Labs / Samples,
// Labs / Stems, Labs / Space, the planned Labs page and Visuals. DOM-free: a section is { heading, text } as help.mjs shows it.
const LIVE = [
  { heading: 'What it does', text: 'Plays a live track or a lab project right here. Live shows both controller '
    + 'pages and the Launchkey row with every control\'s name and value; Labs holds the Sample Designer, Stems & '
    + 'Tracks and Space (Sets is planned); Visuals draws every stem with its name and the tempo. The sidebar shows '
    + 'only what the page needs.' },
  { heading: 'Input', text: 'A track or project from the list (the file is read again on every load, so Play plays your '
    + 'latest edit), plus every connected MIDI controller. A control not moved yet reads 0.' },
  { heading: 'Output', text: 'Sound, the Live panel and visuals. With "Save take on record stop" ticked (Settings), a '
    + 'recording\'s end writes what the controllers did since the last load to tools/trajectory/perform/<track>/takes/, uncommitted. Record writes the sound to recordings/<track>/.' },
  { heading: 'How to use', text: ['Pick a track in the sidebar and press Play (the same button pauses and resumes).', 'Play the controllers, or start '
    + 'Auto-perform (P) to try the track without hardware.', 'Live, Labs and Visuals switch the page; the sound '
    + 'keeps playing.', 'S hides the sidebar, F is fullscreen.', 'The gear opens Settings: Theme (T switches '
    + 'Minimal / Retro; the look of this page and the panel, dark, light or as the system), Visuals, MIDI panel and '
    + 'Recording, plus the list of keyboard shortcuts.'] },
  { heading: 'Takes', text: ['Every Play starts a new capture of all controller input (auto-perform included).',
    'With the setting "Save take on record stop" ticked (Settings, Recording), ending a recording writes the capture as a script; '
    + 'it shows up in the Auto-perform list as takes/<name>.',
    'Start plays it back from a fresh load (the clock restarts at bar 0); what you play on top during a replay is '
    + 'captured too.',
    'A take saved after a replay names its original and shows the replay check; node trajectory/check-replay.mjs '
    + 'lists every differing bar.',
    'Keep the player tab visible while capturing or replaying: a background tab slows the timers.',
    'A take worth keeping: move it up from perform/<track>/takes/ to perform/<track>/, give it a name and a title, '
    + 'run check-perform and commit it. Takes left in takes/ stay out of git.'] },
  { heading: 'Recording', text: ['Record (R) is a switch: while it is on, whatever plays is written to recordings/<track>/ as a WAV.',
    'White = off, steady red = on and waiting for Play, pulsing = recording. Stop leaves it on; click it again to switch off.',
    'Auto-perform with Record audio ticked (or Record on) records from Start to the end of the script plus 4 s.',
    'Stop or another track ends a recording. Recordings stay out of git.'] },
  { heading: 'Stem swap', text: ['Stem tracks only: click a column\'s name in the Live panel.',
    'The drawer lists the library stems of that column\'s role; filter by role (any shows every role), genre, energy and tag.',
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
  { heading: 'What it does', text: 'Stems: stems side by side on the controller columns, played against a '
    + 'context track, to find the stem that fits; a project made from a track, and a project written back as a track.' },
  { heading: 'Input', text: 'A project from the list (sc/lab/stems/<name>.stemlab.json): its columns on '
    + 'their slots, and the context track that plays the rest. New from track starts from a stem track instead.' },
  { heading: 'Output', text: 'Sound, the project file, and with Export track a stem track in sc/tracks/. Column 8 is the same in both modes: button 1 picks what the fader '
    + 'sets, the level of the stems you explore (Stems) or of the context sound (Context); '
    + 'each keeps its own level.' },
  { heading: 'How to use', text: ['Pick a project and press Load (folder symbol; Save is the disk, Save as the disk with a '
    + 'plus, Export track the arrow; hover for the name).', 'Move a control of a column to select it.',
    'Every free slot shows + Add: click it, pick a stem in the drawer (the Live page\'s), it goes on that slot.',
    'Above a stem\'s title: the export symbol (active only for a changed stem, see Promote) and the trash symbol '
    + '(the slot is free again).',
    'Click a knob\'s name to change what the knob does (see Knobs). A click on a stem\'s title opens the drawer to '
    + 'replace that stem.',
    'Add, trash and Apply load the project again (a short gap); Replace plays from the next bar when the stem fits '
    + 'the column\'s mixer strip. All change the project file: Save as first to keep a copy.',
    'Save writes the selected column into the project; Save as copies the project.'] },
  { heading: 'From a track', text: ['Open New from track and pick a stem track.',
    'Each stem goes into the lab (a column you play), the backing (plays along without a controller) or is left '
    + 'off. All stems in lab sets every stem to Lab; off, every stem to Off.',
    'Create writes the project (default name <track>-stems) and plays it.'] },
  { heading: 'Export track', text: ['Writes the project as a stem track sc/tracks/<name>/: the context track\'s frame, '
    + 'tempo, chapters and backing stems, the project\'s columns on their slots.',
    'A changed stem (a draft) cannot go into a track: the player offers to export it to the library first.',
    'The new track shows on the Live page.'] },
  { heading: 'Knobs', text: 'The knob editor picks a parameter of the stem\'s sound (or Space, Echo, Pan), the two '
    + 'bounds the knob moves it between, the curve, the default position of the knob and its name. A preset fills the '
    + 'fields. Apply writes it into a draft of that stem: the library stem stays as it is. Knob 1 and 2 keep the '
    + 'names Brightness and Space while they drive brightness and space; drive something else and give them a name '
    + 'of their own.' },
  { heading: 'Promote', text: 'A stem you changed (a draft) is not in the library yet. The export symbol above its '
    + 'title writes it into the library as a new stem version and puts that version on the slot. A stem that is in '
    + 'the library already has nothing to export: the symbol is grayed out.' }
]

const SPACE = [
  { heading: 'What it does', text: 'Shows where a stem track\'s sound space is free and where it is crowded: time '
    + 'runs left to right, frequency bottom to top, and every cell shows which stems are there.' },
  { heading: 'Input', text: 'A stem track and a setting for each of its stems (pattern, three knobs, level). Every '
    + 'stem is rendered alone in SuperCollider for the chosen number of bars.' },
  { heading: 'Output', text: 'The map and its numbers. Renders are kept in recordings/space/ (outside git): a stem '
    + 'whose setting did not change is not rendered again.' },
  { heading: 'How to use', text: ['Pick a track and a render length, then press Analyse. The first run renders every stem '
    + '(a few seconds each); later runs only the stems you changed.',
    'The tick box includes a stem in the map, the colour swatch sets its colour; neither renders anything.',
    'Settings (pattern, knobs, level) change the stem\'s sound: its dot turns to "needs a render", Analyse renders it again.',
    'Stems colours each cell by its loudest stem; Crowding counts the stems per cell; Free space shows only the gaps.',
    'Cell size runs from 1/32 of a bar to a whole bar; Bars shown and From bar pick the window.',
    '"Active within" decides how far below the loudest sound a stem still counts as there.',
    'The strip on the right shows how much of the time each frequency band is used, the strip below how much of the '
    + 'spectrum each cell uses. Hover the map for the stems in a cell.'] },
  { heading: 'Good to know', text: 'Low notes below about 100 Hz are smeared over roughly 85 ms, longer than a 1/32 '
    + 'cell: use 1/16 or coarser to judge the bass. Each cell is the loudest part of a band, not an average.' }
]

const PLANNED = [
  { heading: 'What it does', text: 'Planned: this designer is not built yet. The Labs menu keeps its place.' }
]

const VISUALS = [
  { heading: 'What it does', text: 'Draws every stem of the playing track with its name and the tempo.' },
  { heading: 'Input', text: 'The track that plays: start it on Live or Labs.' },
  { heading: 'How to use', text: ['Settings (the gear), section Visuals, change the look.',
    'S hides the sidebar, F is fullscreen.'] }
]

const BY_PAGE = { live: LIVE, 'labs/samples': SAMPLES, 'labs/stems': STEMS, 'labs/space': SPACE, 'labs/sets': PLANNED, visuals: VISUALS }

export const helpFor = key => BY_PAGE[key] ?? LIVE
