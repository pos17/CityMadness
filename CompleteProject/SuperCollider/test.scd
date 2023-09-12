Env.new(levels: [0, 1, 0.8, 0], times: [0.5, 0.5, 0.6], curve: [-6, -1, 1]).plot;

{BPF.ar(SinOsc.ar(BrownNoise.ar(300, 400)) * 0.1,MouseX.kr(80, 800, 1), 0.2);}.play


s.boot;

{ Mix.new([ PinkNoise.ar(0.1), FSinOsc.ar(801, 0.1), LFSaw.ar(40, 0.1)]) }.play

(
play({
    Mix.new( Array.fill(8, { SinOsc.ar(500 + 500.0.rand, 0, 0.05) }) );
}))

(.
play({
    Mix.fill(8, { SinOsc.ar(500 + 500.0.rand, 0, 0.05) });
}))