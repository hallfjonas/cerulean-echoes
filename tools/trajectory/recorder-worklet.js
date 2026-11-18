// AudioWorklet of recorder.mjs: turns its stereo input into interleaved 16-bit PCM and posts one chunk per `seconds`
// (transferred, no copy) plus the peak since the last chunk about ten times a second. Message 'flush' posts what is
// left and then 'done'.
class RecorderProcessor extends AudioWorkletProcessor {
  constructor({ processorOptions }) {
    super()
    this.frames = Math.round(sampleRate * processorOptions.seconds)
    this.levelFrames = Math.round(sampleRate / 10)
    this.fresh()
    this.peak = 0
    this.sinceLevel = 0
    this.port.onmessage = ({ data }) => {
      if (data !== 'flush') return
      this.post()
      this.port.postMessage('done')
    }
  }

  fresh() {
    this.buffer = new Int16Array(this.frames * 2)
    this.filled = 0
  }

  post() {
    if (!this.filled) return
    const chunk = this.buffer.buffer.slice(0, this.filled * 4)
    this.port.postMessage({ chunk }, [chunk])
    this.fresh()
  }

  process([input]) {
    const left = input[0]
    if (!left) return true
    const right = input[1] ?? left
    for (let i = 0; i < left.length; i++) {
      const l = Math.max(-1, Math.min(1, left[i]))
      const r = Math.max(-1, Math.min(1, right[i]))
      this.peak = Math.max(this.peak, Math.abs(l), Math.abs(r))
      this.buffer[this.filled * 2] = l < 0 ? l * 0x8000 : l * 0x7fff
      this.buffer[this.filled * 2 + 1] = r < 0 ? r * 0x8000 : r * 0x7fff
      if (++this.filled === this.frames) this.post()
    }
    this.sinceLevel += left.length
    if (this.sinceLevel >= this.levelFrames) {
      this.port.postMessage({ peak: this.peak })
      this.peak = 0
      this.sinceLevel = 0
    }
    return true
  }
}

registerProcessor('recorder', RecorderProcessor)
