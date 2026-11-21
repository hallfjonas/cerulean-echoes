# Lab boards

> New sound work on SuperCollider goes to the [sound lab](sound-lab.md); lab boards are the Strudel way.

## What it is
A lab board is not a track. It is a test bench for one instrument or one track role, such as bass, keys or kick.
Either it holds one sound tuned on its own, or it holds several candidates side by side. Each candidate sits in a
column built like a track column (Brightness, Space, Level, Pattern), so you hear it the way it would play in a
track.

## When to use it
- You need a new bass, chord sound or drum feel and want to choose by ear.
- You want to compare candidates before putting one into a track.

## How to use it
1. Find the board in `lab/<instrument>/`, for example `lab/bass/` or `lab/harmony/`. Each folder has a `feedback.md`.
2. Play it in the [player](player.md) (pick it under **Lab**) or paste the file into strudel.cc
   ([strudel.cc](strudel-cc.md)). Play the columns on the controller.
3. Tell Claude what you liked and what you did not. The result goes into `feedback.md` with the date.
4. Claude builds the next round: it keeps the columns you rated good and replaces the rest with new ones. The current
   round stays in the folder, and older rounds are deleted (git history keeps them). Whole series you rejected go to
   `lab/archive/`.
5. When a column wins, it goes into a track one to one, with the same controls, sounds and levels.

The Claude skills `lab-board` (build a round) and `lab-to-track` (move a winner into a track) do these steps
([Claude skills](claude-skills.md)).

## Good to know
- Boards need rhythm, not only held notes, and all knobs at 0 must already sound good.
- Nothing you rejected comes back: `feedback.md` is read before every new round.
- A board also has a context: a few faders (drums, bass, pad) on the second controller mode, so the candidate is
  judged in place.
- Ear training boards with live sliders and a handbook PDF live in `lab/tutorials/`.

## Related
- [Player](player.md)
- [Live tracks](live-tracks.md)
- [Controllers](controllers.md)
- [Samples and sounds](samples-and-sounds.md)
