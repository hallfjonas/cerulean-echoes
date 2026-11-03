(
s.options.numInputBusChannels = 0;
s.options.numBuffers = 1024 * 256;
s.options.memSize = 8192 * 32;
s.options.maxNodes = 1024 * 32;
s.waitForBoot {
  ~dirt = SuperDirt(2, s);
  ~dirt.loadSoundFiles;
  ~dirt.start(57120, 0 ! 12);
};
)

s.quit;