// Stem Designer: a project file (sc/lab/stems/<name>.stemlab.json, format: sc/lab/stems/stemlab.schema.json) as a stem
// track. The columns of the project are stem versions (library files or drafts of the project) on the 14 slots; the
// context track (default 090-stem-demo) gives tempo, frame (chords, chapters, global column) and, as backing, the stems
// of the slots named in context.backing, which play without a controller. Controls as in a stem track, except column 8:
//   button 1  A/B     the column moved last swaps at the next bar between its candidate and the context track's stem
//                     of the same slot (when both need the same mixer strip, ~ce.swapProblem)
//   button 2  Promote the player's server writes the column's draft into the library (/ce/promote, a library stem
//                     is there already)
// The column moved last is the selection (Save writes it into the project). Loaded by sc/engine.scd and
// sc/tools/render.scd for a .stemlab.json path.
(
~ce.stemLabProject = { |self, path|
	var project = self.readJSON(path), context = project[\context] ? (track: "090-stem-demo");
	var contextPath = self.root +/+ "tracks" +/+ context[\track] +/+ (context[\track] ++ ".track");
	var base = self.readJSON(contextPath), json, track, buildBase, backing = (), number = 0;
	self.stemDrafts = project[\drafts] ? ();
	(context[\backing] ? []).do { |slot| number = number + 1; backing[("b:" ++ number).asSymbol] = base[\slots][slot.asSymbol] };
	json = (name: "stems-" ++ project[\name], tempo: base[\tempo], swing: base[\swing], frame: base[\frame],
		chapters: base[\chapters], slots: project[\columns], dir: contextPath.dirname, backing: backing, ccCount: 256,
		lab: true, chapter: self.numOf(context[\chapter] ? 0));
	track = self.loadStemTrack(contextPath, nil, json);
	track.project = project;
	track.labSelected = (project[\select] ? project[\columns].keys.asArray.sort[0]).asSymbol;
	track.labShowing = ();
	track.labTags = { |lines|
		lines.reject { |l| l.contains(" g.b1 ") or: { l.contains(" g.b2 ") } }
			++ ["// @ctl g.b1 A/B | candidate ↔ the context track's stem.", "// @ctl g.b2 Promote | draft into the library."] };
	track.tagLines = self.stemTrackTags(track);
	buildBase = track[\build];
	track[\build] = { |t, ce| buildBase.(t, ce); ce.stemLabBuild(t, base[\slots]) };
	track[\uiHead] = { |t, ce|
		[["Column", t.labSelected.asString], ["Chord", t.chordAt(TempoClock.default.bar.max(0)).name]] };
	track[\uiGlobal] = { |t, ce| var shown = (t.labShowing[t.labSelected] ? \candidate).asString;
		(b1: [shown[0].toUpper ++ shown.drop(1)] ! 2, b2: ["Promote"] ! 2) };
	track[\uiCols] = { |t, ce| (designer: (select: t.labSelected.asString)) };
	track
};

~ce.stemLabBuild = { |self, t, original|
	var ce = self, projectColumns = t.project[\columns];
	ce.stemSlots.do { |slot| t.columns[slot] !? {
		ce.slotCCs(slot).values.do { |cc| ce.onCC(cc, { t.labSelected = slot; ce.uiPush }) } } };
	ce.onPress(ce.stemGlobal[\chapter], {
		var slot = t.labSelected, shown = t.labShowing[slot] ? \candidate, other, ref, why;
		other = if(shown == \candidate) { \original } { \candidate };
		ref = if(other == \original) { original[slot] } { projectColumns[slot] };
		why = if(ref.isNil) { "no context stem on %".format(slot) } { ce.swapProblem(slot, ref) };
		if(why.notNil) { ce.status("A/B", why) } {
			ce.swapSlot(slot, ref);
			t.labShowing[slot] = other;
			ce.status("A/B", "% %".format(slot, other)) };
		ce.uiPush });
	ce.onPress(ce.stemGlobal[\break], {
		ce.uiSend('/ce/promote', t.labSelected.asString);
		ce.status("Promote", t.labSelected.asString) })
};
)
