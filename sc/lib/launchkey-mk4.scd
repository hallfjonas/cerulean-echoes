// Driver launchkey-mk4: the Launchkey MK4 25, its own stem: keys and drum pads (channel 10) play at once (the track's
// lkNote, ~ce.lkPlay), its mod wheel (CC 1, with pickup) and knobs (CC 21-28, pad bank 31-38) go to ~ce.lkCC and
// the track's lkCtl (its own controls, apart from the LC's: its knobs would collide with the LC knobs). Its DAW port
// is ignored.
(
~ce.addDriver((name: 'launchkey-mk4', kind: \launchkey,
	portMatch: { |d, n| n.contains("Launchkey") and: { n.contains("DAW").not } },
	inCC: { |d, ce, uid, val, num, chan|
		if(num == 1) {
			ce.pickup(uid, \lk1, val / 127, ce.lkCC[1], { ce.setLkCC(num, val / 127, { |msg| ce.server.sendMsg(*msg) }) }) }
			{ ce.setLkCC(num, val / 127, { |msg| ce.server.sendMsg(*msg) }) } },
	inNote: { |d, ce, uid, note, vel, chan| if(vel > 0) { ce.lkPlay(note, vel / 127, chan) } { [] } }
));
)
