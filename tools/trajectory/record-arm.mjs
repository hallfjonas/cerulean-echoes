// The Record button is a switch: on means "record whenever something plays". These two pure functions hold its rules;
// player.html applies them (start or stop the recorder, show the button).

// What to do now so the recorder matches the switch: record exactly while the switch is on and the track plays.
export const recordAction = ({ armed, transport, recording }) => {
  const wanted = armed && transport === 'playing'
  if (wanted && !recording) return 'start'
  if (!wanted && recording) return 'stop'
  return null
}

// 'recording' (a file is being written), 'armed' (on, nothing plays), 'off'
export const recordButtonState = ({ armed, recording }) => recording ? 'recording' : armed ? 'armed' : 'off'
