// Stem Designer: a project file (sc/lab/stems/<name>.stemlab.json, format: sc/lab/stems/stemlab.schema.json) as a stem
// track. The columns of the project are stem versions (library files or drafts of the project) on the slots the
// file names (a slot without a column is free). The context track (default 090-stem-demo) gives
// tempo, frame (chords, chapters, global column) and, as backing, the stems of the slots named in context.backing,
// which play without a controller. Controls as in a stem track, except column 8:
//   master fader, button 1  as everywhere, column 8 is the same in both modes. Button 1 cycles what the fader sets:
//                              the level of the columns (Stems) or of the backing (Context); each keeps its own level
//   Add, Remove and Promote are in the player's panel: a free slot shows "+ Add", a column the trash symbol and the
//   promote symbol (active while the column holds a draft). The panel posts them to the player's server. Replace: a
//   click on a stem's title opens the player's stem drawer.
// The column moved last is the selection (Save writes it into the project). Loaded by sc/engine.scd and sc/tools/render.scd for a .stemlab.json path.
(
~ce.stemLabProject = { |self, path|
	var project = self.readJSON(path), context = project[\context] ? (track: "090-stem-demo");
	var contextPath = self.root +/+ "tracks" +/+ context[\track] +/+ (context[\track] ++ ".track");
	var base = self.readJSON(contextPath), json, track, buildBase, backing = (), number = 0;
	var fileSlots = project[\columns].keys.asArray.sort;
	if(fileSlots.any { |slot| self.stemSlots.includes(slot).not }) {
		Error("a Stem Designer project holds columns on slots 1:1 to 2:7 only").throw };
	project[\select] = if(project[\columns][(project[\select] ? \none).asSymbol].notNil) { project[\select] } {
		fileSlots[0] ? self.stemSlots[0] };
	self.stemDrafts = project[\drafts] ? ();
	(context[\backing] ? []).do { |slot| number = number + 1; backing[("b:" ++ number).asSymbol] = base[\slots][slot.asSymbol] };
	json = (name: "stems-" ++ project[\name], tempo: base[\tempo], swing: base[\swing], frame: base[\frame],
		chapters: base[\chapters], slots: project[\columns], dir: contextPath.dirname, backing: backing, ccCount: 256,
		lab: true, chapter: self.numOf(context[\chapter] ? 0));
	track = self.loadStemTrack(contextPath, nil, json);
	track.project = project;
	track.labSelected = project[\select].asSymbol;
	track.labTargets = [\stems, \context];
	track.labTarget = \stems;
	track.labLevels = (stems: 1, context: 1);
	track.labTags = { |lines|
		lines.reject { |l| [" g.b1 ", " g.b2 ", " g.fader "].any { |tag| l.contains(tag) } }
			++ ["// @ctl g.fader Level | the level of the volume shown on button 1.",
				"// @ctl g.b1 Volume | next: Stems (the columns), Context (the backing)."] };
	track.tagLines = self.stemTrackTags(track);
	buildBase = track[\build];
	track[\build] = { |t, ce| buildBase.(t, ce); ce.stemLabBuild(t) };
	track[\uiHead] = { |t, ce|
		[["Column", t.labSelected.asString], ["Chord", t.chordAt(TempoClock.default.bar.max(0)).name]] };
	track[\uiGlobal] = { |t, ce| var name = t.labTarget.asString;
		(b1: [name[0].toUpper ++ name.drop(1)] ! 2) };
	track[\uiCols] = { |t, ce|
		var slots = ();
		ce.stemSlots.do { |slot| slots[slot] = t.slots[slot] !? { |ref| if(ref.beginsWith("draft:")) { "draft" } { "library" } } ? "free" };
		(designer: (select: t.labSelected.asString, slots: slots)) };
	track
};

~ce.stemLabBuild = { |self, t|
	var ce = self, glob = ce.stemGlobal, setLevels = { |send|
		ce.setCC(ce.labLevelCc[\stems], t.labLevels[\stems], send);
		ce.setCC(ce.labLevelCc[\context], t.labLevels[\context], send) };
	ce.stemSlots.do { |slot| t.columns[slot] !? {
		ce.slotCCs(slot).values.do { |cc| ce.onCC(cc, { t.labSelected = slot; ce.uiPush }) } } };
	ce.onCC(glob[\master], { |v, send| t.labLevels[t.labTarget] = v; setLevels.(send) });
	ce.onPress(glob[\chapter], {
		t.labTarget = t.labTargets.wrapAt(t.labTargets.indexOf(t.labTarget) + 1);
		ce.status("Volume", t.labTarget.asString);
		ce.uiPush })
};
)
